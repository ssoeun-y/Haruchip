import 'package:flutter/material.dart';

import '../models/dashboard_view_mode_option.dart';

/// 온보딩 "대시보드 뷰모드" 화면에 노출하는 선택지 목록.
///
/// 대시보드 카테고리 카드를 세로로 나열할지(세로형), 격자로 보여줄지
/// (박스형) 고르는 두 가지뿐이다 — 상호 배타적인 단일 선택.
///
/// 라벨·설명은 haruchip_app.html `onboardingStep === 3` 분기의 라디오
/// 선택지 문구와 동일하게 맞췄다(§5/§6). 그 화면엔 아이콘이 없어서
/// [DashboardViewModeOption.icon]은 새 라디오형 카드에선 쓰지 않는다 —
/// 필드 자체는 나중을 위해 남겨둔다.
const List<DashboardViewModeOption> kDashboardViewModeOptions = [
  DashboardViewModeOption(
    key: 'vertical',
    labelKo: '세로 정렬 스와이프형',
    description: '카테고리별 깔끔한 리스트 세로 배치',
    icon: Icons.view_agenda_rounded,
  ),
  DashboardViewModeOption(
    key: 'box',
    labelKo: '박스형 대시보드',
    description: '네모난 카드 그리드 개별 노출형',
    icon: Icons.grid_view_rounded,
  ),
];
