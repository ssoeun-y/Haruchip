import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/plan_mock_data.dart';
import '../models/plan_item.dart';

List<PlanItem> _sortedByDate(List<PlanItem> items) {
  final sorted = [...items];
  sorted.sort((a, b) => a.date.compareTo(b.date));
  return sorted;
}

/// plan(D-day 리스트) 상태. 항상 날짜 오름차순 정렬을 유지한다.
///
/// 카테고리는 태그 개념(CLAUDE.md §5)이라 동일 categoryKey를 가진 항목을
/// 몇 개든 추가할 수 있다 — [addItem]에 카테고리 중복 제한이 없다.
class PlanListNotifier extends Notifier<List<PlanItem>> {
  @override
  List<PlanItem> build() => _sortedByDate(mockPlanItems);

  void addItem(PlanItem item) {
    state = _sortedByDate([...state, item]);
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final planListProvider =
    NotifierProvider<PlanListNotifier, List<PlanItem>>(PlanListNotifier.new);

/// 카테고리(§5 태그 개념)별로 필터링한 항목 목록.
/// 대시보드 카드가 categoryKey별로 자기 항목만 뽑아 쓸 때 사용한다.
/// 가족(family) provider 스타일과 맞춰 `.family` 수정자로 categoryKey를
/// 파라미터로 받는다 — 정렬 순서는 [planListProvider]와 동일(날짜 오름차순).
final planItemsByCategoryProvider =
    Provider.family<List<PlanItem>, String>((ref, categoryKey) {
  return ref
      .watch(planListProvider)
      .where((item) => item.categoryKey == categoryKey)
      .toList();
});

/// haruchip_app.html의 daysUntil() 포팅.
/// 'D-n'(미래) / 'D-day'(오늘) / 'D+n'(지남) 문자열을 반환한다.
String dDayLabel(DateTime date) {
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);
  final targetOnly = DateTime(date.year, date.month, date.day);
  final diff = targetOnly.difference(todayOnly).inDays;
  if (diff == 0) return 'D-day';
  if (diff > 0) return 'D-$diff';
  return 'D+${diff.abs()}';
}

/// pet 카테고리 전용 — dDayLabel(카운트다운)과 달리 [date](태어난/입양된 날)
/// 로부터 오늘까지 지난 일수를 그대로 정수로 반환한다(카운트업).
/// 반려동물 카드의 "D+650일째" 표시는 화면 담당자가
/// `'D+${daysSince(date)}일째'`처럼 조합해 쓰면 된다.
int daysSince(DateTime date) {
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);
  final dateOnly = DateTime(date.year, date.month, date.day);
  return todayOnly.difference(dateOnly).inDays;
}
