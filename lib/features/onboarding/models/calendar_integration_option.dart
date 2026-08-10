import 'package:flutter/material.dart';

/// 온보딩 "캘린더 연동 선택" 단계의 선택지 1개.
///
/// 하루칩 자체 캘린더는 CLAUDE.md §7-4에 따라 항상 강제 ON이라 선택지에
/// 포함하지 않는다 — 여기서 고르는 건 *외부* 캘린더(구글/네이버) 연동 여부뿐이다.
@immutable
class CalendarIntegrationOption {
  const CalendarIntegrationOption({
    required this.key,
    required this.labelKo,
    required this.description,
    required this.icon,
  });

  /// "google" | "naver". 이후 사용자별 기본 연동 설정을 저장할 때 쓰는 키.
  final String key;
  final String labelKo;
  final String description;
  final IconData icon;
}
