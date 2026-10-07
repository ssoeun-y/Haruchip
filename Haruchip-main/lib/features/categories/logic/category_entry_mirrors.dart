import 'package:flutter/material.dart';

import '../../plan/models/plan_item.dart';
import '../../professional/models/appointment_model.dart';
import '../../professional/models/goal_model.dart';
import '../../professional/widgets/add_appointment_modal.dart';
import '../../professional/widgets/add_goal_modal.dart';
import '../../professional/widgets/add_routine_modal.dart';
import '../models/birthday_profile.dart';
import '../models/exam_model.dart';
import '../widgets/add_exam_modal.dart';
import '../widgets/birthday_friend_modal.dart';

// 카테고리 metadata 항목(목표/약속/생일친구/시험)이 메인 캘린더에 보이도록
// 만드는 "미러" PlanItem 규칙. 카테고리 상세 화면과 "카테고리 첫 추가"
// 흐름이 같은 규칙을 쓰도록 한곳에 둔다.

/// 목표 — 캘린더 표시를 켰고 마감일이 있을 때만.
PlanItem? goalMirror(GoalItem g, String categoryId) {
  if (!g.showInCalendar || g.deadline == null) return null;
  return PlanItem(
    id: g.id,
    title: g.title,
    date: g.deadline!,
    categoryKey: 'goal',
    categoryInstanceId: categoryId,
    repeat: false,
  );
}

PlanItem appointmentMirror(AppointmentItem a, String categoryId) {
  return PlanItem(
    id: a.id,
    title: a.title,
    date: a.date,
    categoryKey: 'plan',
    categoryInstanceId: categoryId,
    repeat: false,
  );
}

PlanItem birthdayMirror(BirthdayProfile f, String categoryId) {
  return PlanItem(
    id: f.id,
    title: '${f.name} 생일',
    date: f.nextBirthdayDate(),
    categoryKey: 'birthday',
    categoryInstanceId: categoryId,
    repeat: true,
    photoUrl: f.photoUrl,
  );
}

/// 시험 — 중간/기말은 과목별, 자격증 등은 (아직 안 끝났거나 시험일인) 단계별.
List<PlanItem> examMirrors(ExamProfile exam, String categoryId) {
  if (!exam.showInMainCalendar) return const [];
  if (exam.type == ExamType.midterm || exam.type == ExamType.finalExam) {
    return [
      for (final sub in exam.subjects)
        PlanItem(
          id: 'exam-plan-${sub.id}',
          title: '[${exam.title}] ${sub.period}교시 ${sub.subjectName}',
          date: sub.examDate,
          categoryKey: 'exam',
          categoryInstanceId: categoryId,
          repeat: false,
        ),
    ];
  }
  return [
    for (final stage in exam.stages)
      if (!stage.isEnded() || stage.stageType.isExamDay)
        PlanItem(
          id: 'exam-plan-${stage.id}',
          title: '[${exam.title}] ${stage.name}',
          date: stage.startDate,
          categoryKey: 'exam',
          categoryInstanceId: categoryId,
          repeat: false,
        ),
  ];
}

/// 카테고리를 처음 추가할 때 받은 첫 항목.
class FirstCategoryEntry {
  const FirstCategoryEntry({
    required this.metaKey,
    required this.json,
    required this.mirrors,
  });

  /// 카테고리 metadata 안의 목록 키 ('goals', 'appointments', ...)
  final String metaKey;
  final Map<String, dynamic> json;
  final List<PlanItem> mirrors;
}

/// 첫 항목 입력창이 있는 카테고리 타입 — 카테고리 상세 화면에서 "+ 추가"로
/// 여는 것과 똑같은 입력창을 쓴다.
const Set<String> kCategoryKeysWithFirstEntryForm = {
  'plan',
  'goal',
  'routine',
  'exam',
  'birthday',
};

/// [categoryKey]에 맞는 항목 입력창을 띄운다. 입력창이 빈 제목/이름을 이미
/// "입력해주세요"로 막으므로, 돌아온 값이 있으면 내용이 채워진 것이다.
/// 사용자가 닫으면 null.
Future<FirstCategoryEntry?> showFirstEntryFormForCategory(
  BuildContext context, {
  required String categoryKey,
  required String categoryId,
}) async {
  switch (categoryKey) {
    case 'plan':
      final a = await showAddAppointmentModal(context);
      return a == null
          ? null
          : FirstCategoryEntry(metaKey: 'appointments', json: a.toJson(), mirrors: [appointmentMirror(a, categoryId)]);
    case 'goal':
      final g = await showAddGoalModal(context);
      if (g == null) return null;
      final mirror = goalMirror(g, categoryId);
      return FirstCategoryEntry(metaKey: 'goals', json: g.toJson(), mirrors: [if (mirror != null) mirror]);
    case 'routine':
      final r = await showAddRoutineModal(context);
      return r == null ? null : FirstCategoryEntry(metaKey: 'routines', json: r.toJson(), mirrors: const []);
    case 'exam':
      final e = await showAddExamModal(context);
      return e == null ? null : FirstCategoryEntry(metaKey: 'exams', json: e.toJson(), mirrors: examMirrors(e, categoryId));
    case 'birthday':
      final f = await showBirthdayFriendModal(context);
      return f == null
          ? null
          : FirstCategoryEntry(metaKey: 'friends', json: f.toJson(), mirrors: [birthdayMirror(f, categoryId)]);
    default:
      return null;
  }
}
