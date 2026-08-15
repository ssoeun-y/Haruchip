import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../categories/providers/category_provider.dart';
import '../data/onboarding_categories.dart';
import '../providers/category_selection_provider.dart';
import '../widgets/category_selection_card.dart';
import 'dashboard_view_mode_screen.dart';

/// 온보딩 플로우의 "카테고리 선택(다중)" 단계.
///
/// 전체 온보딩 순서(CLAUDE.md §8):
/// 스플래시 → 권한요청 → 로그인 → **카테고리 선택(다중)** → 대시보드
/// 뷰모드 → 완료화면 → 메인셸
///
/// 이 화면은 그중 카테고리 선택 단계만 담당한다. [onNext]를 넘기면
/// (주로 테스트) 그 콜백을 대신 호출하고, 넘기지 않으면 다음 단계인
/// [DashboardViewModeScreen]으로 실제 이동한다.
///
/// NOTE: 이전에는 다음 단계가 캘린더 연동 선택([CalendarIntegrationScreen])
/// 이었지만, 온보딩 재배선에 따라 그 단계는 온보딩 흐름에서 빠지고 설정
/// 화면 용도로 재활용된다 — 이 화면의 다음 단계는 이제
/// [DashboardViewModeScreen]이다.
///
/// haruchip_app.html `renderOnboardingHTML()`의 `onboardingStep === 2`
/// 분기를 그대로 재현한다(§5/§6). 원본엔 상단 진행바가 없고 대신
/// "STEP 1/3" 라벨만 있으며, 카테고리는 감성형/실용형 그룹 구분 없이
/// 2열 그리드로 flat하게 나열된다.
class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key, this.onNext});

  /// 다음 단계(대시보드 뷰모드 선택)로 넘어갈 때 호출된다.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKeys = ref.watch(categorySelectionProvider);
    final canProceed = ref.watch(canProceedFromCategorySelectionProvider);

    void handleToggle(String key) {
      ref.read(categorySelectionProvider.notifier).toggle(key);
    }

    void handleNext() {
      if (!canProceed) return;

      final types = kOnboardingCategories
          .where((c) => selectedKeys.contains(c.key))
          .map((c) => (key: c.key, labelKo: c.labelKo, emoji: c.emoji));
      ref.read(categoryListProvider.notifier).seedFromKeys(types);

      if (onNext != null) {
        onNext!();
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DashboardViewModeScreen()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 1/3',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.protoStepLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '관심 있는 카테고리를 골라주세요',
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.protoHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '나에게 필요한 카테고리를 선택하세요 (중복 선택 가능)',
                      style: AppTypography.bodyMuted.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      // labelKo가 "솔로 / 최애 덕질"처럼 2줄로 감길 수
                      // 있는 카테고리(cat.title 그대로 씀)도 있어, 1.1보다
                      // 낮춰 카드에 세로 여유를 더 준다.
                      childAspectRatio: 0.95,
                      children: [
                        for (final category in kOnboardingCategories)
                          CategorySelectionCard(
                            category: category,
                            selected: selectedKeys.contains(category.key),
                            onTap: () => handleToggle(category.key),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _BottomCta(
              enabled: canProceed,
              onPressed: handleNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.protoButtonBg,
              disabledBackgroundColor: AppColors.surfaceMuted,
              foregroundColor: AppColors.protoButtonText,
              disabledForegroundColor: AppColors.textDisabled,
              // 원본의 `shadow-lg`(뚜렷한 그림자) 재현 — 비활성 상태는
              // 원본에 없는 우리 쪽 정책이라 그림자 없이 눌러둔다.
              elevation: enabled ? 6 : 0,
              shadowColor: Colors.black.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              enabled ? '다음으로' : '카테고리를 1개 이상 선택해주세요',
              style: AppTypography.button.copyWith(
                color: enabled ? AppColors.protoButtonText : AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
