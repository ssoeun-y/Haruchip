import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../home/widgets/add_category_item_dialog.dart';
import '../providers/plan_provider.dart';
import '../widgets/kanban_board.dart';
import '../widgets/plan_item_card.dart';

/// 계획/업무/학업/시험/군대 D-day 리스트 화면 — 실용형 카테고리(§5).
///
/// 상단 "+ 추가" 버튼은 대시보드 카드들과 같은 [showAddCategoryItemDialog]를
/// `categoryKey: 'plan'` 고정으로 연다 — 원래 이 화면 전용으로 따로 있던
/// `add_plan_item_dialog.dart`(제목/날짜/카테고리 칩만 지원하던 더 얕은
/// 버전)를 없애고 캘린더 탭의 "+ 일정 추가"와 같은 통합 다이얼로그로
/// 합쳤다 — UI는 하나, 진입점마다 고정 categoryKey만 다르게 넘기는
/// 방식. 항목 카드를 D-day 오름차순(provider가 항상 정렬 유지)으로
/// 나열한다. 동일 카테고리를 여러 개 추가하는 것을 막지 않는다(§5 다중
/// 인스턴스 허용).
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
    final predictedItems = ref.watch(predictedPlanItemsProvider);

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
                    onPressed: () => showAddCategoryItemDialog(
                      context,
                      categoryKey: 'plan',
                    ),
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
                // "예측 리스트업" 섹션 — 디데이 추가 화면 명세 §3:
                // repeat.type != none 이거나 isPredicted == true인 항목은
                // 아래 전체 목록과 별개로 항상 여기 노출한다(additive —
                // 전체 목록에서 제외하지 않는다).
                if (predictedItems.isNotEmpty) ...[
                  Text(
                    '🔮 예측 리스트업',
                    style: AppTypography.cardLabel.copyWith(
                      color: AppColors.protoHeading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '반복되거나 자동 예측된 일정이에요',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoSubtitle,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final item in predictedItems) PlanItemCard(item: item),
                  const SizedBox(height: 20),
                  Text(
                    '전체 목록',
                    style: AppTypography.cardLabel.copyWith(
                      color: AppColors.protoHeading,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
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
