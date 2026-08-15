import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/plan/models/plan_item.dart';
import 'package:haruchip/features/plan/providers/plan_provider.dart';

void main() {
  group('planListProvider', () {
    test('초기 상태는 mock 데이터가 날짜 오름차순으로 정렬되어 있다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = container.read(planListProvider);
      expect(items, isNotEmpty);
      for (var i = 1; i < items.length; i++) {
        expect(
          items[i].date.isAfter(items[i - 1].date) ||
              items[i].date.isAtSameMomentAs(items[i - 1].date),
          isTrue,
        );
      }
    });

    test('addItem 후에도 날짜 오름차순 정렬을 유지한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planListProvider.notifier);

      notifier.addItem(PlanItem(
        id: 'new-1',
        title: '가장 이른 일정',
        date: DateTime(2000, 1, 1),
        categoryKey: 'plan',
      ));

      final items = container.read(planListProvider);
      expect(items.first.id, 'new-1');
    });

    test('동일 categoryKey를 가진 항목을 여러 개 추가할 수 있다(태그 개념)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planListProvider.notifier);

      notifier.addItem(PlanItem(
        id: 'exam-a',
        title: '시험 A',
        date: DateTime(2027, 1, 1),
        categoryKey: 'exam',
      ));
      notifier.addItem(PlanItem(
        id: 'exam-b',
        title: '시험 B',
        date: DateTime(2027, 2, 1),
        categoryKey: 'exam',
      ));

      final examItems = container
          .read(planListProvider)
          .where((i) => i.categoryKey == 'exam')
          .toList();
      expect(examItems.length, greaterThanOrEqualTo(2));
    });

    test('removeItem은 해당 id 항목만 제거한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planListProvider.notifier);
      final beforeCount = container.read(planListProvider).length;
      final targetId = container.read(planListProvider).first.id;

      notifier.removeItem(targetId);

      final items = container.read(planListProvider);
      expect(items.length, beforeCount - 1);
      expect(items.any((i) => i.id == targetId), isFalse);
    });
  });

  group('dDayLabel', () {
    test('오늘 날짜는 D-day를 반환한다', () {
      expect(dDayLabel(DateTime.now()), 'D-day');
    });

    test('미래 날짜는 D-n을 반환한다', () {
      final target = DateTime.now().add(const Duration(days: 10));
      expect(dDayLabel(target), 'D-10');
    });

    test('과거 날짜는 D+n을 반환한다', () {
      final target = DateTime.now().subtract(const Duration(days: 5));
      expect(dDayLabel(target), 'D+5');
    });
  });
}
