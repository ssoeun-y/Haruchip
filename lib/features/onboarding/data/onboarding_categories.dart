import '../models/onboarding_category.dart';

/// 온보딩 카테고리 선택 화면에 노출하는 전체 카테고리 목록.
///
/// CLAUDE.md §4 `categoryKey` enum(exam | birthday | pet | plan | solo |
/// military | couple)과 1:1로 대응한다. 새 categoryKey를 추가/변경할 때는
/// 반드시 CLAUDE.md §4도 함께 갱신할 것.
///
/// 순서·이모지·라벨은 haruchip_app.html의 `appState.categories` 키 순서 및
/// 각 항목의 `title`, `getCategoryEmoji()`와 동일하게 맞췄다(§5/§6
/// 프로토타입 재현 규칙). `labelKo`가 짧은 단어가 아니라 "솔로 / 최애 덕질"
/// 처럼 긴 것도 있는데, 이는 프로토타입이 온보딩 카드에도 대시보드용
/// `cat.title`을 그대로 재사용하기 때문이다 — 임의로 줄이지 않는다.
/// [OnboardingCategory.group]은 화면에 노출하진 않지만 §5 자유도 구분을
/// 위해 데이터에는 남겨둔다.
const List<OnboardingCategory> kOnboardingCategories = [
  OnboardingCategory(
    key: 'couple',
    labelKo: '커플',
    group: CategoryGroup.emotional,
    emoji: '❤️',
  ),
  OnboardingCategory(
    key: 'solo',
    labelKo: '솔로 / 최애 덕질',
    group: CategoryGroup.emotional,
    emoji: '🌟',
  ),
  OnboardingCategory(
    key: 'military',
    labelKo: '군대 (곰신)',
    group: CategoryGroup.practical,
    emoji: '🎖️',
  ),
  OnboardingCategory(
    key: 'exam',
    labelKo: '시험 / 자격증',
    group: CategoryGroup.practical,
    emoji: '📚',
  ),
  OnboardingCategory(
    key: 'birthday',
    labelKo: '생일',
    group: CategoryGroup.emotional,
    emoji: '🎂',
  ),
  OnboardingCategory(
    key: 'pet',
    labelKo: '반려동물',
    group: CategoryGroup.emotional,
    emoji: '🐾',
  ),
  OnboardingCategory(
    key: 'plan',
    labelKo: '계획 / 일정',
    group: CategoryGroup.practical,
    emoji: '📝',
  ),
];
