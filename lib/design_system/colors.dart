import 'package:flutter/material.dart';

/// 하루칩 디자인 토큰 — 색상.
///
/// 화면 코드에서 Color(0x...) 하드코딩 금지, 항상 이 파일의 토큰을 참조한다.
/// (CLAUDE.md §6: "색상은 항상 디자인 토큰 참조, 하드코딩 금지")
///
/// NOTE: 아래 값들은 정식 브랜드 가이드가 없는 상태에서 잡은 임시 팔레트다.
/// 브랜드 가이드가 확정되면 이 파일만 교체하면 되도록 색상은 전부 여기로 모은다.
///
/// NOTE: §6이 언급하는 `kFreeColorPresets`(D-day/캘린더 등록용 무료 프리셋 7개)는
/// 색상 피커 기능을 만들 때 추가한다 — 실제 브랜드 확정 색상이 필요해 이번
/// 카테고리 선택 화면 범위에서는 임의로 정하지 않았다.
class AppColors {
  AppColors._();

  // Base
  static const Color background = Color(0xFFFFFBF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5F0EC);
  static const Color border = Color(0xFFE7DFD8);

  // Text
  static const Color textPrimary = Color(0xFF2B2320);
  static const Color textSecondary = Color(0xFF8A7F78);
  static const Color textDisabled = Color(0xFFC7BEB8);

  // Brand
  static const Color primary = Color(0xFFFF7A59);
  static const Color primaryMuted = Color(0xFFFFE7DE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 카테고리 유형별 액센트 (§5: 감성형 / 실용형)
  static const Color emotionalAccent = Color(0xFFFF7A9C);
  static const Color emotionalAccentMuted = Color(0xFFFFE3EA);
  static const Color practicalAccent = Color(0xFF4E8CFF);
  static const Color practicalAccentMuted = Color(0xFFE4ECFF);

  static const Color danger = Color(0xFFE0523F);
}
