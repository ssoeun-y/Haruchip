import 'package:flutter/material.dart';

/// 사용자가 만든 카테고리 인스턴스 1개.
///
/// CLAUDE.md §4 `users/{uid}/categoryItems/{itemId}`의 `colorHex`
/// 필드명·형식을 그대로 따른다(추후 Firestore 연동 시 필드 매핑이
/// 1:1이 되도록).
///
/// "카테고리는 태그 개념 — 동일 카테고리 다중 인스턴스 항상 허용"
/// (CLAUDE.md §5)이므로 같은 [categoryKey]를 가진 [Category]가 여러 개
/// 존재할 수 있다. 예: `categoryKey: 'exam'`으로 "정보처리기사"와 "토익"
/// 두 인스턴스를 각각 만들 수 있고, 서로 다른 이름/아이콘/색을 가진다.
///
/// 커스텀 범위는 이름/아이콘/색상 + (감성형 한정) 배경 사진 하나까지다 —
/// 타이포그래피와 그라데이션/스티커 배경은 폰트·에셋 관리 트랙이 아직
/// 없어 다음 단계로 미룬다. [backgroundImageUrl]은 핸드오프 문서 §6
/// "사진 업로드 확정"으로 나중에 추가된 필드라 이름/아이콘/색상보다
/// 뒤늦게 생겼다.
@immutable
class Category {
  const Category({
    required this.id,
    required this.categoryKey,
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.createdAt,
    this.backgroundImageUrl,
  });

  final String id;

  /// 'couple' | 'solo' | 'military' | 'exam' | 'birthday' | 'pet' | 'plan' |
  /// 'baby' — [kCategoryTypes]의 키와 1:1 대응.
  final String categoryKey;

  /// 사용자가 직접 지은 카테고리 이름(예: "정보처리기사", "토익").
  final String name;

  /// 카드에 노출할 이모지 아이콘.
  final String emoji;

  /// 무료 프리셋 7개(§6 `AppColors.kFreeColorPresets`) 중 하나의 hex
  /// 문자열(`#RRGGBB`). 프리셋 밖 값은 프리미엄 범위라 이번 단계에서
  /// 만들 수 없다.
  final String colorHex;

  final DateTime createdAt;

  /// 배경 사진 URL(§5 "감성형: 배경 자유", §6 사진 업로드) — 감성형
  /// 카테고리(couple/solo/birthday/pet/baby)만 설정 UI에 노출한다.
  /// `ImageUploadService`가 Storage에 올리고 돌려준 다운로드 URL 그대로.
  final String? backgroundImageUrl;

  Category copyWith({
    String? id,
    String? categoryKey,
    String? name,
    String? emoji,
    String? colorHex,
    DateTime? createdAt,
    String? backgroundImageUrl,
  }) {
    return Category(
      id: id ?? this.id,
      categoryKey: categoryKey ?? this.categoryKey,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
    );
  }
}

/// `Category.colorHex`(`#RRGGBB`) ↔ [Color] 변환 — 화면 담당자가 스와치를
/// 그리거나 저장할 때 이 두 함수만 쓰면 된다.
String colorToHex(Color color) {
  int channel(double c) => (c * 255).round().clamp(0, 255);
  final r = channel(color.r).toRadixString(16).padLeft(2, '0');
  final g = channel(color.g).toRadixString(16).padLeft(2, '0');
  final b = channel(color.b).toRadixString(16).padLeft(2, '0');
  return '#$r$g$b'.toUpperCase();
}

Color colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}
