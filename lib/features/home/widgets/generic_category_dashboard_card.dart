import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../categories/models/category.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';
import 'add_category_item_dialog.dart';

/// 대시보드 "범용 카테고리" 카드 — CLAUDE.md §8(대시보드 카테고리 카드).
///
/// haruchip_app.html 411~434줄 `renderGenericCategoryCard()`를 그대로
/// 포팅한다(§5/§6): 카테고리 이모지 + 제목 + 항목별 D-day 행. 커플/시험/
/// 생일/반려동물처럼 전용 카드가 없는 카테고리(솔로/군대/계획 등)가
/// 이 카드로 대체된다.
///
/// 카테고리 & 디데이 커스텀 4단계: 다중 인스턴스 지원을 위해 [category]가
/// 온보딩 타입([OnboardingCategory])이 아니라 사용자가 만든 [Category]
/// 인스턴스를 직접 받는다 — 같은 categoryKey라도 인스턴스별로 다른 이름/
/// 아이콘/색과 서로 다른 항목 목록을 보여줄 수 있다
/// (`planItemsByCategoryInstanceProvider(category.id)`가 [items]를 채운다).
///
/// 헤더 우측에 "+ 추가" 아이콘 버튼을 추가해 [showAddCategoryItemDialog]를
/// 이 인스턴스([category.id])에 귀속해서 연다(exam/birthday 카드와 같은
/// 패턴).
class GenericCategoryDashboardCard extends StatelessWidget {
  const GenericCategoryDashboardCard({
    super.key,
    required this.category,
    required this.items,
  });

  final Category category;
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
          // 배경 사진(§6 사진 업로드, §5 감성형 자유도) — 설정된 인스턴스만
          // 헤더 위에 배너로 보여준다. 실용형 카테고리는 애초에 이 필드를
          // 만들 UI가 없어 항상 null이라 자연히 노출되지 않는다.
          if (category.backgroundImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                category.backgroundImageUrl!,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
          ],
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
              Expanded(
                child: Text(
                  category.name,
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
              ),
              InkWell(
                onTap: () => showAddCategoryItemDialog(
                  context,
                  categoryKey: category.categoryKey,
                  categoryInstanceId: category.id,
                ),
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
                        displayLabel(item),
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
