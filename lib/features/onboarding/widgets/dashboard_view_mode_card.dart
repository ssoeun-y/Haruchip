import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/dashboard_view_mode_option.dart';

/// 온보딩 "대시보드 보기 방식 선택" 화면의 라디오형 카드 1개.
///
/// haruchip_app.html `onboardingStep === 3` 분기의 라디오 라벨 마크업을
/// 그대로 재현한다(§5/§6):
/// ```html
/// <label class="flex items-center p-4 rounded-2xl border-2 ...">
///   <input type="radio"> <!-- 라디오, 선택 시 노란색 채움 -->
///   <div class="ml-3">
///     <span class="font-bold text-gray-900 block">...</span>
///     <span class="text-xs text-gray-500">...</span>
///   </div>
/// </label>
/// ```
/// 원본과 달리 라디오가 오른쪽이 아니라 **왼쪽**에 오고, 제목/설명은 선택
/// 여부와 무관하게 항상 같은 색·굵기로 고정된다(원본 HTML이 이렇게
/// 하드코딩돼 있다). 이 화면만 선택 테두리 색이 카테고리 카드와 다르다
/// (`protoRadioSelectedBorder` — yellow-300).
class DashboardViewModeCard extends StatelessWidget {
  const DashboardViewModeCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final DashboardViewModeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${option.labelKo} 뷰모드',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.protoCardSelectedBg : AppColors.protoCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.protoRadioSelectedBorder
                  : AppColors.protoCardBorder,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: selected
                    ? AppColors.protoRadioAccent
                    : AppColors.protoRadioUnselected,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.labelKo,
                      style: AppTypography.cardLabel.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.protoHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
