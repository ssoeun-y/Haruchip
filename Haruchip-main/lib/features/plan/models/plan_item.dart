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

/// 캘린더/알림 사전 미리알림 (Reminder) 옵션
enum EventReminder {
  none('알림 없음', 0),
  onTime('정시(이벤트 시작 시)', 0),
  before10m('10분 전', 10),
  before30m('30분 전', 30),
  before1h('1시간 전', 60),
  before1d9am('1일 전 오전 9시', 1440),
  before3d('3일 전', 4320),
  before1w('1주일 전', 10080);

  const EventReminder(this.labelKo, this.minutesBefore);

  final String labelKo;
  final int minutesBefore;

  String toJson() => name;

  static EventReminder fromJson(String? value) {
    return EventReminder.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EventReminder.none,
    );
  }
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

  Map<String, dynamic> toJson() => {
        'google': google,
        'naver': naver,
        'haruchip': haruchip,
      };

  factory CalendarSyncFlags.fromJson(Map<String, dynamic> json) {
    return CalendarSyncFlags(
      google: json['google'] as bool? ?? false,
      naver: json['naver'] as bool? ?? false,
      haruchip: json['haruchip'] as bool? ?? false,
    );
  }
}

/// [TimeOfDay] ↔ 'HH:mm' (로컬 저장/백업용).
String? _timeToJson(TimeOfDay? t) => t == null
    ? null
    : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay? _timeFromJson(Object? v) {
  if (v is! String) return null;
  final parts = v.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return TimeOfDay(hour: h, minute: m);
}

/// D-day 리스트 화면(plan)에서 다루는 항목 하나.
///
/// 카테고리는 태그 개념(CLAUDE.md §5) — 동일 [categoryKey]를 가진 항목이
/// 여러 개 존재하는 것은 항상 허용된다(다중 인스턴스).
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
    this.reminder = EventReminder.none,
    bool repeat = false,
    this.examTimeline = const [],
    this.kanbanStatus = KanbanStatus.todo,
    this.priority = PlanPriority.medium,
    this.deadlineTime,
    this.endDate,
    this.endDeadlineTime,
    this.isAllDay = false,
    this.photoUrl,
    this.roomLinks = const [],
    this.isPredicted = false,
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
  final EventReminder reminder;

  /// 시험 카테고리 전용 타임라인(§5.4) — exam이 아니면 항상 빈 리스트.
  final List<ExamTimelineEntry> examTimeline;

  /// 계획 카테고리 전용 칸반 상태(§5.7) — plan이 아니면 의미 없음(기본값
  /// todo로 둬도 다른 카테고리 화면엔 노출되지 않는다).
  final KanbanStatus kanbanStatus;

  /// 중요도(§5.7 컬러 라벨) — plan 카테고리에서만 UI에 노출하지만, 다른
  /// 카테고리 항목도 기본값(medium)을 그냥 들고 있는다.
  final PlanPriority priority;

  /// 마감/시작 "시간"(§5.7 deadlineTime) — 날짜([date])와 별개로 시:분까지
  /// 지정하고 싶을 때만 채운다.
  final TimeOfDay? deadlineTime;

  /// 종료일 — 날짜 범위 지정 시 사용
  final DateTime? endDate;

  /// 종료 시간 — 세부 시간 지정 시 사용
  final TimeOfDay? endDeadlineTime;

  /// 하루 종일 여부
  final bool isAllDay;

  /// 프로필/기록 사진 URL(§5.5 아기 "프로필 사진 원형 프레임", §5.6
  /// 반려동물 "사진+이름 카드형 프로필") — `ImageUploadService`가 Storage에
  /// 올리고 돌려준 다운로드 URL을 그대로 담는다. baby/pet이 아니면 보통
  /// null.
  final String? photoUrl;

  /// 연동된 일정 방(`ScheduleRoom.id`) — 핸드오프 문서 §3 "모임 연동
  /// 셀렉터". 빈 리스트면 어떤 방에도 연동되지 않은 일반 항목.
  final List<String> roomLinks;

  /// 시스템이 자동으로 만든 예측 항목인가(§3 "예측 리스트업 로직") — 예:
  /// 커플 카테고리의 100일/1주년 자동 예측. 이번 단계에서 자동 생성 로직
  /// 자체는 만들지 않았지만(§5.1 자동예측 생성부는 별도 작업), 값이 있을
  /// 때 `predictedPlanItemsProvider`가 골라내도록 필드만 먼저 둔다.
  /// [RepeatConfig.isRepeating]인 항목은 이 값과 무관하게 이미 예측
  /// 리스트업에 포함된다.
  final bool isPredicted;

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
    EventReminder? reminder,
    List<ExamTimelineEntry>? examTimeline,
    KanbanStatus? kanbanStatus,
    PlanPriority? priority,
    TimeOfDay? deadlineTime,
    DateTime? endDate,
    TimeOfDay? endDeadlineTime,
    bool? isAllDay,
    String? photoUrl,
    List<String>? roomLinks,
    bool? isPredicted,
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
      reminder: reminder ?? this.reminder,
      examTimeline: examTimeline ?? this.examTimeline,
      kanbanStatus: kanbanStatus ?? this.kanbanStatus,
      priority: priority ?? this.priority,
      deadlineTime: deadlineTime ?? this.deadlineTime,
      endDate: endDate ?? this.endDate,
      endDeadlineTime: endDeadlineTime ?? this.endDeadlineTime,
      isAllDay: isAllDay ?? this.isAllDay,
      photoUrl: photoUrl ?? this.photoUrl,
      roomLinks: roomLinks ?? this.roomLinks,
      isPredicted: isPredicted ?? this.isPredicted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'categoryKey': categoryKey,
        'categoryInstanceId': categoryInstanceId,
        'displayMode': displayMode.name,
        'reminder': reminder.name,
        'kanbanStatus': kanbanStatus.name,
        'priority': priority.name,
        'endDate': endDate?.toIso8601String(),
        'isAllDay': isAllDay,
        'photoUrl': photoUrl,
        'roomLinks': roomLinks,
        'isPredicted': isPredicted,
        'repeatConfig': repeatConfig.toJson(),
        'calendarSync': calendarSync.toJson(),
        'examTimeline': examTimeline.map((e) => e.toJson()).toList(),
        'deadlineTime': _timeToJson(deadlineTime),
        'endDeadlineTime': _timeToJson(endDeadlineTime),
      };

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    return PlanItem(
      id: json['id'] as String? ?? 'item-${DateTime.now().microsecondsSinceEpoch}',
      title: json['title'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      categoryKey: json['categoryKey'] as String? ?? 'plan',
      categoryInstanceId: json['categoryInstanceId'] as String?,
      displayMode: DdayDisplayMode.values.firstWhere(
        (e) => e.name == json['displayMode'],
        orElse: () => DdayDisplayMode.dday,
      ),
      reminder: EventReminder.fromJson(json['reminder'] as String?),
      kanbanStatus: KanbanStatus.values.firstWhere(
        (e) => e.name == json['kanbanStatus'],
        orElse: () => KanbanStatus.todo,
      ),
      priority: PlanPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => PlanPriority.medium,
      ),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      isAllDay: json['isAllDay'] as bool? ?? false,
      photoUrl: json['photoUrl'] as String?,
      roomLinks: (json['roomLinks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isPredicted: json['isPredicted'] as bool? ?? false,
      // 아래 필드들은 이전 버전 백업 JSON엔 없다 — 없으면 기존 기본값.
      repeatConfig: json['repeatConfig'] is Map
          ? RepeatConfig.fromJson(Map<String, dynamic>.from(json['repeatConfig'] as Map))
          : null,
      repeat: json['repeat'] as bool? ?? false,
      calendarSync: json['calendarSync'] is Map
          ? CalendarSyncFlags.fromJson(Map<String, dynamic>.from(json['calendarSync'] as Map))
          : const CalendarSyncFlags(),
      examTimeline: (json['examTimeline'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => ExamTimelineEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      deadlineTime: _timeFromJson(json['deadlineTime']),
      endDeadlineTime: _timeFromJson(json['endDeadlineTime']),
    );
  }
}
