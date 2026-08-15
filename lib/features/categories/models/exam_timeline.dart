import 'package:flutter/foundation.dart';

/// 시험 카테고리 타임라인 단계 — 핸드오프 문서 §5.4 "접수→필기→합격발표→
/// 실기→최종합격 세로 트리".
enum ExamStage {
  application,
  writtenTest,
  writtenResult,
  practicalTest,
  finalResult;

  /// 화면에 노출할 한글 라벨.
  String get labelKo => switch (this) {
        ExamStage.application => '접수',
        ExamStage.writtenTest => '필기',
        ExamStage.writtenResult => '합격발표',
        ExamStage.practicalTest => '실기',
        ExamStage.finalResult => '최종합격',
      };

  /// "시험일"(실제로 시험을 치르는 날)인지 여부 — §5.4 "시험일=메인
  /// 강조색(진하고 굵게), 접수/발표일=서브색(연하고 얇게)" 구분에 쓴다.
  /// 필기/실기만 시험일이고, 접수/합격발표/최종합격은 행정 일정이라
  /// 서브 취급한다.
  bool get isMainExamDay =>
      this == ExamStage.writtenTest || this == ExamStage.practicalTest;
}

/// 타임라인 단계 1건 — 사용자가 디데이 추가 폼에서 선택적으로 입력한다.
/// 5단계 모두 입력할 필요는 없다(입력한 단계만 리스트에 담김).
@immutable
class ExamTimelineEntry {
  const ExamTimelineEntry({required this.stage, required this.date});

  final ExamStage stage;
  final DateTime date;
}
