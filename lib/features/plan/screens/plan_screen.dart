import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../providers/plan_provider.dart';
import '../widgets/add_plan_item_dialog.dart';
import '../widgets/kanban_board.dart';
import '../widgets/plan_item_card.dart';

/// 계획/업무/학업/시험/군대 D-day 리스트 화면 — 실용형 카테고리(§5).
///
/// 상단 "+ 추가" 버튼으로 [AddPlanItemDialog]를 열고, 항목 카드를 D-day
/// 오름차순(provider가 항상 정렬 유지)으로 나열한다. 동일 카테고리를
/// 여러 개 추가하는 것을 막지 않는다(§5 다중 인스턴스 허용).
///
/// "리스트"/"칸반" 뷰모드 토글(핸드오프 문서 §5.7)을 추가로 제공한다.
/// 칸반 뷰는 `categoryKey == 'plan'` 항목만 [KanbanBoard]에 넘겨
/// 렌더링한다 — 다른 categoryKey(시험/학업/군대/업무) 항목은 칸반 뷰에서는
/// 보이지 않는 의도된 동작이다.
///
/// 실용형 규칙(§5)에 따라 컬러+폰트만 제한하고 레이아웃은 고정한다 —
/// 스티커/애니메이션 같은 감성형 전용 컴포넌트는 쓰지 않는다.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

enum _PlanViewMode { list, kanban }

class _PlanScreenState extends ConsumerState<PlanScreen> {
  _PlanViewMode _mode = _PlanViewMode.list;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(planListProvider);

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '계획 D-day',
                          style: AppTypography.heading1.copyWith(
                            color: AppColors.protoHeading,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '업무 · 시험 · 계획 · 학업 · 군대를 한 곳에서 관리해요',
                          style: AppTypography.bodyMuted.copyWith(
                            color: AppColors.protoSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => AddPlanItemDialog.show(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.protoButtonBg,
                      foregroundColor: AppColors.protoButtonText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('+ 추가'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ViewModeToggle(
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: 16),
              if (_mode == _PlanViewMode.list) ...[
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        '아직 등록된 항목이 없어요',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoSubtitle,
                        ),
                      ),
                    ),
                  )
                else
                  for (final item in items) PlanItemCard(item: item),
              ] else
                KanbanBoard(
                  items: items
                      .where((item) => item.categoryKey == 'plan')
                      .toList(),
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

  final _PlanViewMode mode;
  final ValueChanged<_PlanViewMode> onChanged;

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
              label: '리스트',
              selected: mode == _PlanViewMode.list,
              onTap: () => onChanged(_PlanViewMode.list),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: '칸반',
              selected: mode == _PlanViewMode.kanban,
              onTap: () => onChanged(_PlanViewMode.kanban),
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
