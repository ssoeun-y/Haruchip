import 'package:flutter/material.dart';

/// 카테고리 자유도 유형 (CLAUDE.md §5).
///
/// - [emotional] 감성형: 배경/스티커/애니메이션/폰트/프레임 자유
/// - [practical] 실용형: 컬러+폰트만 제한, 레이아웃 고정
///
/// 온보딩 카테고리 선택 화면에는 더 이상 이 구분을 그룹 헤더로 노출하지
/// 않는다(§5/§6 프로토타입 재현 규칙 — haruchip_app.html은 카테고리를
/// flat하게만 보여준다). [group] 값 자체는 이후 실제 카테고리 화면(꾸미기
/// 자유도 제한 등)에서 계속 쓰이므로 모델에는 남겨둔다.
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
    required this.emoji,
  });

  final String key;
  final String labelKo;
  final CategoryGroup group;

  /// haruchip_app.html의 `getCategoryEmoji()`와 동일한 이모지.
  /// 프로토타입은 Material 아이콘이 아니라 이모지를 쓰므로 그대로 맞춘다.
  final String emoji;
}
