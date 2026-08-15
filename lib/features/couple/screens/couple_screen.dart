import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/couple_relationship.dart';
import '../providers/couple_provider.dart';
import '../widgets/anniversary_list_tile.dart';
import '../widgets/breakup_reunite_dialog.dart';
import '../widgets/couple_summary_card.dart';
import '../widgets/reunion_timeline_tile.dart';

/// 커플 화면 — CLAUDE.md §7-1(재회 로직), §7-2(기념일), §8(커플 방).
///
/// 요약형(총 연애일수 D+n 카드 + 재회 후 D+n, 있으면) / 타임라인형(이별·
/// 재회 이력 리스트) 두 뷰를 토글로 전환하고, 다가오는 기념일 리스트와
/// "이별 기록"/"재회 기록" 버튼을 제공한다.
///
/// haruchip_app.html에는 이 화면과 정확히 같은 요약/타임라인 토글이
/// 없다(§5/§6 예외) — 대시보드 뷰모드 필터 바(300~307줄, `bg-gray-100`
/// pill 토글)와 커플룸(589~639줄)의 핑크 톤(`protoCouple*`)만 그대로
/// 재사용해 구성했다. 아바타 매칭 애니메이션·공동 꾸미기(가상의 방)는
/// 별도 커플룸 화면 담당 영역이라 여기서는 다루지 않는다.
///
/// 삭제류 액션(재회 영구삭제 등)은 넣지 않는다 — 로직 담당자도 그 함수를
/// 만들지 않는다(§4 다섯 칸 ④).
class CoupleScreen extends ConsumerStatefulWidget {
  const CoupleScreen({super.key});

  @override
  ConsumerState<CoupleScreen> createState() => _CoupleScreenState();
}

enum _CoupleViewMode { summary, timeline }

class _CoupleScreenState extends ConsumerState<CoupleScreen> {
  _CoupleViewMode _mode = _CoupleViewMode.summary;

  Future<void> _handleBreakup() async {
    final picked = await BreakupReuniteDialog.show(
      context,
      mode: BreakupReuniteDialogMode.breakup,
    );
    if (picked == null || !mounted) return;
    final ok = ref.read(coupleProvider.notifier).addBreakup(picked);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이전 날짜 이후만 선택 가능해요')),
      );
    }
  }

  Future<void> _handleReunite() async {
    final picked = await BreakupReuniteDialog.show(
      context,
      mode: BreakupReuniteDialogMode.reunite,
    );
    if (picked == null || !mounted) return;
    final ok = ref.read(coupleProvider.notifier).addReunite(picked);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이전 날짜 이후만 선택 가능해요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final relationship = ref.watch(coupleProvider);
    final totalDays = ref.watch(totalDaysTogetherProvider);
    final isOnBreak = ref.watch(isCurrentlyOnBreakProvider);
    final daysSinceReunite = ref.watch(daysSinceReuniteProvider);
    final anniversaries = ref.watch(upcomingAnniversariesProvider);

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '우리의 기록',
                style: AppTypography.heading1.copyWith(
                  color: AppColors.protoHeading,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${relationship.partnerIcon} ${relationship.partnerName}와(과)의 연애 기록',
                style: AppTypography.bodyMuted.copyWith(
                  color: AppColors.protoCoupleText,
                ),
              ),
              const SizedBox(height: 20),
              _ViewModeToggle(
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: 16),
              if (_mode == _CoupleViewMode.summary)
                CoupleSummaryCard(
                  partnerName: relationship.partnerName,
                  partnerIcon: relationship.partnerIcon,
                  totalDays: totalDays,
                  isOnBreak: isOnBreak,
                  daysSinceReunite: daysSinceReunite,
                )
              else
                _TimelineList(reunions: relationship.reunions),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: AppColors.protoCoupleTextStrong,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '다가오는 기념일',
                    style: AppTypography.cardLabel.copyWith(
                      color: AppColors.protoHeading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (anniversaries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '다가오는 기념일이 없어요',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoSubtitle,
                    ),
                  ),
                )
              else
                for (final m in anniversaries) AnniversaryListTile(milestone: m),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleBreakup,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.protoCoupleTextStrong,
                        side: const BorderSide(
                          color: AppColors.protoCoupleBgMuted,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('이별 기록'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleReunite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.protoButtonBg,
                        foregroundColor: AppColors.protoButtonText,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('재회 기록'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({required this.mode, required this.onChanged});

  final _CoupleViewMode mode;
  final ValueChanged<_CoupleViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.protoCardBorder,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: '요약형',
              selected: mode == _CoupleViewMode.summary,
              onTap: () => onChanged(_CoupleViewMode.summary),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: '타임라인형',
              selected: mode == _CoupleViewMode.timeline,
              onTap: () => onChanged(_CoupleViewMode.timeline),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.protoCardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? AppColors.protoHeading : AppColors.protoSubtitle,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.reunions});

  final List<ReunionPeriod> reunions;

  @override
  Widget build(BuildContext context) {
    if (reunions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.protoCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.protoCardBorder, width: 2),
        ),
        child: Center(
          child: Text(
            '아직 이별/재회 이력이 없어요',
            style: AppTypography.caption.copyWith(
              color: AppColors.protoSubtitle,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final r in reunions) ReunionTimelineTile(period: r),
      ],
    );
  }
}
