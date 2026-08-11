import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../models/calendar_event.dart';
import '../models/schedule_room.dart';

/// AppColors 토큰(Color)을 CalendarEvent.colorHex가 요구하는 '#RRGGBB' 문자열로
/// 변환한다. 색상값 자체는 항상 AppColors.proto* 토큰에서만 가져온다(§6).
String _toHex(Color color) {
  String channel(double v) => (v * 255).round().toRadixString(16).padLeft(2, '0');
  return '#${channel(color.r)}${channel(color.g)}${channel(color.b)}'.toUpperCase();
}

/// source별 표시 색상.
///
/// NOTE(토큰 갭): AppColors에는 구글/네이버 브랜드색 전용 토큰이 아직 없다.
/// personal은 커플 핑크 톤(protoCoupleText)을, google/naver는 각각
/// practicalAccent(파랑 계열)/emotionalAccent(핑크 계열)를 임시로 빌려 썼다.
/// 실제 구글(빨강 계열)·네이버(초록 계열) 브랜드 색이 필요하면
/// `protoGoogleSource` / `protoNaverSource` 같은 토큰을 colors.dart에 새로
/// 추가해야 한다 — 이번 작업 범위(로직 담당자)에서는 임의로 만들지 않았다.
String colorHexForSource(String source) {
  switch (source) {
    case 'google':
      return _toHex(AppColors.practicalAccent);
    case 'naver':
      return _toHex(AppColors.emotionalAccent);
    case 'personal':
    default:
      return _toHex(AppColors.protoCoupleText);
  }
}

/// CalendarEvent mock 목록.
final List<CalendarEvent> mockCalendarEvents = [
  CalendarEvent(
    id: 'evt-1',
    date: DateTime(2026, 8, 14),
    title: '민수와 데이트',
    time: '19:00',
    source: 'personal',
    colorHex: colorHexForSource('personal'),
    isPublic: false,
  ),
  CalendarEvent(
    id: 'evt-2',
    date: DateTime(2026, 8, 20),
    title: '팀 프로젝트 회식',
    time: '18:30',
    source: 'google',
    colorHex: colorHexForSource('google'),
    isPublic: false,
  ),
  CalendarEvent(
    id: 'evt-3',
    date: DateTime(2026, 9, 1),
    title: '정보처리기사 필기',
    source: 'naver',
    colorHex: colorHexForSource('naver'),
    isPublic: true,
  ),
];

/// ScheduleRoom mock 목록.
///
/// haruchip_app.html의 mock 방 2개("주말 대학 동창 모임" / "팀 프로젝트 회식")와
/// 같은 톤으로 맞췄다. uid는 화면 담당자가 실제 로그인 uid로 교체하기 쉽도록
/// 이름 그대로 문자열 키로 뒀다.
final List<ScheduleRoom> mockScheduleRooms = [
  ScheduleRoom(
    id: 'room-1',
    name: '주말 대학 동창 모임',
    inviteCode: 'ROOM88',
    members: const [
      RoomMember(uid: '하루', name: '하루', icon: '🐥'),
      RoomMember(uid: '민수', name: '민수', icon: '🐶'),
      RoomMember(uid: '서연', name: '서연', icon: '🐱'),
      RoomMember(uid: '도윤', name: '도윤', icon: '🦊'),
    ],
    dates: {
      '2026-08-13': ['하루', '민수', '서연'],
      '2026-08-14': ['하루', '민수', '서연', '도윤'],
    },
    payments: const {'하루': 60000, '서연': 40000},
  ),
  ScheduleRoom(
    id: 'room-2',
    name: '팀 프로젝트 회식',
    inviteCode: 'TEAM99',
    members: const [
      RoomMember(uid: '하루', name: '하루', icon: '🐥'),
      RoomMember(uid: '팀장님', name: '팀장님', icon: '🦁'),
      RoomMember(uid: '인턴', name: '인턴', icon: '🐰'),
    ],
    dates: {
      '2026-08-10': ['하루', '팀장님'],
    },
    payments: const {'팀장님': 45000},
  ),
];
