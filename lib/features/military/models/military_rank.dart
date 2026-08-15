import 'package:flutter/foundation.dart';

/// 군종 — 핸드오프 문서(카테고리&디데이 §5.3) 신규 규정 데이터.
///
/// [MilitaryService.branch]가 참조한다. 병장 구간(전역까지 잔여 기간)만
/// 군종별로 다르고(육군/해병 4개월, 해군 6개월, 공군 7개월), 그 앞
/// 진급 시점(이병→일병→상병→병장, 2/8/14개월차)은 군종 공통이다.
enum MilitaryBranch {
  army,
  marines,
  navy,
  airForce;

  String get labelKo => switch (this) {
        MilitaryBranch.army => '육군',
        MilitaryBranch.marines => '해병대',
        MilitaryBranch.navy => '해군',
        MilitaryBranch.airForce => '공군',
      };
}

/// 군종별 총 복무기간(개월) — §5.3.
const Map<MilitaryBranch, int> totalServiceMonths = {
  MilitaryBranch.army: 18,
  MilitaryBranch.marines: 18,
  MilitaryBranch.navy: 20,
  MilitaryBranch.airForce: 21,
};

const int monthsToPrivateFirstClass = 2; // 이병 → 일병
const int monthsToCorporal = 8; // 일병 → 상병
const int monthsToSergeant = 14; // 상병 → 병장(이후는 전역까지 병장 구간)

/// 계급 — 이병/일병/상병/병장(장교·부사관 등 특수 케이스는 범위 밖, §5.3).
enum MilitaryRank {
  private,
  privateFirstClass,
  corporal,
  sergeant;

  String get labelKo => switch (this) {
        MilitaryRank.private => '이병',
        MilitaryRank.privateFirstClass => '일병',
        MilitaryRank.corporal => '상병',
        MilitaryRank.sergeant => '병장',
      };
}

/// [date]에 [months]개월을 더한다. 말일을 넘어가면(예: 1/31 + 1개월)
/// 해당 월의 마지막 날로 보정한다 — `DateTime(year, month + 1, day)`를
/// 그대로 쓰면 다음 달로 밀려버리는 걸 막기 위함.
DateTime _addMonths(DateTime date, int months) {
  final totalMonths = date.month - 1 + months;
  final year = date.year + totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > daysInMonth ? daysInMonth : date.day;
  return DateTime(year, month, day);
}

/// 진급 시점 1건 — [rank]가 시작되는 날짜.
@immutable
class RankMilestone {
  const RankMilestone({required this.rank, required this.startDate});

  final MilitaryRank rank;
  final DateTime startDate;
}

/// [enlistDate] 기준 이병→일병→상병→병장 진급 시작일 목록(군종 공통
/// 규정, §5.3). 병장은 14개월차에 시작해 전역일까지 이어진다 — 별도
/// 종료일을 두지 않는다("병장 구간: 전역까지 잔여 기간 전부").
List<RankMilestone> rankMilestones(DateTime enlistDate) {
  return [
    RankMilestone(rank: MilitaryRank.private, startDate: enlistDate),
    RankMilestone(
      rank: MilitaryRank.privateFirstClass,
      startDate: _addMonths(enlistDate, monthsToPrivateFirstClass),
    ),
    RankMilestone(
      rank: MilitaryRank.corporal,
      startDate: _addMonths(enlistDate, monthsToCorporal),
    ),
    RankMilestone(
      rank: MilitaryRank.sergeant,
      startDate: _addMonths(enlistDate, monthsToSergeant),
    ),
  ];
}

/// [today](기본값 오늘) 시점의 현재 계급. 입대 전이면 이병으로 clamp.
MilitaryRank currentRank(DateTime enlistDate, {DateTime? today}) {
  final now = today ?? DateTime.now();
  var rank = MilitaryRank.private;
  for (final milestone in rankMilestones(enlistDate)) {
    if (!now.isBefore(milestone.startDate)) {
      rank = milestone.rank;
    }
  }
  return rank;
}

/// 다음 진급 시점 — 이미 병장이면(더 이상 진급 없음, §5.3) null.
RankMilestone? nextRankMilestone(DateTime enlistDate, {DateTime? today}) {
  final now = today ?? DateTime.now();
  for (final milestone in rankMilestones(enlistDate)) {
    if (now.isBefore(milestone.startDate)) return milestone;
  }
  return null;
}

/// 군종 기본 전역 예정일(입대일 + 총 복무기간) — 설정 다이얼로그가 군종을
/// 고르면 이 값으로 전역일 입력을 미리 채운다. 휴가·연장복무 등 예외가
/// 있을 수 있어 사용자가 이후에도 전역일을 직접 수정할 수 있게 강제하지
/// 않는다(그대로 편집 가능한 필드로 남겨둠).
DateTime defaultDischargeDate(DateTime enlistDate, MilitaryBranch branch) {
  return _addMonths(enlistDate, totalServiceMonths[branch]!);
}
