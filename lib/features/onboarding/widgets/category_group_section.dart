import 'package:flutter/material.dart';

import '../../../design_system/typography.dart';
import '../models/onboarding_category.dart';
import 'category_selection_card.dart';

/// "감성형" / "실용형" 그룹 헤더 + 해당 그룹 카테고리 카드 목록.
class CategoryGroupSection extends StatelessWidget {
  const CategoryGroupSection({
    super.key,
    required this.title,
    required this.description,
    required this.categories,
    required this.selectedKeys,
    required this.onToggle,
  });

  final String title;
  final String description;
  final List<OnboardingCategory> categories;
  final Set<String> selectedKeys;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.heading2),
        const SizedBox(height: 4),
        Text(description, style: AppTypography.bodyMuted),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final category in categories)
              CategorySelectionCard(
                category: category,
                selected: selectedKeys.contains(category.key),
                onTap: () => onToggle(category.key),
              ),
          ],
        ),
      ],
    );
  }
}
