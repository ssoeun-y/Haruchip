import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../home/widgets/add_category_item_dialog.dart';
import '../../onboarding/screens/calendar_integration_screen.dart';
import '../providers/calendar_provider.dart';
import '../widgets/event_list_tile.dart';
import '../widgets/month_grid.dart';

/// 통합 캘린더 화면 — CLAUDE.md §7-4, §8(캘린더 화면).
///
/// 미니 월간 뷰(하루칩/구글/네이버 색상 구분은 각 일정의 `colorHex`로
/// 표현) + 선택한 날짜의 일정 목록. haruchip_app.html 474~530줄 마크업을
/// 그대로 따른다(§5/§6).
///
/// (2부 추가) html 481~485줄 "연동 설정" 버튼 → [CalendarIntegrationScreen]
/// (온보딩 전용 화면에서 "설정에서 언제든 연동을 바꿀 수 있는" 화면으로
/// 재활용됨)으로 push. html 509줄 "+ 일정 추가" 버튼 →
/// [showAddCategoryItemDialog]를 categoryKey='plan' 고정으로 열어
/// `planListProvider`에 새 항목을 추가한다(§8 캘린더 화면: 등록 팝업).
///
/// 개인 캘린더 표시를 끄는 토글은 만들지 않는다(§7-4: 항상 강제 ON).
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedMonth = ref.watch(selectedMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider) ?? DateTime.now();
    final events = ref.watch(eventsForDateProvider(selectedDate));
    final notifier = ref.read(calendarSelectionProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '통합 캘린더',
                          style: AppTypography.heading1.copyWith(
                            color: AppColors.protoHeading,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '구글 / 네이버 / 하루칩 캘린더 동시 조회',
                          style: AppTypography.bodyMuted.copyWith(
                            color: AppColors.protoSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CalendarIntegrationScreen(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.protoCardSelectedBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sync_rounded,
                            size: 14,
                            color: AppColors.protoCardSelectedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '연동 설정',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.protoCardSelectedText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MonthGrid(
                focusedMonth: focusedMonth,
                selectedDate: selectedDate,
                hasEventOnDate: (date) =>
                    ref.watch(eventsForDateProvider(date)).isNotEmpty,
                onDateSelected: notifier.selectDate,
                onPreviousMonth: notifier.previousMonth,
                onNextMonth: notifier.nextMonth,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.protoCardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.protoCardBorder,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${selectedDate.month}월 ${selectedDate.day}일 일정 목록',
                            style: AppTypography.cardLabel.copyWith(
                              color: AppColors.protoHeading,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => showAddCategoryItemDialog(
                            context,
                            categoryKey: 'plan',
                          ),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.protoCardSelectedBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+ 일정 추가',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.protoStepLabel,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (events.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '등록된 일정이 없어요',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.protoSubtitle,
                          ),
                        ),
                      )
                    else
                      for (final e in events) EventListTile(event: e),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
