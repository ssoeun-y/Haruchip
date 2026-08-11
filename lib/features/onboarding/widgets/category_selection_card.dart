import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/onboarding_category.dart';

/// 온보딩 카테고리 선택 화면의 카드 1개.
///
/// haruchip_app.html `onboardingStep === 2`의 카드 마크업을 그대로 재현한다:
/// ```html
/// <div class="p-4 rounded-2xl border-2 ... flex flex-col items-center
///      justify-center space-y-2
///      ${isSelected ? 'border-yellow-400 bg-yellow-50 text-amber-900
///                      font-bold shadow-sm'
///                   : 'border-gray-100 bg-white text-gray-600'}">
///     <span class="text-2xl">${emoji}</span>
///     <span class="text-sm">${label}</span>
/// </div>
/// ```
/// 선택 시 체크 배지 없이 테두리/배경/텍스트 색과 미세한 그림자만으로
/// 선택 상태를 표현한다(§5/§6 프로토타입 재현 규칙).
class CategorySelectionCard extends StatelessWidget {
  const CategorySelectionCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final OnboardingCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${category.labelKo} 카테고리',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.protoCardSelectedBg
                : AppColors.protoCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.protoCardSelectedBorder
                  : AppColors.protoCardBorder,
              width: 2,
            ),
            // 원본의 `shadow-sm`(아주 옅은 회색 그림자) 재현 — 앰버 글로우가
            // 아니라 중립 톤이다.
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                category.labelKo,
                textAlign: TextAlign.center,
                style: AppTypography.cardLabel.copyWith(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? AppColors.protoCardSelectedText
                      : AppColors.protoCardText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
