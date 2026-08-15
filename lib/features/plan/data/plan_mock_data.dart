import '../models/plan_item.dart';

/// PlanItem 초기 mock 목록.
///
/// haruchip_app.html의 exam/plan mock(정보처리기사 필기, SQLD 실기, 유럽
/// 여행 계획 확정 등)과 같은 톤으로 맞췄다.
final List<PlanItem> mockPlanItems = [
  PlanItem(
    id: 'plan-1',
    title: '정보처리기사 필기',
    date: DateTime(2026, 9, 15),
    categoryKey: 'exam',
  ),
  PlanItem(
    id: 'plan-2',
    title: 'SQLD 실기',
    date: DateTime(2026, 10, 20),
    categoryKey: 'exam',
  ),
  PlanItem(
    id: 'plan-3',
    title: '유럽 여행 계획 확정',
    date: DateTime(2026, 9, 1),
    categoryKey: 'plan',
  ),
  // birthday: §7-2 100일 단위+1주년 자동 계산과는 별개로, 생일은 매년
  // 반복(repeat: true)이라 dDayLabel이 그해 기준 D-day를 그대로 보여준다.
  PlanItem(
    id: 'plan-4',
    title: '엄마 생신',
    date: DateTime(2026, 10, 12),
    categoryKey: 'birthday',
    repeat: true,
  ),
  PlanItem(
    id: 'plan-5',
    title: '베프 지민',
    date: DateTime(2026, 11, 4),
    categoryKey: 'birthday',
    repeat: true,
  ),
  // pet: date는 D-day 카운트다운용이 아니라 "태어난/입양된 날"이다.
  // 대시보드 카드는 이 날짜로 daysSince()를 호출해 "D+650일째"처럼
  // 카운트업으로 보여준다(dDayLabel의 카운트다운 문자열과는 용도가 다르다).
  PlanItem(
    id: 'plan-6',
    title: '초코 (포메라니안)',
    date: DateTime(2023, 8, 20),
    categoryKey: 'pet',
  ),
];
