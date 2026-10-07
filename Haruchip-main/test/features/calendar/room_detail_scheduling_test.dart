import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/calendar/providers/schedule_room_provider.dart';
import 'package:haruchip/features/calendar/screens/schedule_room_detail_screen.dart';
import 'package:haruchip/features/calendar/widgets/room_availability_month_grid.dart';
import 'package:haruchip/features/plan/models/plan_item.dart';
import 'package:haruchip/features/plan/providers/plan_provider.dart';

/// 모임방 상세 — 일정 조율(임시 선택→저장, 방장 확정, 댓글)과 공유 캘린더.
/// 화면에 1초 주기 타이머가 있어 pumpAndSettle 대신 시간을 직접 흘린다.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<ProviderContainer> _open(WidgetTester tester, String roomId, {Size size = const Size(430, 2400)}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final c = ProviderContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: ScheduleRoomDetailScreen(roomId: roomId)),
    ),
  );
  await _settle(tester);
  addTearDown(() => tester.pumpWidget(const SizedBox())); // 타이머 정리
  return c;
}

Future<void> _goAvailabilityTab(WidgetTester tester) async {
  await tester.tap(find.text('일정 조율'));
  await _settle(tester);
}

String _key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  testWidgets('날짜를 눌러도 바로 저장되지 않고, [저장하기]를 눌러야 반영된다', (tester) async {
    final c = await _open(tester, 'room-1');
    await _goAvailabilityTab(tester);

    final now = DateTime.now();
    final day20 = _key(DateTime(now.year, now.month, 20));
    await tester.tap(find.descendant(of: find.byType(RoomAvailabilityMonthGrid), matching: find.text('20')));
    await _settle(tester);

    expect(find.text('저장하지 않은 변경이 있어요'), findsOneWidget);
    expect(c.read(scheduleRoomsProvider).firstWhere((r) => r.id == 'room-1').dates[day20], isNull,
        reason: '저장 전에는 멤버들에게 반영되지 않는다');

    await tester.tap(find.text('저장하기'));
    await _settle(tester);

    expect(c.read(scheduleRoomsProvider).firstWhere((r) => r.id == 'room-1').dates[day20], ['하루']);
    expect(find.text('저장하지 않은 변경이 있어요'), findsNothing);
  });

  testWidgets('[변경 취소]를 누르면 임시 선택이 사라진다', (tester) async {
    final c = await _open(tester, 'room-1');
    await _goAvailabilityTab(tester);
    final before = c.read(scheduleRoomsProvider).firstWhere((r) => r.id == 'room-1').dates;

    await tester.tap(find.descendant(of: find.byType(RoomAvailabilityMonthGrid), matching: find.text('21')));
    await _settle(tester);
    await tester.tap(find.text('변경 취소'));
    await _settle(tester);

    expect(find.text('저장하지 않은 변경이 있어요'), findsNothing);
    expect(c.read(scheduleRoomsProvider).firstWhere((r) => r.id == 'room-1').dates, before);
  });

  testWidgets('방장은 겹치는 날짜에서 확인 후 확정하고, 다른 날로 바꿔도 일정이 중복되지 않는다', (tester) async {
    final c = await _open(tester, 'room-1');
    await _goAvailabilityTab(tester);

    expect(find.text('겹치는 날짜'), findsOneWidget);
    expect(find.text('전원 가능'), findsOneWidget); // 10/1 4/4명

    await tester.ensureVisible(find.text('이 날짜로 확정').first);
    await tester.tap(find.text('이 날짜로 확정').first);
    await _settle(tester);
    expect(find.text('확정하기'), findsOneWidget, reason: '바로 확정하지 않고 확인 창');
    await tester.tap(find.text('확정하기'));
    await _settle(tester);

    var room = c.read(scheduleRoomsProvider).firstWhere((r) => r.id == 'room-1');
    expect(room.confirmedDate, '2026-10-01');
    expect(find.text('확정됨 ✓'), findsOneWidget);

    // 다른 날짜로 재확정
    await tester.ensureVisible(find.text('이 날짜로 확정').first);
    await tester.tap(find.text('이 날짜로 확정').first);
    await _settle(tester);
    await tester.tap(find.text('확정하기'));
    await _settle(tester);

    room = c.read(scheduleRoomsProvider).firstWhere((r) => r.id == 'room-1');
    expect(room.confirmedDate, '2026-10-05');
    final meetingPlans = c.read(planListProvider).where((p) => p.id == 'plan-room-room-1-meeting').toList();
    expect(meetingPlans.single.date, DateTime(2026, 10, 5));
    expect(room.events.where((e) => e.id == 'room-ev-room-1-meeting').single.date, DateTime(2026, 10, 5));
  });

  testWidgets('방장이 아니면 확정 버튼이 없다', (tester) async {
    await _open(tester, 'room-2');
    await _goAvailabilityTab(tester);

    expect(find.text('겹치는 날짜'), findsOneWidget);
    expect(find.text('이 날짜로 확정'), findsNothing);
    expect(find.text('날짜 확정은 방장이 해요'), findsOneWidget);
  });

  testWidgets('확정된 모임에 댓글을 달 수 있고, 빈 댓글은 막힌다', (tester) async {
    final c = await _open(tester, 'room-1');
    c.read(scheduleRoomsProvider.notifier).confirmDate('room-1', '2026-10-01');
    await _goAvailabilityTab(tester);

    expect(find.textContaining('모임 확정:'), findsOneWidget);

    await tester.ensureVisible(find.text('등록'));
    await tester.tap(find.text('등록'));
    await _settle(tester);
    expect(find.text('댓글 내용을 입력해주세요.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, '예: 참석! 7시쯤 도착해요'), '참석! 조금 늦어요');
    await tester.tap(find.text('등록'));
    await _settle(tester);

    final comments = c.read(scheduleRoomsProvider).firstWhere((r) => r.id == 'room-1').meetingComments;
    expect(comments.single.content, '참석! 조금 늦어요');
    expect(comments.single.authorName, '하루');
    expect(find.textContaining('참석! 조금 늦어요'), findsOneWidget);
  });

  testWidgets('메인 캘린더에서 이 방에 공유한 일정이 공유 캘린더에 보인다', (tester) async {
    final c = await _open(tester, 'room-1');
    final today = DateTime.now();
    c.read(planListProvider.notifier).addItem(PlanItem(
          id: 'p-shared',
          title: '메인에서 만든 저녁 약속',
          date: DateTime(today.year, today.month, today.day),
          categoryKey: 'plan',
          roomLinks: const ['room-1'],
        ));
    await _settle(tester);

    expect(find.text('메인에서 만든 저녁 약속'), findsOneWidget);
    expect(find.text('내 캘린더'), findsOneWidget);
  });

  testWidgets('좁은 화면(344)에서 일정 조율 탭 전체(저장 버튼·확정 카드·겹치는 날짜)가 넘치지 않는다', (tester) async {
    final c = await _open(tester, 'room-1', size: const Size(344, 2400));
    c.read(scheduleRoomsProvider.notifier).confirmDate('room-1', '2026-10-05');
    await _goAvailabilityTab(tester);
    await tester.tap(find.descendant(of: find.byType(RoomAvailabilityMonthGrid), matching: find.text('22')));
    await _settle(tester);

    expect(find.text('변경 취소'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('넓은 화면에서 공유 캘린더와 일정 조율 달력이 같은 폭·같은 칸 높이', (tester) async {
    await _open(tester, 'room-1', size: const Size(1600, 2400));

    final sharedGrid = find.byType(GridView).first;
    final sharedSize = tester.getSize(sharedGrid);
    expect(sharedSize.height, 6 * kRoomGridCellHeight + 5 * 4); // 42칸 고정 6줄, 간격 4

    await _goAvailabilityTab(tester);
    final availCard = tester.getSize(find.byType(RoomAvailabilityMonthGrid));

    expect(sharedSize.width, lessThanOrEqualTo(kRoomContentMaxWidth));
    expect(availCard.width, lessThanOrEqualTo(kRoomContentMaxWidth));
    expect(tester.takeException(), isNull);
  });
}
