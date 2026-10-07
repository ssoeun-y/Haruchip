import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/categories/providers/category_provider.dart';
import 'package:haruchip/features/home/widgets/add_category_dashboard_modal.dart';
import 'package:haruchip/features/plan/providers/plan_provider.dart';

/// 대시보드 "+ 새 카테고리 추가" 흐름:
/// 카테고리 설정 → (내용 입력 시트가 있는 타입은) 내용 입력·저장 → 그때 추가.
Future<ProviderContainer> _openModal(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAddCategoryDashboardModal(context),
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('내용 시트를 저장 없이 닫으면 카테고리가 추가되지 않는다', (tester) async {
    final c = await _openModal(tester);

    await tester.tap(find.text('직접 설정하기'));
    await tester.pumpAndSettle();
    expect(find.text('다음: 내용 입력하기'), findsOneWidget);

    await tester.tap(find.text('다음: 내용 입력하기'));
    await tester.pumpAndSettle();
    expect(find.text('나만의 카테고리 직접 설정'), findsOneWidget);
    expect(c.read(categoryListProvider), isEmpty, reason: '시트가 열린 시점엔 아직 추가 전');

    await tester.tap(find.byIcon(Icons.close).last); // 시트의 X
    await tester.pumpAndSettle();

    expect(c.read(categoryListProvider), isEmpty);
    expect(find.text('내용을 입력하고 저장해야 카테고리가 추가돼요.'), findsOneWidget);
    expect(find.text('다음: 내용 입력하기'), findsOneWidget, reason: '설정 화면으로 돌아와 다시 시도 가능');
  });

  testWidgets('내용 시트에서 저장하면 그때 내용이 채워진 카테고리가 추가된다', (tester) async {
    final c = await _openModal(tester);

    await tester.tap(find.text('직접 설정하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음: 내용 입력하기'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('설정 완료'));
    await tester.tap(find.text('설정 완료'));
    await tester.pumpAndSettle();

    final cats = c.read(categoryListProvider);
    expect(cats.length, 1);
    expect(cats.single.categoryKey, 'custom');
    expect(cats.single.metadata?['isInitialized'], isTrue);
    expect(find.text('다음: 내용 입력하기'), findsNothing, reason: '추가 모달도 닫힌다');
  });

  testWidgets('일정 카테고리: 첫 일정 입력창이 뜨고, 제목이 비면 "입력해주세요"로 막힌다', (tester) async {
    final c = await _openModal(tester);

    await tester.tap(find.text('일정 / 약속'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음: 내용 입력하기'));
    await tester.pumpAndSettle();

    // 카테고리 안 "+ 추가"와 같은 일정 입력창
    expect(find.text('일정 등록하기'), findsOneWidget);

    await tester.ensureVisible(find.text('일정 등록하기'));
    await tester.tap(find.text('일정 등록하기'));
    await tester.pumpAndSettle();

    expect(find.text('⚠️ 일정 제목을 입력해주세요.'), findsOneWidget);
    expect(c.read(categoryListProvider), isEmpty);
  });

  testWidgets('일정 카테고리: 첫 일정을 등록하면 그 일정과 함께 카테고리가 추가된다', (tester) async {
    final c = await _openModal(tester);

    await tester.tap(find.text('일정 / 약속'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음: 내용 입력하기'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, '예: 팀 디자인 싱크 미팅, 동창 저녁 약속'), '동창 저녁 약속');
    await tester.ensureVisible(find.text('일정 등록하기'));
    await tester.tap(find.text('일정 등록하기'));
    await tester.pumpAndSettle();

    final cat = c.read(categoryListProvider).single;
    expect(cat.categoryKey, 'plan');
    final appts = cat.metadata!['appointments'] as List;
    expect(appts.length, 1, reason: '샘플 일정이 섞이지 않고 입력한 일정 하나만');
    expect(appts.single['title'], '동창 저녁 약속');
    // 메인 캘린더에도 보인다
    expect(
      c.read(planListProvider).where((p) => p.categoryInstanceId == cat.id).single.title,
      '동창 저녁 약속',
    );
    expect(find.text('다음: 내용 입력하기'), findsNothing);
  });

  testWidgets('일정 카테고리: 입력창을 그냥 닫으면 추가되지 않는다', (tester) async {
    final c = await _openModal(tester);

    await tester.tap(find.text('일정 / 약속'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음: 내용 입력하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded).last); // 일정 입력창의 X
    await tester.pumpAndSettle();

    expect(c.read(categoryListProvider), isEmpty);
    expect(find.text('내용을 입력하고 저장해야 카테고리가 추가돼요.'), findsOneWidget);
  });

  testWidgets('커플은 기존처럼 바로 추가된다 (관계 설정은 카드 진입 시)', (tester) async {
    final c = await _openModal(tester);

    await tester.tap(find.text('커플'));
    await tester.pumpAndSettle();
    expect(find.text('추가하기'), findsOneWidget);
    await tester.tap(find.text('추가하기'));
    await tester.pumpAndSettle();

    expect(c.read(categoryListProvider).single.categoryKey, 'couple');
  });
}
