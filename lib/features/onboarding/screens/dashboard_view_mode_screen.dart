import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../data/dashboard_view_mode_options.dart';
import '../providers/dashboard_view_mode_provider.dart';
import '../widgets/dashboard_view_mode_card.dart';
import 'onboarding_complete_screen.dart';

/// 온보딩 플로우의 "대시보드 뷰모드" 단계.
///
/// 전체 온보딩 순서(CLAUDE.md §8, 재배선 반영):
/// 스플래시 → 권한요청 → 로그인 → 카테고리 선택(다중) →
/// **대시보드 뷰모드** → 완료화면 → 메인셸
///
/// haruchip_app.html `renderOnboardingHTML()`의 `onboardingStep === 3`
/// 분기를 그대로 재현한다(§5/§6). 원본엔 상단 진행바가 없고 대신
/// "STEP 2/3" 라벨만 있다.
///
/// 카테고리 선택/캘린더 연동 선택과 달리 이건 단일 선택(라디오형)이라
/// 하나를 반드시 골라야 다음 단계로 진행할 수 있다. [onNext]를 넘기면
/// (주로 테스트) 그 콜백을 대신 호출하고, 넘기지 않으면 다음 단계인
/// [OnboardingCompleteScreen]으로 실제 이동한다.
///
/// NOTE: 이전에는 다음 단계가 [WidgetGuideScreen](위젯 안내)이었지만,
/// 온보딩 재배선(스플래시 → 로그인 → 카테고리선택 → 대시보드뷰모드 →
/// 완료화면 → 메인셸)에 따라 캘린더연동/위젯안내 두 단계는 온보딩
/// 흐름에서 빠지고 설정 화면 용도로 재활용된다 — 이 화면의 다음 단계는
/// 이제 [OnboardingCompleteScreen]이다.
class DashboardViewModeScreen extends ConsumerWidget {
  const DashboardViewModeScreen({super.key, this.onNext});

  /// 다음 단계(완료화면)로 넘어갈 때 호출된다.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKey = ref.watch(dashboardViewModeProvider);
    final canProceed = ref.watch(canProceedFromDashboardViewModeProvider);

    void handleSelect(String key) {
      ref.read(dashboardViewModeProvider.notifier).select(key);
    }

    void handleNext() {
      if (!canProceed) return;
      if (onNext != null) {
        onNext!();
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingCompleteScreen()),
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
                      'STEP 2/3',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.protoStepLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '대시보드 보기 방식 선택',
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.protoHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '메인 화면에서 정보를 어떤 형태로 확인할까요?',
                      style: AppTypography.bodyMuted.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final option in kDashboardViewModeOptions) ...[
                      DashboardViewModeCard(
                        option: option,
                        selected: selectedKey == option.key,
                        onTap: () => handleSelect(option.key),
                      ),
                      const SizedBox(height: 12),
                    ],
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
              enabled ? '다음으로' : '뷰모드를 선택해주세요',
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
