import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';

/// 대시보드 시험/자격증 카드 — CLAUDE.md §8(대시보드 카테고리 카드).
///
/// haruchip_app.html 332~355줄 "EXAM CARD" 마크업을 그대로 재현한다
/// (§5/§6): 📚 아이콘 + "시험 / 자격증 디데이" + "+ 추가" 버튼 + 항목별
/// D-day 배지(+ "연동" 링크).
///
/// [items]는 `planItemsByCategoryProvider('exam')`을 그대로 넘겨받고,
/// D-day 문자열은 로직 담당자의 `dDayLabel()`을 그대로 쓴다. "+ 추가"와
/// 항목별 "연동"은 둘 다 2부(항목 추가 모달/캘린더 등록 팝업) 범위라
/// 지금은 [onAdd]/[onSyncItem] 콜백을 [DashboardScreen]에서 스낵바
/// 스텁으로 연결한다.
class ExamDashboardCard extends StatelessWidget {
  const ExamDashboardCard({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onSyncItem,
  });

  final List<PlanItem> items;
  final VoidCallback onAdd;
  final ValueChanged<PlanItem> onSyncItem;

  @override
  Widget build(BuildContext context) {
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
                child: const Text('📚', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '시험 / 자격증 디데이',
                      style: AppTypography.cardLabel.copyWith(
                        color: AppColors.protoHeading,
                      ),
                    ),
                    Text(
                      '목표 달성 프로젝트',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.protoStepLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.protoCardSelectedBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ 추가',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoStepLabel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '아직 등록된 항목이 없어요',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
            )
          else
            for (final item in items) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.protoCardSelectedBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoCardText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => onSyncItem(item),
                      child: Text(
                        '연동',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.protoSubtitle,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}
