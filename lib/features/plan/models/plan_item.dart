/// D-day 리스트 화면(plan)에서 다루는 항목 하나.
///
/// 카테고리는 태그 개념(CLAUDE.md §5) — 동일 [categoryKey]를 가진 항목이
/// 여러 개 존재하는 것은 항상 허용된다(다중 인스턴스).
class PlanItem {
  const PlanItem({
    required this.id,
    required this.title,
    required this.date,
    required this.categoryKey,
    this.repeat = false,
  });

  final String id;
  final String title;
  final DateTime date;

  /// 'plan' | 'exam' | 'study' | 'military' 등 — 자유롭게 확장 가능한 태그성
  /// 문자열. 이번 범위(§7-3 AI 스케줄링 제외)에서는 D-day 계산에만 쓰인다.
  final String categoryKey;

  /// 매년 반복(생일 등)인지 여부.
  final bool repeat;

  PlanItem copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? categoryKey,
    bool? repeat,
  }) {
    return PlanItem(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      categoryKey: categoryKey ?? this.categoryKey,
      repeat: repeat ?? this.repeat,
    );
  }
}
