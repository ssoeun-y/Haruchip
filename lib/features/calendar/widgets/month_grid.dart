import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// 통합 캘린더의 미니 월간 뷰 그리드 — CLAUDE.md §7-4, §8(캘린더 화면).
///
/// haruchip_app.html 489~530줄 "Mini Month View Box" 마크업을 그대로
/// 재현한다(§5/§6): 오늘은 노란 채움(`protoButtonBg`/`protoButtonText`),
/// 일정 있는 날은 점 마커, 선택된 날은 연한 노란 배경.
///
/// 개인 캘린더 표시 자체를 끄는 토글은 만들지 않는다 — §7-4에 따라 개인
/// 캘린더 노출은 항상 강제 ON이다.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.hasEventOnDate,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  /// 그리드가 보여줄 연/월(일자는 무시).
  final DateTime focusedMonth;

  /// 현재 선택된 날짜.
  final DateTime selectedDate;

  /// 해당 날짜에 일정이 있는지 여부(점 마커 노출용).
  final bool Function(DateTime date) hasEventOnDate;

  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    // 일요일 시작 그리드 — html 원본의 일/월/화/수/목/금/토 헤더와 동일.
    final leadingBlanks = firstOfMonth.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.protoCardBorder, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${focusedMonth.year}년 ${focusedMonth.month}월',
                style: AppTypography.cardLabel.copyWith(
                  color: AppColors.protoHeading,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onPreviousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppColors.protoCardText,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: onNextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppColors.protoCardText,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final label in const ['일', '월', '화', '수', '목', '금', '토'])
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoSubtitle,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final date = DateTime(
                focusedMonth.year,
                focusedMonth.month,
                day,
              );
              final isToday = _isSameDay(date, today);
              final isSelected = _isSameDay(date, selectedDate);
              final hasEvent = hasEventOnDate(date);

              return InkWell(
                onTap: () => onDateSelected(date),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.protoButtonBg
                        : isSelected
                            ? AppColors.protoCardSelectedBg
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: AppTypography.caption.copyWith(
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isToday
                              ? AppColors.protoButtonText
                              : AppColors.protoCardText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 4,
                        width: 4,
                        child: hasEvent
                            ? DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppColors.protoButtonText
                                      : AppColors.protoStepLabel,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
