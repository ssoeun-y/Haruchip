import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/plan_item.dart';
import '../providers/plan_provider.dart';

/// D-day 리스트의 항목 카드 1개 — 실용형 카테고리(§5) 전용.
///
/// haruchip_app.html 332~355줄(시험 카드), 419~423줄(plans 리스트 행)
/// 톤을 따른다(§5/§6): 흰 배경 카드 + `bg-yellow-400 text-amber-950
/// rounded-full font-bold` D-day 배지. `protoCardBorder`(gray-100)는
/// html의 `border-yellow-100`과 가장 가까운 기존 토큰을 재사용한 것이다
/// — `design_system/colors.dart`에 정확한 yellow-100 보더 토큰이 아직
/// 없어 새 컬러를 만들지 않고 이 토큰으로 대체했다.
///
/// 실용형 카테고리 규칙(§5)에 따라 스티커/애니메이션 같은 감성형 전용
/// 컴포넌트는 쓰지 않고 레이아웃도 고정한다.
class PlanItemCard extends StatelessWidget {
  const PlanItemCard({super.key, required this.item});

  final PlanItem item;

  /// `add_plan_item_dialog.dart`가 저장하는 대표 categoryKey → 한글 라벨.
  /// 목록에 없는 값(향후 다른 담당자가 추가한 태그 등)은 원문 그대로 보여준다
  /// — categoryKey는 태그 개념(§5)이라 화면에서 값 자체를 막지 않는다.
  static const _categoryLabels = {
    'plan': '계획',
    'exam': '시험',
    'study': '학업',
    'military': '군대',
    'work': '업무',
  };

  String get _categoryLabel => _categoryLabels[item.categoryKey] ?? item.categoryKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.protoCardBorder, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _categoryLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                    if (item.repeat) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· 매년 반복',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoSubtitle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.protoButtonBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              dDayLabel(item.date),
              style: AppTypography.caption.copyWith(
                color: AppColors.protoButtonText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
