import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../categories/models/exam_timeline.dart';

String _formatMonthDay(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$m.$d';
}

/// 시험 카테고리 카드에서 [ExamTimelineEntry] 목록을 가로 chip 나열로
/// 보여주는 위젯 — 핸드오프 문서 §5.4 "접수→필기→합격발표→실기→최종합격".
///
/// 시험일([ExamStage.isMainExamDay] true, 필기/실기)은 굵게 + 진한 강조
/// 배경, 행정 일정(접수/합격발표/최종합격)은 연하게 + 옅은 배경으로
/// 구분한다. 오늘보다 과거인 날짜는 흐리게 + 취소선 처리한다.
class ExamTimelineRow extends StatelessWidget {
  const ExamTimelineRow({super.key, required this.entries});

  final List<ExamTimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in sorted)
          _TimelineChip(
            entry: entry,
            isPast: DateTime(
              entry.date.year,
              entry.date.month,
              entry.date.day,
            ).isBefore(todayOnly),
          ),
      ],
    );
  }
}

class _TimelineChip extends StatelessWidget {
  const _TimelineChip({required this.entry, required this.isPast});

  final ExamTimelineEntry entry;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final isMain = entry.stage.isMainExamDay;
    final backgroundColor =
        isMain ? AppColors.protoButtonBg : AppColors.surfaceMuted;
    final textColor =
        isMain ? AppColors.protoButtonText : AppColors.protoSubtitle;

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${entry.stage.labelKo} ${_formatMonthDay(entry.date)}',
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          color: textColor,
          fontWeight: isMain ? FontWeight.w700 : FontWeight.w500,
          decoration: isPast ? TextDecoration.lineThrough : null,
        ),
      ),
    );

    if (!isPast) return chip;
    return Opacity(opacity: 0.5, child: chip);
  }
}
