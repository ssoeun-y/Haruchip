import 'package:flutter/material.dart';

/// 카테고리 자유도 유형 (CLAUDE.md §5).
///
/// - [emotional] 감성형: 배경/스티커/애니메이션/폰트/프레임 자유
/// - [practical] 실용형: 컬러+폰트만 제한, 레이아웃 고정
enum CategoryGroup { emotional, practical }

/// 온보딩 카테고리 선택지 1개.
///
/// [key]는 Firestore `users/{uid}/categoryItems/{itemId}.categoryKey`
/// (CLAUDE.md §4)와 반드시 동일한 값을 써야 한다.
@immutable
class OnboardingCategory {
  const OnboardingCategory({
    required this.key,
    required this.labelKo,
    required this.group,
    required this.icon,
  });

  final String key;
  final String labelKo;
  final CategoryGroup group;
  final IconData icon;
}
