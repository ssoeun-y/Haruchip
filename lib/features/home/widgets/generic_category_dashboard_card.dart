import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../onboarding/models/onboarding_category.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';

/// 대시보드 "범용 카테고리" 카드 — CLAUDE.md §8(대시보드 카테고리 카드).
///
/// haruchip_app.html 411~434줄 `renderGenericCategoryCard()`를 그대로
/// 포팅한다(§5/§6): 카테고리 이모지 + 제목 + 항목별 D-day 행. 커플/시험/
/// 생일/반려동물처럼 전용 카드가 없는 카테고리(솔로/군대/계획 등)가
/// 이 카드로 대체된다.
///
/// 원본의 `renderGenericCategoryCard`는 카테고리 종류(ddayDate/
/// dischargeDate/plans)에 따라 분기했지만, 우리 쪽은 모든 카테고리가
/// 이미 `PlanItem` 리스트(`planItemsByCategoryProvider(key)`)로 통일돼
/// 있어 분기 없이 항목 리스트를 그대로 순회한다 — 이게 원본의 여러
/// 분기를 하나로 정리한 의도적인 차이다(로직 담당자 provider 스펙에
/// 맞춘 것).
class GenericCategoryDashboardCard extends StatelessWidget {
  const GenericCategoryDashboardCard({
    super.key,
    required this.category,
    required this.items,
  });

  final OnboardingCategory category;
  final List<PlanItem> items;

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
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(category.emoji, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Text(
                category.labelKo,
                style: AppTypography.cardLabel.copyWith(
                  color: AppColors.protoHeading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '아직 등록된 항목이 없어요',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
            )
          else
            for (final item in items)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.protoCardSelectedBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        dDayLabel(item.date),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoStepLabel,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
