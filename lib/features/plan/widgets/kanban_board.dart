import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/plan_item.dart';
import '../providers/plan_provider.dart';

/// 계획 카테고리 칸반 보드(핸드오프 문서 §5.7) — "할일 / 진행중 / 완료"
/// 3개 세로 컬럼. 드래그앤드롭은 범위 밖이라 카드를 탭하면 뜨는 시트에서
/// 상태를 골라 이동한다.
///
/// [items]는 호출부(`PlanScreen`)가 이미 `categoryKey == 'plan'`으로
/// 필터링해서 넘겨준다고 가정 — 이 위젯 안에서 추가 필터링은 하지 않는다.
///
/// 실용형 카테고리(CLAUDE.md §5) 규칙에 따라 컬러+폰트만 제한하고
/// 레이아웃은 고정, 스티커/애니메이션 같은 감성형 전용 컴포넌트는 쓰지
/// 않는다.
class KanbanBoard extends ConsumerWidget {
  const KanbanBoard({super.key, required this.items});

  final List<PlanItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final status in KanbanStatus.values) ...[
            _KanbanColumn(
              status: status,
              items: items.where((i) => i.kanbanStatus == status).toList(),
              onCardTap: (item) => _showMoveSheet(context, ref, item),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

/// 카드를 탭했을 때 뜨는 "OO로 이동" 선택 시트.
///
/// 공통 UI 규칙(CLAUDE.md §8 "모달 닫기")대로 X 버튼 / 하단 "닫기" 버튼 /
/// 배경 클릭(`showModalBottomSheet` 기본 `isDismissible: true`) 3가지를
/// 모두 지원한다.
void _showMoveSheet(BuildContext context, WidgetRef ref, PlanItem item) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.protoCardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.protoHeading,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(sheetContext).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.protoSubtitle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final status in KanbanStatus.values)
              _MoveOptionTile(
                status: status,
                current: item.kanbanStatus == status,
                onTap: item.kanbanStatus == status
                    ? null
                    : () {
                        ref
                            .read(planListProvider.notifier)
                            .updateKanbanStatus(item.id, status);
                        Navigator.of(sheetContext).pop();
                      },
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.protoCardText,
                  side: const BorderSide(
                    color: AppColors.protoCardBorder,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _MoveOptionTile extends StatelessWidget {
  const _MoveOptionTile({
    required this.status,
    required this.current,
    required this.onTap,
  });

  final KanbanStatus status;
  final bool current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: current ? AppColors.protoCardSelectedBg : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: current
                ? AppColors.protoCardSelectedBorder
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${status.labelKo}로 이동',
                style: AppTypography.body.copyWith(
                  color: current
                      ? AppColors.protoCardSelectedText
                      : AppColors.protoCardText,
                  fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (current)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.protoCardSelectedText,
              ),
          ],
        ),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.status,
    required this.items,
    required this.onCardTap,
  });

  final KanbanStatus status;
  final List<PlanItem> items;
  final ValueChanged<PlanItem> onCardTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                status.labelKo,
                style: AppTypography.cardLabel.copyWith(
                  color: AppColors.protoHeading,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.protoCardBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${items.length}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.protoSubtitle,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '항목 없음',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
            )
          else
            for (final item in items)
              _KanbanCard(item: item, onTap: () => onCardTap(item)),
        ],
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({required this.item, required this.onTap});

  final PlanItem item;
  final VoidCallback onTap;

  String? get _deadlineLabel {
    final time = item.deadlineTime;
    if (time == null) return null;
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.protoCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.protoCardBorder, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: priorityColor(item.priority),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.title,
                    style: AppTypography.cardLabel.copyWith(
                      color: AppColors.protoHeading,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.protoButtonBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    dDayLabel(item.date),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoButtonText,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (_deadlineLabel != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _deadlineLabel!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoSubtitle,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
