import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/couple_relationship.dart';

/// 타임라인형 뷰의 이별·재회 이력 항목 1개.
///
/// haruchip_app.html에는 이별/재회 이력을 나열하는 화면이 별도로 없어서
/// (§5/§6 예외 — 새 컬러 팔레트는 만들지 않고, 커플룸(589~639줄)의 핑크
/// 톤(`protoCouple*`)만 그대로 가져와 카드 레이아웃을 구성했다.
///
/// 삭제 버튼은 두지 않는다 — CLAUDE.md §7-1은 이별 후 30일 유예 뒤 자동
/// 정리라고 정하고 있고, 삭제류 액션 UI는 이 화면 담당 범위 밖이다.
class ReunionTimelineTile extends StatelessWidget {
  const ReunionTimelineTile({super.key, required this.period});

  final ReunionPeriod period;

  String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final reunited = period.reuniteDate != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.protoCoupleBgMuted, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.heart_broken_rounded,
                size: 16,
                color: AppColors.protoCoupleTextStrong,
              ),
              const SizedBox(width: 6),
              Text(
                '이별 ${_formatDate(period.breakupDate)}',
                style: AppTypography.cardLabel.copyWith(
                  color: AppColors.protoHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 16,
                color: reunited
                    ? AppColors.protoCoupleTextStrong
                    : AppColors.protoSubtitle,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  reunited
                      ? '재회 ${_formatDate(period.reuniteDate!)} · 이별 기간 ${period.length.inDays}일'
                      : '아직 재회하지 않았어요',
                  style: AppTypography.caption.copyWith(
                    color: reunited
                        ? AppColors.protoCoupleText
                        : AppColors.protoSubtitle,
                  ),
                ),
              ),
            ],
          ),
          if (!reunited && period.isPendingDeletion) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '30일 유예 기간이 지나 자동으로 정리될 예정이에요',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
