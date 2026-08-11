import 'package:flutter/material.dart';

/// 온보딩 "대시보드 뷰모드" 단계의 선택지 1개.
///
/// 대시보드에서 카테고리 카드를 보여줄 기본 레이아웃(§8 "대시보드" 명세의
/// "뷰모드 전환")을 고르는 단계다. 카테고리 선택/캘린더 연동 선택과 달리
/// 이 값은 단일 선택(라디오형)이며, [DashboardViewModeNotifier]가 이 중
/// 하나의 key만 상태로 들고 있는다.
@immutable
class DashboardViewModeOption {
  const DashboardViewModeOption({
    required this.key,
    required this.labelKo,
    required this.description,
    required this.icon,
  });

  /// "vertical" | "box". 온보딩 완료 시 유저 설정(기본 대시보드 뷰모드)으로
  /// 저장될 키.
  final String key;
  final String labelKo;
  final String description;
  final IconData icon;
}
