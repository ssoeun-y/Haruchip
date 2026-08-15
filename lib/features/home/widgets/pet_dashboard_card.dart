import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';
import 'add_category_item_dialog.dart';

/// 대시보드 반려동물 카드 — CLAUDE.md §8(대시보드 카테고리 카드).
///
/// haruchip_app.html 379~392줄 "PET CARD" 마크업을 기반으로 하되, 핸드오프
/// 문서 §5.6 "사료/산책/병원예약 반복 알림 D-Day 관리"를 반영해 여러 개의
/// 반려동물/알림 항목을 리스트로 보여준다(원본은 첫 반려동물 하나만
/// 보여줬지만, 다중 항목 요구사항이 생겨 [items] 전체를 순회하도록
/// 확장했다).
///
/// [items]는 `planItemsByCategoryProvider('pet')`(또는 인스턴스별
/// provider)을 그대로 넘겨받는다. 각 행의 배지는 `displayLabel(item)`을
/// 재사용해 항목별 `displayMode`(D-Day/N일째/개월수)를 그대로 존중한다.
/// 헤더 우측 "+ 추가" 버튼은 `generic_category_dashboard_card.dart` 패턴을
/// 따라 [showAddCategoryItemDialog]를 연다.
class PetDashboardCard extends StatelessWidget {
  const PetDashboardCard({super.key, required this.items});

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
                  // 원본 bg-amber-100에 대응하는 개별 토큰이 없어 톤이 가장
                  // 가까운 protoCardSelectedBg(yellow-50)로 근사한다.
                  color: AppColors.protoCardSelectedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🐾', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '반려동물 기록',
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    showAddCategoryItemDialog(context, categoryKey: 'pet'),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 20,
                    color: AppColors.protoStepLabel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '아직 등록된 반려동물이 없어요',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
            )
          else
            for (final item in items)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
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
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.protoCardSelectedBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        displayLabel(item),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoCardSelectedText,
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
