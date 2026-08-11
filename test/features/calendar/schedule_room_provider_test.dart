import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/calendar/models/schedule_room.dart';
import 'package:haruchip/features/calendar/providers/schedule_room_provider.dart';

void main() {
  group('scheduleRoomsProvider', () {
    test('초기 상태는 mock 방 목록이다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rooms = container.read(scheduleRoomsProvider);
      expect(rooms, isNotEmpty);
      expect(rooms.first.id, 'room-1');
    });

    test('toggleAvailability: 없으면 추가, 있으면 제거한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(scheduleRoomsProvider.notifier);

      notifier.toggleAvailability('room-1', '2026-08-15', '하루');
      var room =
          container.read(scheduleRoomsProvider).firstWhere((r) => r.id == 'room-1');
      expect(room.dates['2026-08-15'], contains('하루'));

      notifier.toggleAvailability('room-1', '2026-08-15', '하루');
      room = container
          .read(scheduleRoomsProvider)
          .firstWhere((r) => r.id == 'room-1');
      expect(room.dates['2026-08-15'], isNot(contains('하루')));
    });

    test('toggleAvailability는 다른 방 상태를 건드리지 않는다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(scheduleRoomsProvider.notifier);
      final before = container
          .read(scheduleRoomsProvider)
          .firstWhere((r) => r.id == 'room-2');

      notifier.toggleAvailability('room-1', '2026-08-15', '하루');

      final after = container
          .read(scheduleRoomsProvider)
          .firstWhere((r) => r.id == 'room-2');
      expect(after.dates, before.dates);
    });

    test('confirmDate: 해당 방의 confirmedDate만 설정한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(scheduleRoomsProvider.notifier);

      notifier.confirmDate('room-1', '2026-08-14');

      final room = container
          .read(scheduleRoomsProvider)
          .firstWhere((r) => r.id == 'room-1');
      expect(room.confirmedDate, '2026-08-14');
    });

    test('초기 mock 방에는 §4 settlement.payments 값이 채워져 있다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final rooms = container.read(scheduleRoomsProvider);
      final room1 = rooms.firstWhere((r) => r.id == 'room-1');
      final room2 = rooms.firstWhere((r) => r.id == 'room-2');

      expect(room1.payments, {'하루': 60000, '서연': 40000});
      expect(room1.settlementConfirmedAt, isNull);
      expect(room2.payments, {'팀장님': 45000});
    });

    test('updatePayments: 해당 방의 payments만 갱신한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(scheduleRoomsProvider.notifier);

      notifier.updatePayments('room-1', {'하루': 70000});

      final room1 = container
          .read(scheduleRoomsProvider)
          .firstWhere((r) => r.id == 'room-1');
      final room2 = container
          .read(scheduleRoomsProvider)
          .firstWhere((r) => r.id == 'room-2');
      expect(room1.payments, {'하루': 70000});
      expect(room2.payments, {'팀장님': 45000}); // 다른 방은 영향 없음
    });

    test('recordSettlementConfirmation: settlementConfirmedAt만 채우고 '
        'payments는 그대로 둔다(§7-6 확정 후 재계산 허용)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(scheduleRoomsProvider.notifier);

      notifier.recordSettlementConfirmation('room-1');
      final confirmedRoom = container
          .read(scheduleRoomsProvider)
          .firstWhere((r) => r.id == 'room-1');
      expect(confirmedRoom.settlementConfirmedAt, isNotNull);
      expect(confirmedRoom.payments, {'하루': 60000, '서연': 40000});

      // 확정 후에도 재계산(payments 변경)이 막히지 않아야 한다.
      notifier.updatePayments('room-1', {'하루': 80000, '서연': 40000});
      final recalculated = container
          .read(scheduleRoomsProvider)
          .firstWhere((r) => r.id == 'room-1');
      expect(recalculated.payments, {'하루': 80000, '서연': 40000});
      expect(recalculated.settlementConfirmedAt, isNotNull);
    });
  });

  group('bestDateFor', () {
    test('가장 많은 인원이 겹치는 날짜와 인원수를 반환한다', () {
      const room = ScheduleRoom(
        id: 'r',
        name: '테스트 방',
        inviteCode: 'CODE',
        members: [],
        dates: {
          '2026-08-13': ['a', 'b'],
          '2026-08-14': ['a', 'b', 'c'],
        },
      );

      final result = bestDateFor(room);

      expect(result.date, '2026-08-14');
      expect(result.count, 3);
    });

    test('동률이면 날짜 오름차순으로 첫 번째를 반환한다', () {
      const room = ScheduleRoom(
        id: 'r',
        name: '테스트 방',
        inviteCode: 'CODE',
        members: [],
        dates: {
          '2026-08-20': ['a', 'b'],
          '2026-08-14': ['a', 'b'],
        },
      );

      final result = bestDateFor(room);

      expect(result.date, '2026-08-14');
      expect(result.count, 2);
    });

    test('겹치는 날짜가 없으면 date는 null, count는 0이다', () {
      const room = ScheduleRoom(
        id: 'r',
        name: '테스트 방',
        inviteCode: 'CODE',
        members: [],
        dates: {},
      );

      final result = bestDateFor(room);

      expect(result.date, isNull);
      expect(result.count, 0);
    });
  });
}
