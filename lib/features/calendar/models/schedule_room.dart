/// CLAUDE.md §4 `scheduleRooms/{roomId}` 데이터 모델의 클라이언트 측 표현.
library;

const Object _unset = Object();

class RoomMember {
  const RoomMember({
    required this.uid,
    required this.name,
    required this.icon,
  });

  final String uid;
  final String name;
  final String icon;
}

/// 일정 방 하나 (CLAUDE.md §7-5 방 상세 플로우).
///
/// §4 `scheduleRooms/{roomId}.settlement`는 `{ payments, confirmedAt }`
/// 형태지만, 여기서는 별도 클래스로 감싸지 않고 [payments]/
/// [settlementConfirmedAt] 두 필드로 바로 둔다 — [dates]/[confirmedDate]도
/// 이미 같은 방식(중첩 객체 없이 필드 평탄화)이라 스타일을 맞췄다.
class ScheduleRoom {
  const ScheduleRoom({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.members,
    required this.dates,
    this.confirmedDate,
    this.payments = const {},
    this.settlementConfirmedAt,
  });

  final String id;
  final String name;

  /// 1회용 초대코드.
  final String inviteCode;
  final List<RoomMember> members;

  /// key: 'YYYY-MM-DD', value: 그 날짜에 가능하다고 표시한 uid 리스트.
  final Map<String, List<String>> dates;

  /// §7-5 5번: 날짜가 확정되면 채워진다(null이면 아직 미확정).
  final String? confirmedDate;

  /// §4 `settlement.payments` — key: uid(멤버 이름), value: 실제로 낸 금액.
  /// 아직 아무도 입력하지 않았으면 빈 맵.
  final Map<String, int> payments;

  /// §4 `settlement.confirmedAt` — §7-6 "확정 시점 = 실제 송금 진행 시점".
  /// null이면 아직 미확정. 확정 후에도 payments 재계산은 항상 허용되므로
  /// 이 필드가 잠금 역할을 하지 않는다(단순 기록용).
  final DateTime? settlementConfirmedAt;

  ScheduleRoom copyWith({
    String? id,
    String? name,
    String? inviteCode,
    List<RoomMember>? members,
    Map<String, List<String>>? dates,
    Object? confirmedDate = _unset,
    Map<String, int>? payments,
    Object? settlementConfirmedAt = _unset,
  }) {
    return ScheduleRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      members: members ?? this.members,
      dates: dates ?? this.dates,
      confirmedDate: identical(confirmedDate, _unset)
          ? this.confirmedDate
          : confirmedDate as String?,
      payments: payments ?? this.payments,
      settlementConfirmedAt: identical(settlementConfirmedAt, _unset)
          ? this.settlementConfirmedAt
          : settlementConfirmedAt as DateTime?,
    );
  }
}
