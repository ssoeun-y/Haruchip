import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_mock_data.dart';
import '../models/schedule_room.dart';

/// 일정 방 목록 상태 (CLAUDE.md §7-5 방 상세 플로우).
class ScheduleRoomListNotifier extends Notifier<List<ScheduleRoom>> {
  @override
  List<ScheduleRoom> build() => mockScheduleRooms;

  /// haruchip_app.html의 toggleAvailability() 포팅: 해당 [date]의 uid
  /// 리스트에 [myUid]가 있으면 제거, 없으면 추가.
  void toggleAvailability(String roomId, String date, String myUid) {
    state = [
      for (final room in state)
        if (room.id == roomId) _toggle(room, date, myUid) else room,
    ];
  }

  ScheduleRoom _toggle(ScheduleRoom room, String date, String myUid) {
    final updatedDates = <String, List<String>>{
      for (final entry in room.dates.entries)
        entry.key: List<String>.from(entry.value),
    };
    final members = updatedDates.putIfAbsent(date, () => []);
    if (members.contains(myUid)) {
      members.remove(myUid);
    } else {
      members.add(myUid);
    }
    return room.copyWith(dates: updatedDates);
  }

  /// CLAUDE.md §7-5 5번: 방의 confirmedDate만 설정한다. 실제 구글 캘린더
  /// 연동 팝업이나 방 목록에서의 제거는 화면 담당자가 UI에서 처리한다 —
  /// 이 메서드는 필드 값 설정만 책임진다.
  void confirmDate(String roomId, String date) {
    state = [
      for (final room in state)
        if (room.id == roomId) room.copyWith(confirmedDate: date) else room,
    ];
  }

  /// 정산에 쓰인 금액(payments)을 갱신한다. §7-6: 확정 후에도 재계산은
  /// 항상 허용되므로, settlementConfirmedAt이 이미 찍혀 있어도 이 메서드
  /// 호출을 막지 않는다.
  void updatePayments(String roomId, Map<String, int> payments) {
    state = [
      for (final room in state)
        if (room.id == roomId) room.copyWith(payments: payments) else room,
    ];
  }

  /// CLAUDE.md §7-6 "확정 시점 = 실제 송금 진행 시점": settlementConfirmedAt만
  /// 기록한다. payments/tx는 그대로 두고 잠그지 않는다 — 확정 후에도 재계산은
  /// 항상 허용된다.
  void recordSettlementConfirmation(String roomId) {
    state = [
      for (final room in state)
        if (room.id == roomId)
          room.copyWith(settlementConfirmedAt: DateTime.now())
        else
          room,
    ];
  }
}

final scheduleRoomsProvider =
    NotifierProvider<ScheduleRoomListNotifier, List<ScheduleRoom>>(
  ScheduleRoomListNotifier.new,
);

/// CLAUDE.md §7-5 3번: 가장 많은 인원이 겹치는 날짜와 인원수.
/// 동률이면 날짜 문자열 오름차순으로 가장 앞선 날짜를 고른다.
/// 겹치는 날짜가 하나도 없으면 (date: null, count: 0).
({String? date, int count}) bestDateFor(ScheduleRoom room) {
  String? bestDate;
  var bestCount = 0;
  final sortedDates = room.dates.keys.toList()..sort();
  for (final date in sortedDates) {
    final count = room.dates[date]!.length;
    if (count > bestCount) {
      bestCount = count;
      bestDate = date;
    }
  }
  return (date: bestDate, count: bestCount);
}
