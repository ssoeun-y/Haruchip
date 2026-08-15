import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../categories/models/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';

String _formatYmd(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

/// 대시보드 생일 카드 — CLAUDE.md §8(대시보드 카테고리 카드).
///
/// haruchip_app.html 357~377줄 "BIRTHDAY CARD" 마크업을 그대로 재현한다
/// (§5/§6): 🎂 아이콘 + "소중한 사람 생일" + "매년 자동 반복 D-Day" +
/// "+ 추가" 버튼 + 항목별(이름 (날짜)) D-day 배지.
///
/// [items]는 `planItemsByCategoryProvider('birthday')`를 그대로 넘겨받고
/// (mock 데이터는 `repeat: true`), D-day 문자열은 `dDayLabel()`을 그대로
/// 쓴다. "+ 추가"는 2부(항목 추가 모달) 범위라 [onAdd] 콜백을
/// [DashboardScreen]에서 스낵바 스텁으로 연결한다.
///
/// 색상 갭: 원본은 이 카드에만 purple 계열(bg-purple-100/text-purple-700,
/// bg-purple-200/text-purple-800, bg-purple-50/40)을 쓰는데
/// `colors.dart`엔 purple 계열 토큰이 전혀 없다. §5가 이 카테고리를
/// "감성형"으로 분류하는 점에 맞춰, 이미 정의된 감성형 공용 액센트
/// (`AppColors.emotionalAccent`/`emotionalAccentMuted`)로 대체했다 —
/// 정확한 보라색 톤은 아니라는 점을 최종 보고에 남긴다.
class BirthdayDashboardCard extends ConsumerWidget {
  const BirthdayDashboardCard({
    super.key,
    required this.items,
    required this.onAdd,
  });

  final List<PlanItem> items;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider);
    Category? categoryFor(PlanItem item) {
      final instanceId = item.categoryInstanceId;
      if (instanceId == null) return null;
      for (final category in categories) {
        if (category.id == instanceId) return category;
      }
      return null;
    }

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
                  color: AppColors.emotionalAccentMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🎂', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '소중한 사람 생일',
                      style: AppTypography.cardLabel.copyWith(
                        color: AppColors.protoHeading,
                      ),
                    ),
                    Text(
                      '매년 자동 반복 D-Day',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.emotionalAccent,
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
                    color: AppColors.emotionalAccentMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ 추가',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.emotionalAccent,
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
            for (final item in items)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emotionalAccentMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${categoryFor(item)?.emoji ?? '🎂'} ${item.title} (${_formatYmd(item.date)})',
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
                        color: AppColors.emotionalAccentMuted,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        dDayLabel(item.date),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.emotionalAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
