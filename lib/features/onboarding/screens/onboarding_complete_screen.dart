import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../home/screens/main_shell_screen.dart';

/// 온보딩 플로우의 "완료" 단계 — 새로 추가하는 마지막 화면.
///
/// 전체 온보딩 순서(CLAUDE.md §8):
/// 스플래시 → 권한요청 → 로그인 → 카테고리 선택(다중) → 대시보드 뷰모드 →
/// **완료** → (메인 셸)
///
/// haruchip_app.html `renderOnboardingHTML()`의 마지막 `else` 분기
/// (243~258줄)를 그대로 재현한다(§5/§6): 🎉 원형 아이콘 + "설정이
/// 완료되었습니다!" 헤드라인 + 부제 + 팁 박스(💡 두 줄) + "이제
/// 시작하겠습니다 ✨" 버튼.
///
/// 원본은 이 버튼으로 `currentScreen = 'main'`으로 전환한다 — 우리 쪽
/// 메인 화면은 [MainShellScreen](대시보드/캘린더/일정·정산방/우리의방
/// 4탭 셸)이다. [onFinish]를 넘기면(주로 테스트) 그 콜백을 대신 호출하고,
/// 넘기지 않으면 [MainShellScreen]으로 실제 이동한다(다른 온보딩 화면들과
/// 동일한 패턴). 이 화면부터는 온보딩을 다시 push로 쌓지 않도록
/// `pushReplacement`를 쓴다 — 메인 화면 진입 후 뒤로가기로 온보딩으로
/// 돌아가지 않게 하기 위해서다.
class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key, this.onFinish});

  /// 온보딩을 마칠 때 호출된다.
  final VoidCallback? onFinish;

  void _handleFinish(BuildContext context) {
    if (onFinish != null) {
      onFinish!();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        // 원본 `bg-yellow-200 rounded-full` — 개별 yellow-200
                        // 토큰이 없어 카드 선택 테두리색(yellow-300)보다 옅은
                        // protoCardSelectedBg(yellow-50)가 아니라, 좀 더
                        // 진한 protoRadioSelectedBorder(yellow-300)로
                        // 근사한다(최종 보고에 색상 갭으로 남긴다).
                        color: AppColors.protoRadioSelectedBorder,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🎉', style: TextStyle(fontSize: 36)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '설정이 완료되었습니다!',
                      textAlign: TextAlign.center,
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.protoHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '구글/네이버 캘린더 연동 및 위젯 가이드가 준비되었어요. '
                      '이제 하루칩의 모든 기능을 만나보세요.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMuted.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.protoCardSelectedBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.protoCardBorder,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 팁:',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.protoCardSelectedText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• 상단 설정 버튼에서 언제든지 카테고리를 추가하거나 '
                            '수정할 수 있습니다.',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.protoCardSelectedText,
                            ),
                          ),
                          Text(
                            '• 캘린더 탭에서 친구들과 그룹 일정을 조율하고 '
                            '정산해보세요!',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.protoCardSelectedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomCta(onPressed: () => _handleFinish(context)),
          ],
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.protoButtonBg,
              foregroundColor: AppColors.protoButtonText,
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              '이제 시작하겠습니다 ✨',
              style: AppTypography.button.copyWith(
                color: AppColors.protoButtonText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
