import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// 요약형 뷰의 총 연애일수 카드 — CLAUDE.md §7-1.
///
/// haruchip_app.html 597줄의 "D+380일째 💕" 배지와 601~623줄 커플룸 카드의
/// 핑크 톤(`protoCouple*`)을 참고해 요약 카드로 재구성했다(§5/§6). 아바타
/// 매칭 애니메이션 자체는 대시보드/커플룸 담당 영역이라 이 카드에는
/// 넣지 않는다.
class CoupleSummaryCard extends StatelessWidget {
  const CoupleSummaryCard({
    super.key,
    required this.partnerName,
    required this.partnerIcon,
    required this.totalDays,
    required this.isOnBreak,
    required this.daysSinceReunite,
  });

  final String partnerName;
  final String partnerIcon;
  final int totalDays;
  final bool isOnBreak;
  final int? daysSinceReunite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.protoCoupleBg, AppColors.protoCardBg],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.protoCoupleBgMuted, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(partnerIcon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$partnerName와(과) 함께한 시간',
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoCoupleTextStrong,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isOnBreak)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '현재 이별 기간이에요',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Text(
              'D+$totalDays',
              style: AppTypography.heading1.copyWith(
                color: AppColors.protoCoupleTextStrong,
                fontSize: 32,
              ),
            ),
          if (!isOnBreak && daysSinceReunite != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.protoCoupleBgMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '재회 후 D+$daysSinceReunite',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoCoupleTextStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
