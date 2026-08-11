import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../onboarding/data/onboarding_categories.dart';
import '../../onboarding/providers/category_selection_provider.dart';

/// "카테고리 추가하기" 모달 — CLAUDE.md §5("+ 새 카테고리 추가하기" 진입점),
/// §8(대시보드 명세).
///
/// haruchip_app.html 436~466줄 `openAddCategoryModal()`/
/// `addCategoryToDashboard()`를 그대로 재현한다(§5/§6): 아직 선택하지 않은
/// 카테고리만 2열 그리드로 보여주고, 탭하면 `categorySelectionProvider`에
/// 추가한다(온보딩과 같은 provider를 그대로 재사용 — 대시보드에 노출되는
/// 카드 여부가 이 Set 하나로 결정되므로).
///
/// CLAUDE.md 공통 UI 모달 닫기 규칙(X 버튼 / 하단 닫기 버튼 / 배경 클릭)을
/// 모두 지원한다.
Future<void> showAddCategoryDashboardModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _AddCategoryDashboardModal(),
  );
}

class _AddCategoryDashboardModal extends ConsumerWidget {
  const _AddCategoryDashboardModal();

  void _handleAdd(
    BuildContext context,
    WidgetRef ref,
    String key,
    String label,
  ) {
    ref.read(categorySelectionProvider.notifier).toggle(key);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text("✨ '$label' 카테고리가 추가되었습니다!")),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(categorySelectionProvider);
    final available =
        kOnboardingCategories.where((c) => !selected.contains(c.key)).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.protoCardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '카테고리 추가하기',
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.protoSubtitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (available.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    '이미 모든 카테고리를 사용 중이에요 🎉',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoSubtitle,
                    ),
                  ),
                ),
              )
            else ...[
              Text(
                '대시보드에 추가할 카테고리를 선택하세요',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  for (final category in available)
                    InkWell(
                      onTap: () => _handleAdd(
                        context,
                        ref,
                        category.key,
                        category.labelKo,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.protoCardBorder,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.labelKo,
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.protoCardText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
