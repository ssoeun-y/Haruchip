import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/onboarding/screens/category_selection_screen.dart';
import 'package:haruchip/features/onboarding/screens/login_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, {VoidCallback? onNext}) {
    return tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: LoginScreen(onNext: onNext)),
      ),
    );
  }

  testWidgets('카카오/애플/구글 로그인 버튼 3개가 모두 노출된다', (tester) async {
    await pumpScreen(tester);

    expect(find.text('카카오로 시작하기'), findsOneWidget);
    expect(find.text('애플로 시작하기'), findsOneWidget);
    expect(find.text('구글로 시작하기'), findsOneWidget);
  });

  testWidgets('카카오 버튼을 누르면 다음 단계로 진행한다', (tester) async {
    var nextCalled = false;
    await pumpScreen(tester, onNext: () => nextCalled = true);

    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pump();

    expect(nextCalled, isTrue);
  });

  testWidgets('애플 버튼을 누르면 다음 단계로 진행한다', (tester) async {
    var nextCalled = false;
    await pumpScreen(tester, onNext: () => nextCalled = true);

    await tester.tap(find.text('애플로 시작하기'));
    await tester.pump();

    expect(nextCalled, isTrue);
  });

  testWidgets('구글 버튼을 누르면 다음 단계로 진행한다', (tester) async {
    var nextCalled = false;
    await pumpScreen(tester, onNext: () => nextCalled = true);

    await tester.tap(find.text('구글로 시작하기'));
    await tester.pump();

    expect(nextCalled, isTrue);
  });

  testWidgets('onNext 없이 버튼을 누르면 카테고리 선택 화면으로 실제 이동한다', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('구글로 시작하기'));
    await tester.pumpAndSettle();

    expect(find.byType(CategorySelectionScreen), findsOneWidget);
  });
}
