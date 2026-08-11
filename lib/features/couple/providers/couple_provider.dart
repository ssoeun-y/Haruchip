import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/couple_mock_data.dart';
import '../models/couple_relationship.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 커플 관계(재회 이력 포함) 상태.
///
/// CLAUDE.md §7-1: 날짜 입력은 이전 날짜 이후로만 선택 가능(역전 방지).
/// [addBreakup]/[addReunite]는 이 규칙을 지키지 못하면 상태를 바꾸지 않고
/// false를 반환한다 — UI 쪽에서 이 반환값으로 에러 토스트 등을 띄우면 된다.
class CoupleNotifier extends Notifier<CoupleRelationship> {
  @override
  CoupleRelationship build() => mockCoupleRelationship;

  /// 이별 기록 추가.
  ///
  /// - [date]가 직전 이벤트(마지막 이별/재회일, 없으면 startDate)보다 이르거나
  ///   같으면 역전 방지로 실패(false).
  /// - 이미 이별 중(마지막 이별기간이 재회 안 된 상태)이면 중복 이별을 막기
  ///   위해 실패(false).
  bool addBreakup(DateTime date) {
    if (!date.isAfter(_lastEventDate())) return false;
    if (state.reunions.isNotEmpty && state.reunions.last.reuniteDate == null) {
      return false;
    }
    state = state.copyWith(
      reunions: [...state.reunions, ReunionPeriod(breakupDate: date)],
    );
    return true;
  }

  /// 재회 기록 추가.
  ///
  /// - [date]가 직전 이벤트보다 이르거나 같으면 역전 방지로 실패(false).
  /// - 현재 이별 중이 아니면(재회할 대상이 없으면) 실패(false).
  bool addReunite(DateTime date) {
    if (!date.isAfter(_lastEventDate())) return false;
    if (state.reunions.isEmpty || state.reunions.last.reuniteDate != null) {
      return false;
    }
    final updated = [...state.reunions];
    updated[updated.length - 1] = updated.last.copyWith(reuniteDate: date);
    state = state.copyWith(reunions: updated);
    return true;
  }

  DateTime _lastEventDate() {
    if (state.reunions.isEmpty) return state.startDate;
    final last = state.reunions.last;
    return last.reuniteDate ?? last.breakupDate;
  }
}

final coupleProvider =
    NotifierProvider<CoupleNotifier, CoupleRelationship>(CoupleNotifier.new);

/// CLAUDE.md §7-1 공식: (오늘 − 처음 만난 날) − Σ(이별 기간).
final totalDaysTogetherProvider = Provider<int>((ref) {
  final couple = ref.watch(coupleProvider);
  final totalDays =
      _dateOnly(DateTime.now()).difference(_dateOnly(couple.startDate)).inDays;
  final breakupDays =
      couple.reunions.fold<int>(0, (sum, r) => sum + r.length.inDays);
  return totalDays - breakupDays;
});

/// 마지막 이별기록이 있고 아직 재회하지 않았으면 true.
final isCurrentlyOnBreakProvider = Provider<bool>((ref) {
  final couple = ref.watch(coupleProvider);
  if (couple.reunions.isEmpty) return false;
  return couple.reunions.last.reuniteDate == null;
});

/// 가장 최근 재회일 기준 오늘까지 일수. 재회 이력이 없으면 null.
final daysSinceReuniteProvider = Provider<int?>((ref) {
  final couple = ref.watch(coupleProvider);
  final reuniteDates = couple.reunions
      .map((r) => r.reuniteDate)
      .whereType<DateTime>()
      .toList();
  if (reuniteDates.isEmpty) return null;
  final mostRecent =
      reuniteDates.reduce((a, b) => a.isAfter(b) ? a : b);
  return _dateOnly(DateTime.now()).difference(_dateOnly(mostRecent)).inDays;
});

/// CLAUDE.md §7-2: 100일 단위(100, 200, 300...) + 1주년 단위(365, 730...)
/// 배수 중 아직 지나지 않은 것을 날짜 오름차순으로 최대 5개 반환.
///
/// 이 계산은 이별기간을 빼지 않고 startDate로부터 달력일 그대로 계산한다
/// (haruchip_app.html의 coupleDays 계산과 동일한 방식 — 이별기간 차감 없음).
final upcomingAnniversariesProvider = Provider<List<AnniversaryMilestone>>((ref) {
  final couple = ref.watch(coupleProvider);
  final today = _dateOnly(DateTime.now());
  final start = _dateOnly(couple.startDate);

  final candidates = <AnniversaryMilestone>[];

  // 100일 단위 — 최대 50년(18,000일)까지 여유 있게 커버.
  for (var n = 100; n <= 18000; n += 100) {
    final date = start.add(Duration(days: n));
    if (!date.isBefore(today)) {
      candidates.add(AnniversaryMilestone(
        label: '$n일',
        date: date,
        dDay: date.difference(today).inDays,
      ));
    }
  }

  // 1주년 단위 — 최대 50주년까지.
  for (var years = 1; years <= 50; years++) {
    final date = start.add(Duration(days: 365 * years));
    if (!date.isBefore(today)) {
      candidates.add(AnniversaryMilestone(
        label: '$years주년',
        date: date,
        dDay: date.difference(today).inDays,
      ));
    }
  }

  candidates.sort((a, b) => a.date.compareTo(b.date));
  return candidates.take(5).toList();
});
