import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../models/category.dart';

/// 사용자가 만든 카테고리 인스턴스 전체 목록.
///
/// 온보딩 "카테고리 선택(다중)" 단계는 여전히 `categorySelectionProvider`
/// (타입 Set)로 어떤 종류를 쓸지 고르지만, 실제로 대시보드에 카드가 뜨려면
/// 이 목록에 [Category] 인스턴스가 있어야 한다 — 온보딩 완료 시
/// [CategoryListNotifier.seedFromKeys]로 선택된 타입마다 기본 인스턴스를
/// 1개씩 만들어 채운다(온보딩 완료 화면 담당).
///
/// "카테고리는 태그 개념 — 동일 카테고리 다중 인스턴스 항상 허용"
/// (CLAUDE.md §5)이므로 [addCategory]에 categoryKey 중복 제한이 없다 —
/// 대시보드 "+ 새 카테고리 추가하기"에서 같은 타입을 몇 번이든 추가할
/// 수 있다.
class CategoryListNotifier extends Notifier<List<Category>> {
  @override
  List<Category> build() => const <Category>[];

  Category addCategory({
    required String categoryKey,
    required String name,
    required String emoji,
    required String colorHex,
  }) {
    final category = Category(
      id: 'cat-${DateTime.now().microsecondsSinceEpoch}',
      categoryKey: categoryKey,
      name: name,
      emoji: emoji,
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );
    state = [...state, category];
    return category;
  }

  /// 온보딩에서 고른 카테고리 타입([keys])마다 기본값(라벨=이름,
  /// 이모지=타입 이모지, 색=무료 프리셋 첫 번째)으로 인스턴스를 하나씩
  /// 만든다. 이미 해당 타입 인스턴스가 하나라도 있으면 건너뛴다 — 온보딩
  /// 완료 화면이 재진입돼도 중복 생성되지 않게.
  void seedFromKeys(
    Iterable<({String key, String labelKo, String emoji})> types,
  ) {
    final existingKeys = state.map((c) => c.categoryKey).toSet();
    final seeded = <Category>[];
    for (final type in types) {
      if (existingKeys.contains(type.key)) continue;
      seeded.add(
        Category(
          id: 'cat-${DateTime.now().microsecondsSinceEpoch}-${type.key}',
          categoryKey: type.key,
          name: type.labelKo,
          emoji: type.emoji,
          colorHex: colorToHex(AppColors.kFreeColorPresets.first),
          createdAt: DateTime.now(),
        ),
      );
    }
    if (seeded.isNotEmpty) {
      state = [...state, ...seeded];
    }
  }

  void removeCategory(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}

final categoryListProvider =
    NotifierProvider<CategoryListNotifier, List<Category>>(
  CategoryListNotifier.new,
);

/// categoryKey별로 필터링한 인스턴스 목록 — 전용 카드(커플/시험/생일/
/// 반려동물)가 "이 타입 인스턴스가 존재하는가"를 판단할 때 쓴다.
final categoriesOfKeyProvider =
    Provider.family<List<Category>, String>((ref, categoryKey) {
  return ref
      .watch(categoryListProvider)
      .where((c) => c.categoryKey == categoryKey)
      .toList();
});

/// 전용 카드 노출 조건 — 기존 `categorySelectionProvider.contains(key)`를
/// 대체한다. 인스턴스가 1개 이상 있어야 카드가 뜬다.
final hasCategoryOfKeyProvider = Provider.family<bool, String>((ref, key) {
  return ref.watch(categoriesOfKeyProvider(key)).isNotEmpty;
});
