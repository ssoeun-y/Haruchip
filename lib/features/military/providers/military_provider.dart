import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plan/providers/plan_provider.dart' show dDayLabel;
import '../data/military_mock_data.dart';
import '../models/military_service.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 군대(곰신) 복무 정보 상태 — 핸드오프 문서 §5.3.
///
/// [CoupleNotifier]와 같은 구조: mock으로 시작하고, "설정" 다이얼로그가
/// [setService]/[setNextLeave]로 갱신한다.
class MilitaryServiceNotifier extends Notifier<MilitaryService> {
  @override
  MilitaryService build() => mockMilitaryService;

  void setService({required DateTime enlistDate, required DateTime dischargeDate}) {
    state = state.copyWith(enlistDate: enlistDate, dischargeDate: dischargeDate);
  }

  void setNextLeave(DateTime? date) {
    state = state.copyWith(
      nextLeaveDate: date,
      clearNextLeaveDate: date == null,
    );
  }
}

final militaryServiceProvider =
    NotifierProvider<MilitaryServiceNotifier, MilitaryService>(
  MilitaryServiceNotifier.new,
);

/// 진급 게이지 — §5.3 "(오늘-입대일)/(전역일-입대일)*100%". 전역일이
/// 지났거나 입대 전이어도 0.0~1.0 범위로 clamp한다.
final militaryProgressProvider = Provider<double>((ref) {
  final service = ref.watch(militaryServiceProvider);
  final enlist = _dateOnly(service.enlistDate);
  final discharge = _dateOnly(service.dischargeDate);
  final today = _dateOnly(DateTime.now());

  final totalDays = discharge.difference(enlist).inDays;
  if (totalDays <= 0) return 0;
  final elapsedDays = today.difference(enlist).inDays;
  return (elapsedDays / totalDays).clamp(0.0, 1.0);
});

/// 전역 D-day 라벨('D-n'/'D-day'/'D+n') — [dDayLabel] 재사용.
final militaryDischargeDdayProvider = Provider<String>((ref) {
  final service = ref.watch(militaryServiceProvider);
  return dDayLabel(service.dischargeDate);
});

/// 다음 휴가 D-day — 설정 안 했으면 null.
final militaryLeaveDdayProvider = Provider<String?>((ref) {
  final date = ref.watch(militaryServiceProvider).nextLeaveDate;
  if (date == null) return null;
  return dDayLabel(date);
});
