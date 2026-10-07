import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/calendar/models/schedule_room.dart';
import 'package:haruchip/features/calendar/widgets/room_availability_month_grid.dart';

/// 일정조율(모임방) 달력이 화면 폭에 비례해 커지지 않는지.
const _room = ScheduleRoom(
  id: 'r1',
  name: '동기 모임',
  inviteCode: 'ABC123',
  members: [
    RoomMember(uid: 'me', name: '나', icon: '🐰'),
    RoomMember(uid: 'u2', name: '친구', icon: '🐻'),
    RoomMember(uid: 'u3', name: '동생', icon: '🐶'),
  ],
  dates: {
    '2026-08-01': ['me', 'u2', 'u3'],
    '2026-08-15': ['me'],
    '2026-08-31': ['u2', 'u3'],
  },
);

Future<Size> _pumpAt(WidgetTester tester, double width) async {
  await tester.binding.setSurfaceSize(Size(width, 1200));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: RoomAvailabilityMonthGrid(
            room: _room,
            // 2026년 8월: 토요일 시작 + 31일 → 6주(가장 긴 달 모양)
            focusedMonth: DateTime(2026, 8, 1),
            myUid: 'me',
            onDateToggle: (_) {},
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: '$width 폭에서 오버플로우');
  return tester.getSize(find.byType(GridView));
}

void main() {
  testWidgets('6주짜리 달도 폭과 무관하게 같은 높이, 넓은 화면에서는 폭 상한', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final sizes = <double, Size>{};
    for (final w in [344.0, 375.0, 430.0, 674.0, 1024.0]) {
      sizes[w] = await _pumpAt(tester, w);
    }

    // 6줄 × 40 + 5 간격 × 2 = 250. 달력 카드 전체 높이 실측: 예전(폭 비례) 375→431, 430→490,
    // 674→751, 1024→1126 / 지금은 모든 폭에서 347.
    for (final s in sizes.values) {
      expect(s.height, 6 * kRoomGridCellHeight + 5 * 2);
    }
    // 폴드 펼침/태블릿에서도 달력 폭은 상한(테두리·여백 제외) 안에 머문다.
    expect(sizes[674]!.width, lessThanOrEqualTo(kRoomGridMaxWidth));
    expect(sizes[1024]!.width, sizes[674]!.width);
  });
}
