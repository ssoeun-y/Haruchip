import 'package:flutter/material.dart';

import '../models/calendar_integration_option.dart';

/// 온보딩 "캘린더 연동 선택" 화면에 노출하는 외부 캘린더 목록.
///
/// CLAUDE.md §7-4 "구글/네이버는 카테고리별 기본값 저장 방식"과 대응한다.
/// 실제 OAuth 연동은 이 단계 범위 밖이며(§11 우선순위 참고), 여기서는
/// 사용자가 나중에 쓸 기본 연동 의사만 기록한다.
const List<CalendarIntegrationOption> kCalendarIntegrationOptions = [
  CalendarIntegrationOption(
    key: 'google',
    labelKo: '구글 캘린더',
    description: '구글 캘린더 일정을 하루칩에서 함께 볼 수 있어요',
    icon: Icons.event_rounded,
  ),
  CalendarIntegrationOption(
    key: 'naver',
    labelKo: '네이버 캘린더',
    description: '네이버 캘린더 일정을 하루칩에서 함께 볼 수 있어요',
    icon: Icons.calendar_month_rounded,
  ),
];
