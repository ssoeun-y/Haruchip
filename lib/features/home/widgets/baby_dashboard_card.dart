import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../categories/data/baby_milestones.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';
import 'add_category_item_dialog.dart';

/// 대시보드 아기 카드 — CLAUDE.md §5.5.
///
/// `pet_dashboard_card.dart`/`exam_dashboard_card.dart`와 같은 흰
/// 카드+radius 24+아이콘+제목+배지 톤을 따른다. [items]의 **첫 항목**을
/// 아기의 출생/입양일 대표 기록으로 삼아 `babyAgeLabel()`로 "N일째 ·
/// M개월 D일째"를 표시하고, `kBabyMilestones` 중 D-14 이내로 다가온
/// 마일스톤이 있으면 배너 하나를 추가로 보여준다.
class BabyDashboardCard extends StatelessWidget {
  const BabyDashboardCard({super.key, required this.items});

  final List<PlanItem> items;

  /// D-14 이내(이미 지났으면 제외)로 가장 가까운 마일스톤 하나.
  ({({int day, String label, List<String> checklist}) milestone, int daysLeft})?
      _nearestMilestone(DateTime birthDate) {
    final elapsed = daysSince(birthDate);
    ({({int day, String label, List<String> checklist}) milestone, int daysLeft})?
        nearest;
    for (final milestone in kBabyMilestones) {
      final daysLeft = milestone.day - elapsed;
      if (daysLeft < 0 || daysLeft > 14) continue;
      if (nearest == null || daysLeft < nearest.daysLeft) {
        nearest = (milestone: milestone, daysLeft: daysLeft);
      }
    }
    return nearest;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.protoCardSelectedBg, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.protoCardSelectedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('👶', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  items.isEmpty ? '아기 성장 기록' : items.first.title,
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    showAddCategoryItemDialog(context, categoryKey: 'baby'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.protoCardSelectedBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ 추가',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoStepLabel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              '아직 등록된 아기 기록이 없어요',
              style: AppTypography.caption.copyWith(
                color: AppColors.protoSubtitle,
              ),
            )
          else ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.protoCardSelectedBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                babyAgeLabel(items.first.date),
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoCardSelectedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Builder(
              builder: (context) {
                final nearest = _nearestMilestone(items.first.date);
                if (nearest == null) return const SizedBox.shrink();
                final milestone = nearest.milestone;
                final daysLeft = nearest.daysLeft;
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.protoCoupleBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🎉 ${milestone.label}까지 D-$daysLeft · 준비물: '
                      '${milestone.checklist.join(', ')}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoCoupleTextStrong,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (items.length > 1) ...[
              const SizedBox(height: 10),
              for (final item in items.skip(1))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.protoCardText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        babyAgeLabel(item.date),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoStepLabel,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
