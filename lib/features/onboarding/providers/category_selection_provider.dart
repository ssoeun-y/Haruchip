import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 온보딩 카테고리 선택(다중) 상태.
///
/// 값은 [OnboardingCategory.key] 집합이다. "카테고리는 태그 개념 — 동일
/// 카테고리 다중 인스턴스 항상 허용"(CLAUDE.md §5)이므로 온보딩 단계에서는
/// 어떤 태그를 쓸지 "종류"만 고르고, 카테고리별 실제 항목(다중 인스턴스)
/// 생성은 대시보드의 "+ 새 카테고리 추가하기"에서 이어진다.
class CategorySelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void toggle(String categoryKey) {
    final next = {...state};
    if (!next.remove(categoryKey)) {
      next.add(categoryKey);
    }
    state = next;
  }

  bool isSelected(String categoryKey) => state.contains(categoryKey);
}

final categorySelectionProvider =
    NotifierProvider<CategorySelectionNotifier, Set<String>>(
  CategorySelectionNotifier.new,
);

/// 최소 1개 이상 선택해야 다음 단계(캘린더 연동 선택)로 진행할 수 있다.
final canProceedFromCategorySelectionProvider = Provider<bool>((ref) {
  return ref.watch(categorySelectionProvider).isNotEmpty;
});
