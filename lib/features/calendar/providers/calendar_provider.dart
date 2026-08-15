import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_mock_data.dart';
import '../models/calendar_event.dart';

const Object _unset = Object();

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 캘린더 화면에서 사용자가 보고 있는 연/월과 선택한 날짜.
///
/// CLAUDE.md §7-4: "개인 캘린더 표시는 항상 강제 ON (토글 UI 자체를 만들지
/// 않는다)" — 그래서 이 상태에는 "개인 캘린더 끄기" 같은 boolean이 없다.
class CalendarSelectionState {
  const CalendarSelectionState({
    required this.focusedMonth,
    this.selectedDate,
  });

  /// 현재 보고 있는 달의 1일 (연/월 내비게이션용).
  final DateTime focusedMonth;

  /// 사용자가 탭한 날짜. 아직 선택 안 했으면 null.
  final DateTime? selectedDate;

  CalendarSelectionState copyWith({
    DateTime? focusedMonth,
    Object? selectedDate = _unset,
  }) {
    return CalendarSelectionState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDate: identical(selectedDate, _unset)
          ? this.selectedDate
          : selectedDate as DateTime?,
    );
  }
}

class CalendarSelectionNotifier extends Notifier<CalendarSelectionState> {
  @override
  CalendarSelectionState build() {
    final today = _dateOnly(DateTime.now());
    return CalendarSelectionState(
      focusedMonth: DateTime(today.year, today.month, 1),
      selectedDate: today,
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: _dateOnly(date));
  }

  void changeMonth(DateTime month) {
    state = state.copyWith(
      focusedMonth: DateTime(month.year, month.month, 1),
      selectedDate: null,
    );
  }

  void nextMonth() {
    final m = state.focusedMonth;
    changeMonth(DateTime(m.year, m.month + 1, 1));
  }

  void previousMonth() {
    final m = state.focusedMonth;
    changeMonth(DateTime(m.year, m.month - 1, 1));
  }
}

final calendarSelectionProvider =
    NotifierProvider<CalendarSelectionNotifier, CalendarSelectionState>(
  CalendarSelectionNotifier.new,
);

final selectedMonthProvider = Provider<DateTime>(
  (ref) => ref.watch(calendarSelectionProvider).focusedMonth,
);

final selectedDateProvider = Provider<DateTime?>(
  (ref) => ref.watch(calendarSelectionProvider).selectedDate,
);

/// 주어진 날짜의 CalendarEvent 목록. 개인 캘린더는 항상 강제 표시이므로
/// source 필터링 없이 그날의 모든 이벤트를 반환한다(§7-4).
final eventsForDateProvider =
    Provider.family<List<CalendarEvent>, DateTime>((ref, date) {
  final target = _dateOnly(date);
  return mockCalendarEvents
      .where((e) => _dateOnly(e.date) == target)
      .toList();
});
