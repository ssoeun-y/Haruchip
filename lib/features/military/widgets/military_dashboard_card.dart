import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../providers/military_provider.dart';
import 'military_setup_dialog.dart';

/// 대시보드 군대(곰신) 카드 — CLAUDE.md §5.3.
///
/// 다른 대시보드 카드들(`pet_dashboard_card.dart`,
/// `exam_dashboard_card.dart`)과 같은 흰 카드+radius 24+아이콘+제목+배지
/// 톤을 따른다. 파라미터 없이 내부에서 `militaryServiceProvider`/
/// `militaryProgressProvider`/`militaryDischargeDdayProvider`/
/// `militaryLeaveDdayProvider`를 직접 watch한다 — 다른 카드들처럼 상위에서
/// 데이터를 넘겨받지 않는 이유는 이 카드가 단일 [MilitaryService] 상태 하나만
/// 다뤄서 별도 리스트 필터링이 필요 없기 때문이다.
///
/// "설정" 아이콘을 누르면 [showMilitarySetupDialog]로 입대일/전역일/다음
/// 휴가일을 입력·수정한다.
class MilitaryDashboardCard extends ConsumerWidget {
  const MilitaryDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(militaryProgressProvider);
    final dischargeDday = ref.watch(militaryDischargeDdayProvider);
    final leaveDday = ref.watch(militaryLeaveDdayProvider);
    final currentRank = ref.watch(militaryCurrentRankProvider);
    final nextRankDday = ref.watch(militaryNextRankDdayProvider);
    final progressPercent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.protoCardSelectedBg, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.protoCardSelectedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🎖️', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '군대 (곰신)',
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
              ),
              InkWell(
                onTap: () => showMilitarySetupDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 18,
                    color: AppColors.protoSubtitle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.protoButtonBg,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '진급률 $progressPercent%',
            style: AppTypography.caption.copyWith(
              color: AppColors.protoStepLabel,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.protoCardSelectedBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '전역 $dischargeDday',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.protoCardSelectedText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  nextRankDday == null
                      ? '${currentRank.labelKo} (진급 완료)'
                      : '${currentRank.labelKo} · 다음 진급 $nextRankDday',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.protoCardText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (leaveDday != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.protoCoupleBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '휴가까지 $leaveDday',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoCoupleTextStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  '휴가일 미설정',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.protoSubtitle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
