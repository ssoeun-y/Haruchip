import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/calendar_integration_option.dart';

/// 온보딩 "캘린더 연동 선택" 화면의 행(row) 카드 1개.
///
/// 탭할 때마다 연동 여부가 토글되는 다중 선택 카드.
class CalendarIntegrationCard extends StatelessWidget {
  const CalendarIntegrationCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CalendarIntegrationOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${option.labelKo} 연동',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryMuted : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 26,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.labelKo, style: AppTypography.cardLabel),
                    const SizedBox(height: 2),
                    Text(option.description, style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: selected ? AppColors.primary : AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
