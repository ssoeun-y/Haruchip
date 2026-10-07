import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/categories/models/exam_model.dart';
import 'package:haruchip/features/categories/providers/category_provider.dart';
import 'package:haruchip/features/categories/screens/category_detail_screen.dart';

/// 시험 카테고리 상세 화면이 주요 기기 폭에서 RenderFlex 오버플로우 없이 그려지는지.
/// 요약바 + 자격증(다단계 파이프라인) 카드 + 중간고사(과목 타임테이블) 카드를 모두 띄운다.
const _widths = <String, double>{
  '갤럭시 폴드 커버': 344,
  'iPhone SE': 375,
  'iPhone Pro Max': 430,
  '갤럭시 폴드 펼침': 674,
};

List<ExamProfile> _exams() {
  final now = DateTime.now();
  return [
    ExamProfile(
      id: 'q1',
      title: '2026 정보처리기사 실기 3회차 (산업인력공단)',
      type: ExamType.qualification,
      stages: [
        ExamStageItem(
          id: 'q1-a',
          stageType: ExamStageType.application,
          name: '원서접수 (인터넷 접수 마감일 18시까지)',
          startDate: now.add(const Duration(days: 3)),
          endDate: now.add(const Duration(days: 6)),
          testTime: '09:00 입실완료',
          location: '서울 강남구 공단 서울지역본부 시험장',
          seatNumber: '24번',
          registrationNumber: '26123456789',
          checklist: const ['신분증', '수험표', '검정 볼펜', '공학용 계산기'],
        ),
        ExamStageItem(
          id: 'q1-b',
          stageType: ExamStageType.writtenTest,
          name: '1차 필기시험',
          startDate: now.add(const Duration(days: 30)),
        ),
      ],
    ),
    ExamProfile(
      id: 'm1',
      title: '2학기 중간고사',
      type: ExamType.midterm,
      subjects: [
        ExamSubjectItem(
          id: 'm1-1',
          subjectName: '데이터베이스론 및 실습',
          examDate: now.add(const Duration(days: 10)),
          period: 1,
          startTime: '09:00',
          endTime: '10:30',
          classroom: '인문관 301호 대형강의실',
          seatNumber: '24번',
          checklist: const ['공학용 계산기', '컴싸', '학생증'],
          memo: '범위: 1단원 ~ 4단원, 정규화/트랜잭션 집중',
        ),
      ],
    ),
  ];
}

void main() {
  for (final entry in _widths.entries) {
    testWidgets('시험 상세 화면 ${entry.key}(${entry.value.toInt()}) 폭 오버플로우 없음', (tester) async {
      await tester.binding.setSurfaceSize(Size(entry.value, 3200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(categoryListProvider.notifier);
      final created = notifier.addCategory(categoryKey: 'exam', name: '자격증', emoji: '📚', colorHex: '#4F46E5');
      final category = created.copyWith(metadata: {
        'isInitialized': true,
        'exams': _exams().map((e) => e.toJson()).toList(),
      });
      notifier.updateCategory(category);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: CategoryDetailScreen(category: category)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('시험 파이프라인 관리'), findsOneWidget);
      expect(find.textContaining('정보처리기사'), findsWidgets);
      expect(find.textContaining('중간고사'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
