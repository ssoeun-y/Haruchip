import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 온보딩 "캘린더 연동 선택" 단계 상태.
///
/// 값은 [CalendarIntegrationOption.key] 집합. 하루칩 자체 캘린더는 항상
/// 켜져 있어(CLAUDE.md §7-4) 여기 포함하지 않으며, 0개를 선택해도(=연동
/// 없이 계속하기) 다음 단계로 진행할 수 있다 — 카테고리 선택과 달리 최소
/// 선택 제약이 없다.
class CalendarIntegrationNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  void toggle(String providerKey) {
    final next = {...state};
    if (!next.remove(providerKey)) {
      next.add(providerKey);
    }
    state = next;
  }

  bool isSelected(String providerKey) => state.contains(providerKey);
}

final calendarIntegrationProvider =
    NotifierProvider<CalendarIntegrationNotifier, Set<String>>(
  CalendarIntegrationNotifier.new,
);
