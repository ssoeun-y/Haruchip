import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/onboarding_category.dart';

/// 온보딩 카테고리 선택 화면의 카드 1개.
///
/// 탭할 때마다 선택/해제가 토글되는 다중 선택 카드. 그룹(감성형/실용형)에
/// 따라 선택 시 액센트 컬러가 달라진다.
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

  Color get _accent => category.group == CategoryGroup.emotional
      ? AppColors.emotionalAccent
      : AppColors.practicalAccent;

  Color get _accentMuted => category.group == CategoryGroup.emotional
      ? AppColors.emotionalAccentMuted
      : AppColors.practicalAccentMuted;

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
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? _accentMuted : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _accent : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    category.icon,
                    size: 28,
                    color: selected ? _accent : AppColors.textSecondary,
                  ),
                  if (selected)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: _accent,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                category.labelKo,
                textAlign: TextAlign.center,
                style: AppTypography.cardLabel.copyWith(
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
