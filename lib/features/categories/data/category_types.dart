import '../../onboarding/data/onboarding_categories.dart';
import '../../onboarding/models/onboarding_category.dart';

/// 카테고리 & 디데이 명세 §4 `ddayTitlePlaceholder`를 그대로 이식한 맵.
///
/// 명세 원문의 `CategoryType.project`는 이 저장소의 기존 `categoryKey`
/// (CLAUDE.md §4: exam|birthday|pet|plan|solo|military|couple)와 대조했을
/// 때 의미가 겹치는 게 `plan`("계획/업무/학업/시험/군대 공통" §2)이라
/// 별도 키를 만들지 않고 `plan`에 이식했다. `custom`은 아직 이 저장소에
/// 자유 생성 카테고리 키가 없어(§7 우선순위상 다음 단계) placeholder만
/// 미리 마련해 둔다. `solo`는 명세 §4에 없던 값이라 프로토타입 톤에 맞춰
/// 새로 하나 지었다 — 확정 카피는 아니다.
const Map<String, String> ddayTitlePlaceholder = {
  'custom': '제목을 입력하세요',
  'couple': '예: 우리 100일, 여행 기념일',
  'birthday': '예: 엄마 생신, ○○이 생일',
  'military': '예: 전역까지, 첫 휴가',
  'exam': '예: 정보처리기사 필기, 토익',
  'baby': '예: 첫 뒤집기, 백일 사진',
  'pet': '예: 병원 예약, 산책',
  'plan': '예: 기획안 마감, 클라이언트 미팅',
  'solo': '예: 콘서트 티켓팅, 최애 컴백일',
};

/// [kOnboardingCategories]에 명세의 `baby`(아기 — §5.5)를 더한 카테고리
/// 타입 전체 목록. CLAUDE.md §4 `categoryKey` enum도 함께 갱신했다.
///
/// 온보딩 화면은 여전히 [kOnboardingCategories]를 쓴다(온보딩 카드 순서는
/// haruchip_app.html 고정 순서라 §5/§6 규칙상 임의로 늘리지 않는다) —
/// 이 목록은 "카테고리 추가하기" 같은 온보딩 이후 신규 생성 플로우에서만
/// 쓴다.
const List<OnboardingCategory> kCategoryTypes = [
  ...kOnboardingCategories,
  OnboardingCategory(
    key: 'baby',
    labelKo: '아기',
    group: CategoryGroup.emotional,
    emoji: '👶',
  ),
];

/// [categoryKey]에 해당하는 [OnboardingCategory]를 찾는다. 못 찾으면
/// null(호출부가 'custom'류 기본값으로 대체).
OnboardingCategory? categoryTypeOf(String categoryKey) {
  for (final type in kCategoryTypes) {
    if (type.key == categoryKey) return type;
  }
  return null;
}
