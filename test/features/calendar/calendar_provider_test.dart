import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/calendar/providers/calendar_provider.dart';

void main() {
  group('calendarSelectionProvider', () {
    test('초기 상태는 오늘이 focusedMonth/selectedDate로 잡혀 있다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final now = DateTime.now();
      final focused = container.read(selectedMonthProvider);
      final selected = container.read(selectedDateProvider);

      expect(focused.year, now.year);
      expect(focused.month, now.month);
      expect(focused.day, 1);
      expect(selected, isNotNull);
      expect(selected!.day, now.day);
    });

    test('selectDate 호출 시 선택 날짜가 바뀐다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarSelectionProvider.notifier);

      notifier.selectDate(DateTime(2026, 8, 20));

      expect(container.read(selectedDateProvider), DateTime(2026, 8, 20));
    });

    test('nextMonth/previousMonth 호출 시 focusedMonth가 이동하고 selectedDate는 초기화된다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarSelectionProvider.notifier);
      notifier.changeMonth(DateTime(2026, 8, 1));

      notifier.nextMonth();
      expect(container.read(selectedMonthProvider), DateTime(2026, 9, 1));
      expect(container.read(selectedDateProvider), isNull);

      notifier.previousMonth();
      expect(container.read(selectedMonthProvider), DateTime(2026, 8, 1));
    });
  });

  group('eventsForDateProvider', () {
    test('mock 데이터 중 해당 날짜의 이벤트만 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final events =
          container.read(eventsForDateProvider(DateTime(2026, 8, 14)));

      expect(events, hasLength(1));
      expect(events.single.title, '민수와 데이트');
    });

    test('일정이 없는 날짜는 빈 리스트를 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final events =
          container.read(eventsForDateProvider(DateTime(2099, 1, 1)));

      expect(events, isEmpty);
    });
  });
}
