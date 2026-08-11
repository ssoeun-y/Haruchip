/// 하루칩 커플 도메인 모델 (CLAUDE.md §7-1 재회, §7-2 기념일).
///
/// NOTE: [AnniversaryMilestone]은 재회/기념일 로직과 밀접해 이 파일에 함께
/// 정의한다(별도 anniversary.dart를 만들지 않았다) — providers/couple_provider.dart의
/// `upcomingAnniversariesProvider`가 반환하는 타입이 바로 이 클래스다.
library;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 이별 ~ 재회 사이 한 기간.
///
/// [reuniteDate]가 null이면 아직 재회하지 않은(= 현재 이별 중인) 상태를 뜻한다.
class ReunionPeriod {
  const ReunionPeriod({
    required this.breakupDate,
    this.reuniteDate,
  });

  final DateTime breakupDate;
  final DateTime? reuniteDate;

  /// 이별 기간 길이. 아직 재회하지 않았으면 오늘 날짜 기준으로 계산한다.
  /// CLAUDE.md §7-1 "총 연애일수 = (오늘 − 처음 만난 날) − Σ(이별 기간)"에 쓰인다.
  Duration get length {
    final end = reuniteDate ?? DateTime.now();
    return _dateOnly(end).difference(_dateOnly(breakupDate));
  }

  /// 재회하지 않은 채로 30일이 지났는지 판단하는 순수 계산.
  ///
  /// CLAUDE.md §7-1 "이별 시 소프트 삭제 → 30일 보관 → ... 경과 시 영구 삭제"의
  /// 상태 판단용 getter일 뿐 — 이 getter는 실제로 아무것도 삭제하지 않는다.
  /// 실제 영구삭제 실행은 CLAUDE.md §5(사람 확인 필요) 때문에 이번 범위 밖이다.
  bool get isPendingDeletion => reuniteDate == null && length.inDays > 30;

  ReunionPeriod copyWith({DateTime? breakupDate, DateTime? reuniteDate}) {
    return ReunionPeriod(
      breakupDate: breakupDate ?? this.breakupDate,
      reuniteDate: reuniteDate ?? this.reuniteDate,
    );
  }
}

/// 커플 관계 전체 상태. CLAUDE.md §4 `coupleRooms`의 클라이언트 측 표현.
class CoupleRelationship {
  const CoupleRelationship({
    required this.startDate,
    required this.partnerName,
    required this.partnerIcon,
    this.reunions = const [],
  });

  final DateTime startDate;
  final String partnerName;
  final String partnerIcon;

  /// 이별→재회 이력. 최신 이벤트가 리스트의 마지막 원소다.
  final List<ReunionPeriod> reunions;

  CoupleRelationship copyWith({
    DateTime? startDate,
    String? partnerName,
    String? partnerIcon,
    List<ReunionPeriod>? reunions,
  }) {
    return CoupleRelationship(
      startDate: startDate ?? this.startDate,
      partnerName: partnerName ?? this.partnerName,
      partnerIcon: partnerIcon ?? this.partnerIcon,
      reunions: reunions ?? this.reunions,
    );
  }
}

/// CLAUDE.md §7-2 기념일 한 건 — `upcomingAnniversariesProvider`가 반환하는 타입.
class AnniversaryMilestone {
  const AnniversaryMilestone({
    required this.label,
    required this.date,
    required this.dDay,
  });

  /// 예: '100일', '1주년'
  final String label;
  final DateTime date;

  /// 오늘부터 [date]까지 남은 일수(항상 0 이상 — 이미 지난 기념일은 이 목록에
  /// 포함하지 않는다).
  final int dDay;
}
