import 'package:flutter/foundation.dart';

/// 디데이 항목의 반복 종류. 명세 §1 `DdayItem.repeat.type`
/// (none/weekly/yearly/monthly)을 그대로 옮겼다.
enum RepeatType { none, weekly, monthly, yearly }

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 반복 설정 1건. [weekdays]는 [type]이 [RepeatType.weekly]일 때만
/// 쓰이고, `DateTime.weekday` 값(1=월요일 ~ 7=일요일)을 그대로 담는다.
@immutable
class RepeatConfig {
  const RepeatConfig({this.type = RepeatType.none, this.weekdays = const []});

  /// 반복 없음 — 기본값.
  static const RepeatConfig none = RepeatConfig();

  /// 생일 카테고리 기본값(§5.2 "카테고리 생성 시 repeat.type=yearly 기본
  /// 활성화") — 폼이 이 상수를 초기값으로 쓴다.
  static const RepeatConfig yearlyDefault = RepeatConfig(type: RepeatType.yearly);

  final RepeatType type;
  final List<int> weekdays;

  bool get isRepeating => type != RepeatType.none;

  RepeatConfig copyWith({RepeatType? type, List<int>? weekdays}) {
    return RepeatConfig(
      type: type ?? this.type,
      weekdays: weekdays ?? this.weekdays,
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

    case RepeatType.yearly:
      var next = DateTime(today.year, base.month, base.day);
      if (next.isBefore(today)) {
        next = DateTime(today.year + 1, base.month, base.day);
      }
      return next;

    case RepeatType.monthly:
      var next = DateTime(today.year, today.month, base.day);
      if (next.isBefore(today)) {
        next = DateTime(next.year, next.month + 1, base.day);
      }
      return next;

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
