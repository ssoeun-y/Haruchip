import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// 대시보드 상단 "인사 카드" — CLAUDE.md §8(대시보드: 인사 + 뷰모드 전환 +
/// 카테고리 카드).
///
/// haruchip_app.html 288~298줄 그라디언트 인사 카드를 그대로 재현한다
/// (§5/§6): 노란 그라디언트 배경 + "오늘 하루도 행복하게 🌻" 배지 +
/// "안녕하세요, {이름}님!" + 부제 + 우측 아바타 이모지 박스.
///
/// 로그인 provider가 아직 없어 유저 이름/아바타는 [DashboardScreen]에서
/// html mock("김하루"/"🌻")을 그대로 넘겨 받는다.
///
/// 색상 갭: 원본은 `from-yellow-300 via-yellow-200 to-amber-100` 3단
/// 그라디언트를 쓰는데, `colors.dart`엔 yellow-300([AppColors.
/// protoRadioSelectedBorder])만 정확히 대응하는 토큰이 있고 yellow-200/
/// amber-100에 대응하는 개별 토큰이 없다. 가장 가까운 기존 토큰
/// (protoButtonBg → protoRadioSelectedBorder → protoCardSelectedBg)
/// 3개로 근사했다 — 정식 브랜드 팔레트가 생기면 교체 대상이다.
class DashboardGreetingCard extends StatelessWidget {
  const DashboardGreetingCard({
    super.key,
    required this.userName,
    required this.avatarEmoji,
  });

  final String userName;
  final String avatarEmoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.protoButtonBg, // yellow-400 근사(원본 yellow-300)
            AppColors.protoRadioSelectedBorder, // yellow-300 정확 대응
            AppColors.protoCardSelectedBg, // yellow-50 근사(원본 amber-100)
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '오늘 하루도 행복하게 🌻',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoCardSelectedText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '안녕하세요, $userName님!',
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.protoButtonText,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '다가오는 기념일과 일정을 확인하세요.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.protoCardSelectedText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.protoCardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(avatarEmoji, style: const TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
  }
}
