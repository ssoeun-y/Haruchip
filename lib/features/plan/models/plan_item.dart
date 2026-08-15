import 'package:flutter/material.dart' show TimeOfDay;

import '../../categories/logic/repeat_rule.dart';
import '../../categories/models/exam_timeline.dart';

/// 계획(업무/프로젝트) 카테고리 칸반 상태 — 명세 §1
/// `DdayItem.kanbanStatus`, §5.7 "칸반 보드(할일/진행중/완료)".
/// `categoryKey == 'plan'` 항목에서만 의미가 있다.
enum KanbanStatus {
  todo,
  inProgress,
  done;

  String get labelKo => switch (this) {
        KanbanStatus.todo => '할일',
        KanbanStatus.inProgress => '진행중',
        KanbanStatus.done => '완료',
      };
}

/// 중요도 — 명세 §5.7 "중요도별 컬러 라벨". `priorityColor()`(로직
/// 담당자)가 이 값을 기존 디자인 토큰에 매핑한다.
enum PlanPriority { low, medium, high }

/// 디데이 항목의 표시 방식 — 카테고리 & 디데이 명세 §1
/// `DdayItem.displayMode`(dday/daysCount/monthsCount)를 그대로 옮겼다.
enum DdayDisplayMode {
  /// 'D-n' / 'D-day' / 'D+n' — 기본값, [dDayLabel] 그대로 사용.
  dday,

  /// 'N일째' — [daysSince] 카운트업(반려동물 카드가 이미 쓰던 방식).
  daysCount,

  /// '개월수' — 아기 카테고리(§5.5) 등 "N일째 · M개월 D일째" 병기용.
  monthsCount,
}

/// 캘린더 연동 체크박스 상태 — 명세 §1 `DdayItem.calendarSync`.
///
/// 실제 구글/네이버 캘린더 API 연동은 보류 트랙(핸드오프 문서 §6)이라
/// 이번 단계에서는 UI 상태값만 들고 있는다.
class CalendarSyncFlags {
  const CalendarSyncFlags({
    this.google = false,
    this.naver = false,
    this.haruchip = false,
  });

  final bool google;
  final bool naver;
  final bool haruchip;

  CalendarSyncFlags copyWith({bool? google, bool? naver, bool? haruchip}) {
    return CalendarSyncFlags(
      google: google ?? this.google,
      naver: naver ?? this.naver,
      haruchip: haruchip ?? this.haruchip,
    );
  }
}

/// D-day 리스트 화면(plan)에서 다루는 항목 하나.
///
/// 카테고리는 태그 개념(CLAUDE.md §5) — 동일 [categoryKey]를 가진 항목이
/// 여러 개 존재하는 것은 항상 허용된다(다중 인스턴스).
///
/// NOTE: 카테고리 & 디데이 명세가 정의한 `DdayItem`을 별도 모델로 새로
/// 만들지 않고 이 클래스를 확장했다 — `PlanItem`이 이미 대시보드/plan
/// 탭/캘린더 화면이 공유하는 사실상의 통합 D-day 저장소라서, 병렬 모델을
/// 만들면 그 3곳을 전부 마이그레이션해야 해 "최소 흐름 검증" 범위를
/// 넘어선다.
class PlanItem {
  PlanItem({
    required this.id,
    required this.title,
    required this.date,
    required this.categoryKey,
    this.categoryInstanceId,
    this.displayMode = DdayDisplayMode.dday,
    RepeatConfig? repeatConfig,
    this.calendarSync = const CalendarSyncFlags(),
    bool repeat = false,
    this.examTimeline = const [],
    this.kanbanStatus = KanbanStatus.todo,
    this.priority = PlanPriority.medium,
    this.deadlineTime,
    this.photoUrl,
  }) : repeatConfig = repeatConfig ?? (repeat ? RepeatConfig.yearlyDefault : RepeatConfig.none);

  final String id;
  final String title;
  final DateTime date;

  /// 'plan' | 'exam' | 'study' | 'military' 등 — 자유롭게 확장 가능한 태그성
  /// 문자열. 이번 범위(§7-3 AI 스케줄링 제외)에서는 D-day 계산에만 쓰인다.
  final String categoryKey;

  /// 이 항목이 속한 [Category] 인스턴스 id. 기존 mock 데이터처럼 특정
  /// 인스턴스에 안 묶인 legacy 항목은 null — 그런 항목은 categoryKey로만
  /// 필터링된다(다중 인스턴스 카드 분기 대상에서는 제외).
  final String? categoryInstanceId;

  final DdayDisplayMode displayMode;

  /// 반복 설정. 과거 `repeat: bool`(매년 반복만 표현 가능했다)을 대체한다.
  final RepeatConfig repeatConfig;

  final CalendarSyncFlags calendarSync;

  /// 시험 카테고리 전용 타임라인(§5.4) — exam이 아니면 항상 빈 리스트.
  final List<ExamTimelineEntry> examTimeline;

  /// 계획 카테고리 전용 칸반 상태(§5.7) — plan이 아니면 의미 없음(기본값
  /// todo로 둬도 다른 카테고리 화면엔 노출되지 않는다).
  final KanbanStatus kanbanStatus;

  /// 중요도(§5.7 컬러 라벨) — plan 카테고리에서만 UI에 노출하지만, 다른
  /// 카테고리 항목도 기본값(medium)을 그냥 들고 있는다.
  final PlanPriority priority;

  /// 마감 "시간"(§5.7 deadlineTime) — 날짜([date])와 별개로 시:분까지
  /// 지정하고 싶을 때만 채운다.
  final TimeOfDay? deadlineTime;

  /// 프로필/기록 사진 URL(§5.5 아기 "프로필 사진 원형 프레임", §5.6
  /// 반려동물 "사진+이름 카드형 프로필") — `ImageUploadService`가 Storage에
  /// 올리고 돌려준 다운로드 URL을 그대로 담는다. baby/pet이 아니면 보통
  /// null.
  final String? photoUrl;

  /// 과거 `repeat: bool` 호환용 getter — 반복 종류와 무관하게 "반복되는
  /// 항목인가"만 필요한 기존 호출부가 계속 동작하도록 남겨둔다.
  bool get repeat => repeatConfig.isRepeating;

  PlanItem copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? categoryKey,
    String? categoryInstanceId,
    DdayDisplayMode? displayMode,
    RepeatConfig? repeatConfig,
    CalendarSyncFlags? calendarSync,
    List<ExamTimelineEntry>? examTimeline,
    KanbanStatus? kanbanStatus,
    PlanPriority? priority,
    TimeOfDay? deadlineTime,
    String? photoUrl,
  }) {
    return PlanItem(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      categoryKey: categoryKey ?? this.categoryKey,
      categoryInstanceId: categoryInstanceId ?? this.categoryInstanceId,
      displayMode: displayMode ?? this.displayMode,
      repeatConfig: repeatConfig ?? this.repeatConfig,
      calendarSync: calendarSync ?? this.calendarSync,
      examTimeline: examTimeline ?? this.examTimeline,
      kanbanStatus: kanbanStatus ?? this.kanbanStatus,
      priority: priority ?? this.priority,
      deadlineTime: deadlineTime ?? this.deadlineTime,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
