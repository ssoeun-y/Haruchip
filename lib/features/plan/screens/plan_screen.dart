import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../providers/plan_provider.dart';
import '../widgets/add_plan_item_dialog.dart';
import '../widgets/plan_item_card.dart';

/// 계획/업무/학업/시험/군대 D-day 리스트 화면 — 실용형 카테고리(§5).
///
/// 상단 "+ 추가" 버튼으로 [AddPlanItemDialog]를 열고, 항목 카드를 D-day
/// 오름차순(provider가 항상 정렬 유지)으로 나열한다. 동일 카테고리를
/// 여러 개 추가하는 것을 막지 않는다(§5 다중 인스턴스 허용).
///
/// 실용형 규칙(§5)에 따라 컬러+폰트만 제한하고 레이아웃은 고정한다 —
/// 스티커/애니메이션 같은 감성형 전용 컴포넌트는 쓰지 않는다.
class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            ],
          ),
        ),
      ),
    );
  }
}
