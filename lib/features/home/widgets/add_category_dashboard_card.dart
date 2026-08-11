import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// 대시보드 "+ 새 카테고리 추가하기" 카드 — CLAUDE.md §5("대시보드에는
/// '+ 새 카테고리 추가하기' 진입점을 항상 유지"), §8(대시보드 명세).
///
/// haruchip_app.html 397~400줄 마크업을 그대로 재현한다(§5/§6): 점선
/// 테두리 + 가운데 정렬된 "+" 아이콘과 문구. 실제 카테고리 추가 모달은
/// 2부 범위라 [onTap]은 [DashboardScreen]에서 스낵바 스텁으로 연결한다
/// — 이 카드(진입점) 자체는 온보딩 이후에도 항상 대시보드에 노출돼야
/// 한다는 §5 규칙을 지키기 위해 카드 표시 여부에 조건을 걸지 않는다.
///
/// 점선 테두리는 Flutter 기본 [BoxDecoration]에 옵션이 없어 `dotted_border`
/// 패키지(`pubspec.yaml`)를 써서 원본의 `border-dashed`를 그대로 재현한다.
class AddCategoryDashboardCard extends StatelessWidget {
  const AddCategoryDashboardCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(24),
        color: AppColors.protoRadioSelectedBorder,
        strokeWidth: 2,
        dashPattern: const [6, 4],
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: AppColors.protoStepLabel,
              ),
              const SizedBox(width: 8),
              Text(
                '새 카테고리 추가하기',
                style: AppTypography.cardLabel.copyWith(
                  color: AppColors.protoStepLabel,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
