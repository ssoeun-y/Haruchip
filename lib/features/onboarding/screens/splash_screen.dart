import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import 'login_screen.dart';

/// 온보딩 플로우의 "스플래시" 단계 — 새로 추가하는 첫 화면.
///
/// 전체 온보딩 순서(CLAUDE.md §8):
/// **스플래시** → 권한요청 → 로그인 → 카테고리 선택(다중) → 대시보드
/// 뷰모드 → 위젯 안내
///
/// haruchip_app.html `renderOnboardingHTML()`의 `onboardingStep === 1`
/// 분기(194~201줄)를 그대로 재현한다(§5/§6): 노란 그라디언트 배경 +
/// 🌻 아이콘 박스 + "스마트 디데이 & 일정 관리" 배지 + 헤드라인/부제 +
/// "시작하기" 버튼. 권한요청 단계는 네이티브 권한 다이얼로그가 필요해
/// 이 담당자 범위 밖이다 — 이 화면은 곧바로 로그인 화면으로 이동한다.
///
/// [onNext]를 넘기면(주로 테스트) 그 콜백을 대신 호출하고, 넘기지 않으면
/// 다음 단계인 [LoginScreen]으로 실제 이동한다(다른 온보딩 화면들과 동일한
/// 패턴).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onNext});

  /// 다음 단계(로그인)로 넘어갈 때 호출된다.
  final VoidCallback? onNext;

  void _handleStart(BuildContext context) {
    if (onNext != null) {
      onNext!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        // 원본 `bg-gradient-to-b from-yellow-50 to-white` 재현.
        // yellow-50에 대응하는 개별 토큰이 없어 카드 선택 배경 톤과 같은
        // protoCardSelectedBg(yellow-50)를 그대로 재사용한다.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.protoCardSelectedBg, AppColors.protoBackground],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.protoButtonBg,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text('🌻', style: TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.protoCardSelectedBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '스마트 디데이 & 일정 관리',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoCardSelectedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '소중한 날들을 더 특별하게,\n하루칩과 함께 시작해요',
                  textAlign: TextAlign.center,
                  style: AppTypography.heading1.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '커플, 시험, 생일, 군대, 반려동물까지 모든 디데이를 '
                  '한눈에 관리하세요.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMuted.copyWith(
                    color: AppColors.protoSubtitle,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _handleStart(context),
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
                      '시작하기',
                      style: AppTypography.button.copyWith(
                        color: AppColors.protoButtonText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
