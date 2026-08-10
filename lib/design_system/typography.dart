import 'package:flutter/material.dart';

import 'colors.dart';

/// 하루칩 디자인 토큰 — 타이포그래피.
///
/// 화면 코드에서 TextStyle 직접 생성 금지, 항상 이 파일의 토큰을 참조한다.
class AppTypography {
  AppTypography._();

  // TODO(design): 브랜드 폰트(예: Pretendard) 확정 시 pubspec.yaml에
  // asset으로 등록하고 여기 지정한다. 현재는 플랫폼 기본 폰트를 사용한다.
  static const String? fontFamily = null;

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cardLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
