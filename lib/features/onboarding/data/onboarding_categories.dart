import 'package:flutter/material.dart';

import '../models/onboarding_category.dart';

/// 온보딩 카테고리 선택 화면에 노출하는 전체 카테고리 목록.
///
/// CLAUDE.md §4 `categoryKey` enum(exam | birthday | pet | plan | solo |
/// military | couple)과 1:1로 대응한다. 새 categoryKey를 추가/변경할 때는
/// 반드시 CLAUDE.md §4도 함께 갱신할 것.
const List<OnboardingCategory> kOnboardingCategories = [
  // 감성형 — 배경/스티커/애니메이션/폰트/프레임 자유 (§5)
  OnboardingCategory(
    key: 'couple',
    labelKo: '커플',
    group: CategoryGroup.emotional,
    icon: Icons.favorite_rounded,
  ),
  OnboardingCategory(
    key: 'solo',
    labelKo: '솔로',
    group: CategoryGroup.emotional,
    icon: Icons.person_rounded,
  ),
  OnboardingCategory(
    key: 'birthday',
    labelKo: '생일',
    group: CategoryGroup.emotional,
    icon: Icons.cake_rounded,
  ),
  OnboardingCategory(
    key: 'pet',
    labelKo: '반려동물',
    group: CategoryGroup.emotional,
    icon: Icons.pets_rounded,
  ),

  // 실용형 — 컬러+폰트만 제한, 레이아웃 고정 (§5)
  OnboardingCategory(
    key: 'exam',
    labelKo: '시험',
    group: CategoryGroup.practical,
    icon: Icons.edit_note_rounded,
  ),
  OnboardingCategory(
    key: 'plan',
    labelKo: '계획',
    group: CategoryGroup.practical,
    icon: Icons.checklist_rounded,
  ),
  OnboardingCategory(
    key: 'military',
    labelKo: '군대',
    group: CategoryGroup.practical,
    icon: Icons.military_tech_rounded,
  ),
];
