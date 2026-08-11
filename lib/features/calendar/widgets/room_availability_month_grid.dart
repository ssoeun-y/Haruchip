import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/schedule_room.dart';

/// 방 상세 화면의 "가능한 날짜 표시" 그리드 — 미니 월간뷰 방식.
///
/// CLAUDE.md §7-5(방 상세 플로우 1~3번: 날짜 그리드 탭으로 본인 가능여부
/// 토글, 다른 멤버 표시, 전원 겹침/최다인원 강조). 기존에는 오늘부터
/// 8일 고정 카드 그리드(haruchip_app.html `generateRoomDateRange` 포팅)
/// 였는데, 좌우 화살표로 몇 달 뒤까지 미리 정할 수 있도록 캘린더 탭의
/// [MonthGrid](요일 헤더 + 숫자 칸 + 좌우 화살표, html 489~530줄 스타일)
/// 톤을 그대로 가져와 재구성했다.
///
/// 칸이 작아 멤버 이모지를 다 늘어놓을 수 없으므로, 가능 인원은
/// "n/전체" 배지 + 배경 진하기(가능 인원 비율)로 표현한다 — 이모지
/// 나열은 하지 않는다.
class RoomAvailabilityMonthGrid extends StatelessWidget {
  const RoomAvailabilityMonthGrid({
    super.key,
    required this.focusedMonth,
    required this.room,
    required this.myUid,
    required this.onDateToggle,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  /// 그리드가 보여줄 연/월(일자는 무시).
  final DateTime focusedMonth;

  final ScheduleRoom room;

  /// "나"로 취급할 uid — 탭하면 이 uid의 가능여부만 토글한다.
  final String myUid;

  /// 'YYYY-MM-DD' 문자열 키로 탭한 날짜를 알려준다.
  final ValueChanged<String> onDateToggle;

  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

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
    // 일요일 시작 그리드 — 캘린더 탭 MonthGrid와 동일한 규칙.
    final leadingBlanks = firstOfMonth.weekday % 7;
    final memberCount = room.members.length;

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
              childAspectRatio: 0.8,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final date = DateTime(focusedMonth.year, focusedMonth.month, day);
              final key = dateKey(date);
              final isToday = _isSameDay(date, today);
              final availableUids = room.dates[key] ?? const [];
              final availableCount = availableUids.length;
              final isMeAvailable = availableUids.contains(myUid);
              final isFull = memberCount > 0 && availableCount == memberCount;
              final ratio = memberCount > 0 ? availableCount / memberCount : 0;

              final Color bgColor;
              if (isFull) {
                bgColor = AppColors.protoStepLabel.withValues(alpha: 0.85);
              } else if (availableCount > 0) {
                bgColor = AppColors.protoStepLabel
                    .withValues(alpha: 0.12 + 0.35 * ratio);
              } else {
                bgColor = Colors.transparent;
              }

              return InkWell(
                onTap: () => onDateToggle(key),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: isToday || isMeAvailable ? 1.5 : 0,
                      color: isToday
                          ? AppColors.protoButtonBg
                          : isMeAvailable
                              ? AppColors.protoRadioSelectedBorder
                              : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: AppTypography.caption.copyWith(
                          fontWeight:
                              isToday || isFull ? FontWeight.w700 : FontWeight.w500,
                          color: isFull
                              ? Colors.white
                              : isToday
                                  ? AppColors.protoStepLabel
                                  : AppColors.protoCardText,
                        ),
                      ),
                      const SizedBox(height: 1),
                      SizedBox(
                        height: 11,
                        child: availableCount == 0
                            ? null
                            : Text(
                                '$availableCount/$memberCount명',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: isFull
                                      ? Colors.white
                                      : AppColors.protoCardSelectedText,
                                ),
                              ),
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
