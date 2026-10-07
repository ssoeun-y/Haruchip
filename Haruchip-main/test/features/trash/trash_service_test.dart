import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/categories/logic/repeat_rule.dart';
import 'package:haruchip/features/categories/providers/category_provider.dart';
import 'package:haruchip/features/plan/models/plan_item.dart';
import 'package:haruchip/features/plan/providers/plan_provider.dart';
import 'package:haruchip/features/trash/logic/trash_service.dart';
import 'package:haruchip/features/trash/models/trash_item.dart';
import 'package:haruchip/features/trash/providers/trash_provider.dart';
import 'package:haruchip/services/storage/local_store.dart';

ProviderContainer _boot(LocalStore store) {
  final c = ProviderContainer(overrides: [localStoreProvider.overrideWithValue(store)]);
  addTearDown(c.dispose);
  return c;
}

/// 목표 1개 + 캘린더 미러 PlanItem을 가진 카테고리를 만든다.
String _seedGoalCategory(ProviderContainer c) {
  c.read(trashBinProvider.notifier).emptyTrash();
  final cats = c.read(categoryListProvider.notifier);
  final cat = cats.addCategory(categoryKey: 'goal', name: '자기계발', emoji: '🎯', colorHex: '#4F46E5');
  cats.updateCategory(cat.copyWith(metadata: {
    'isInitialized': true,
    'goals': [
      {'id': 'g1', 'title': '토익 900'},
      {'id': 'g2', 'title': '운동'},
    ],
  }));
  c.read(planListProvider.notifier).addItem(
        PlanItem(id: 'g1', title: '토익 900', date: DateTime(2026, 11, 30), categoryKey: 'goal', categoryInstanceId: cat.id),
      );
  return cat.id;
}

void _trashGoal1(ProviderContainer c, String catId) {
  final cat = c.read(categoryListProvider).firstWhere((x) => x.id == catId);
  c.read(trashServiceProvider).trashCategoryEntry(
        type: TrashEntityType.goal,
        category: cat,
        metaKey: 'goals',
        entry: {'id': 'g1', 'title': '토익 900'},
        title: '토익 900',
        mirrorPlanIds: {'g1'},
      );
  // 화면(_saveGoals)이 하는 것처럼 metadata 목록에서도 뺀다.
  c.read(categoryListProvider.notifier).updateCategory(cat.copyWith(metadata: {
    ...cat.metadata!,
    'goals': [
      {'id': 'g2', 'title': '운동'},
    ],
  }));
}

List<String> _goalIds(ProviderContainer c, String catId) =>
    (c.read(categoryListProvider).firstWhere((x) => x.id == catId).metadata!['goals'] as List)
        .map((e) => (e as Map)['id'] as String)
        .toList();

void main() {
  test('removedById는 삭제만 잡고 수정(같은 id)은 잡지 않는다', () {
    final before = [('a', 1), ('b', 2), ('c', 3)];
    final after = [('a', 9), ('c', 3)];
    expect(removedById(before, after, (e) => e.$1), [('b', 2)]);
  });

  test('카테고리 항목 삭제 → 휴지통으로 가고 캘린더 미러 일정도 내려간다', () {
    final c = _boot(InMemoryLocalStore());
    final catId = _seedGoalCategory(c);

    _trashGoal1(c, catId);

    final trash = c.read(trashBinProvider);
    expect(trash.single.entityType, TrashEntityType.goal);
    expect(trash.single.originalTitle, '토익 900');
    expect(trash.single.daysRemaining, 30);
    expect(c.read(planListProvider).any((p) => p.id == 'g1'), isFalse);
  });

  test('복구 → 원래 카테고리 목록과 캘린더 미러가 둘 다 돌아온다', () {
    final c = _boot(InMemoryLocalStore());
    final catId = _seedGoalCategory(c);
    _trashGoal1(c, catId);

    final ok = c.read(trashServiceProvider).restore(c.read(trashBinProvider).single);

    expect(ok, isTrue);
    expect(c.read(trashBinProvider), isEmpty);
    expect(_goalIds(c, catId), ['g1', 'g2']);
    expect(c.read(planListProvider).where((p) => p.id == 'g1').single.categoryInstanceId, catId);
  });

  test('두 번 복구해도 중복으로 들어가지 않는다', () {
    final c = _boot(InMemoryLocalStore());
    final catId = _seedGoalCategory(c);
    _trashGoal1(c, catId);
    final item = c.read(trashBinProvider).single;

    c.read(trashServiceProvider).restore(item);
    c.read(trashBinProvider.notifier).moveToTrash(item); // 같은 항목이 다시 들어온 상황
    c.read(trashServiceProvider).restore(item);

    expect(_goalIds(c, catId), ['g1', 'g2']);
    expect(c.read(planListProvider).where((p) => p.id == 'g1').length, 1);
  });

  test('원래 카테고리가 없어졌으면 복구 실패 + 휴지통에 그대로 남는다', () {
    final c = _boot(InMemoryLocalStore());
    final catId = _seedGoalCategory(c);
    _trashGoal1(c, catId);
    c.read(categoryListProvider.notifier).removeCategory(catId);

    final ok = c.read(trashServiceProvider).restore(c.read(trashBinProvider).single);

    expect(ok, isFalse);
    expect(c.read(trashBinProvider).length, 1);
  });

  test('삭제 → 앱 재시작 → 복구가 그대로 된다', () {
    final store = InMemoryLocalStore();
    final c1 = _boot(store);
    final catId = _seedGoalCategory(c1);
    _trashGoal1(c1, catId);

    final c2 = _boot(store);
    final ok = c2.read(trashServiceProvider).restore(c2.read(trashBinProvider).single);

    expect(ok, isTrue);
    expect(_goalIds(c2, catId), ['g1', 'g2']);
    expect(c2.read(planListProvider).any((p) => p.id == 'g1'), isTrue);
  });

  test('일정(plan) 복구 시 반복/시간 필드가 유실되지 않는다', () {
    final c = _boot(InMemoryLocalStore());
    final plan = PlanItem(
      id: 'p-weekly',
      title: '주간 회의',
      date: DateTime(2026, 10, 12),
      categoryKey: 'plan',
      repeatConfig: const RepeatConfig(type: RepeatType.weekly, weekdays: [1]),
      reminder: EventReminder.before10m,
    );
    final item = TrashItem(
      id: 't-p',
      entityType: TrashEntityType.plan,
      originalTitle: plan.title,
      deletedAt: DateTime.now(),
      originalData: plan.toJson(),
    );
    c.read(trashBinProvider.notifier).moveToTrash(item);

    expect(c.read(trashServiceProvider).restore(item), isTrue);
    final back = c.read(planListProvider).firstWhere((p) => p.id == 'p-weekly');
    expect(back.repeatConfig.type, RepeatType.weekly);
    expect(back.reminder, EventReminder.before10m);
  });

  test('모임방이 없으면 정산/공지 복구는 실패하고 휴지통에 남는다', () {
    final c = _boot(InMemoryLocalStore());
    final item = TrashItem(
      id: 't-n',
      entityType: TrashEntityType.notice,
      originalTitle: '사라진 방 공지',
      deletedAt: DateTime.now(),
      originalData: const {'id': 'n1', 'title': 'x'},
      roomId: 'no-such-room',
    );
    c.read(trashBinProvider.notifier).moveToTrash(item);

    expect(c.read(trashServiceProvider).restore(item), isFalse);
    expect(c.read(trashBinProvider).any((t) => t.id == 't-n'), isTrue);
  });
}
