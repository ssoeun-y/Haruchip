import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';

/// 대시보드 반려동물 카드 — CLAUDE.md §8(대시보드 카테고리 카드).
///
/// haruchip_app.html 379~392줄 "PET CARD" 마크업을 그대로 재현한다
/// (§5/§6): 🐾 아이콘 + "반려동물 기록" + 반려동물 이름(부제) + 우측
/// "D+n일째" 배지. 원본은 첫 반려동물 하나만 보여준다 — 이 카드도
/// `planItemsByCategoryProvider('pet')`의 **첫 항목**만 쓴다(카드 자체는
/// "+ 추가" 버튼이 원본에 없다).
///
/// [item]이 null이면(아직 pet 항목이 없으면) 원본에 없는 빈 상태 문구를
/// 대신 보여준다 — 다른 카드들과 톤을 맞추기 위한 최소한의 보강이다.
/// 카운트업 일수는 `daysSince()`(로직 담당자 구현)로 계산한다.
class PetDashboardCard extends StatelessWidget {
  const PetDashboardCard({super.key, required this.item});

  final PlanItem? item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.protoCardSelectedBg, width: 2),
      ),
      child: Row(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '반려동물 기록',
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
                Text(
                  item?.title ?? '아직 등록된 반려동물이 없어요',
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.protoStepLabel,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (item != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.protoCardSelectedBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'D+${daysSince(item!.date)}일째',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoCardSelectedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
