import 'package:flutter/foundation.dart';

/// 디데이 항목의 반복 종류. 명세 §1 `DdayItem.repeat.type`
/// (none/weekly/yearly/monthly)을 그대로 옮겼다.
enum RepeatType { none, daily, weekly, monthly, yearly }

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 반복 설정 1건. [weekdays]는 [type]이 [RepeatType.weekly]일 때,
/// [daysOfMonth]는 [RepeatType.monthly]일 때(1~31),
/// [daysOfYear]는 [RepeatType.yearly]일 때("MM-DD" 포맷) 쓰인다.
@immutable
class RepeatConfig {
  const RepeatConfig({
    this.type = RepeatType.none,
    this.weekdays = const [],
    this.daysOfMonth = const [],
    this.daysOfYear = const [],
  });

  /// 반복 없음 — 기본값.
  static const RepeatConfig none = RepeatConfig();

  /// 생일 카테고리 기본값
  static const RepeatConfig yearlyDefault = RepeatConfig(type: RepeatType.yearly);

  final RepeatType type;
  final List<int> weekdays;
  final List<int> daysOfMonth;
  final List<String> daysOfYear;

  bool get isRepeating => type != RepeatType.none;

  RepeatConfig copyWith({
    RepeatType? type,
    List<int>? weekdays,
    List<int>? daysOfMonth,
    List<String>? daysOfYear,
  }) {
    return RepeatConfig(
      type: type ?? this.type,
      weekdays: weekdays ?? this.weekdays,
      daysOfMonth: daysOfMonth ?? this.daysOfMonth,
      daysOfYear: daysOfYear ?? this.daysOfYear,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'weekdays': weekdays,
        'daysOfMonth': daysOfMonth,
        'daysOfYear': daysOfYear,
      };

  factory RepeatConfig.fromJson(Map<String, dynamic> json) {
    List<int> ints(Object? v) =>
        (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [];
    return RepeatConfig(
      type: RepeatType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RepeatType.none,
      ),
      weekdays: ints(json['weekdays']),
      daysOfMonth: ints(json['daysOfMonth']),
      daysOfYear:
          (json['daysOfYear'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

/// [baseDate] 기준으로 [config]의 규칙을 적용했을 때, [from](기본값 오늘)
/// **이후** 첫 발생일을 계산한다. 반복이 없으면 [baseDate]를 그대로
/// 돌려준다(과거여도 그대로 — dDayLabel이 D+n으로 표시).
///
/// 캘린더/plan 탭 등 다른 화면에서도 재사용할 수 있도록 순수 함수로
/// 뺐다(부작용 없음, DateTime만 입출력).
DateTime nextOccurrence(
  DateTime baseDate,
  RepeatConfig config, {
  DateTime? from,
}) {
  final today = _dateOnly(from ?? DateTime.now());
  final base = _dateOnly(baseDate);

  switch (config.type) {
    case RepeatType.none:
      return base;

    case RepeatType.daily:
      return base.isAfter(today) ? base : today;

    case RepeatType.yearly:
      if (config.daysOfYear.isEmpty) {
        var next = DateTime(today.year, base.month, base.day);
        if (next.isBefore(today)) {
          next = DateTime(today.year + 1, base.month, base.day);
        }
        return next;
      } else {
        DateTime? closest;
        for (final doy in config.daysOfYear) {
          final parts = doy.split('-');
          if (parts.length != 2) continue;
          final m = int.tryParse(parts[0]) ?? 1;
          final d = int.tryParse(parts[1]) ?? 1;
          var next = DateTime(today.year, m, d);
          if (next.isBefore(today)) next = DateTime(today.year + 1, m, d);
          if (closest == null || next.isBefore(closest)) closest = next;
        }
        return closest ?? base;
      }

    case RepeatType.monthly:
      if (config.daysOfMonth.isEmpty) {
        var next = DateTime(today.year, today.month, base.day);
        if (next.isBefore(today)) {
          next = DateTime(next.year, next.month + 1, base.day);
        }
        return next;
      } else {
        DateTime? closest;
        for (final dom in config.daysOfMonth) {
          var next = DateTime(today.year, today.month, dom);
          if (next.isBefore(today)) next = DateTime(next.year, next.month + 1, dom);
          if (closest == null || next.isBefore(closest)) closest = next;
        }
        return closest ?? base;
      }

    case RepeatType.weekly:
      if (config.weekdays.isEmpty) return base;
      // today부터 최대 7일 안에서 config.weekdays에 속하는 가장 가까운
      // 날짜를 찾는다(오늘 포함).
      for (var i = 0; i < 7; i++) {
        final candidate = today.add(Duration(days: i));
        if (config.weekdays.contains(candidate.weekday)) {
          return candidate;
        }
      }
      return base;
  }
}
