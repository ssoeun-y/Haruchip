import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/onboarding/screens/calendar_integration_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    VoidCallback? onNext,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CalendarIntegrationScreen(onNext: onNext),
        ),
      ),
    );
  }

  testWidgets('구글/네이버 카드를 하나도 선택하지 않아도 다음으로 진행할 수 있다', (tester) async {
    var nextCalled = false;
    await pumpScreen(tester, onNext: () => nextCalled = true);

    expect(find.text('연동 없이 계속하기'), findsOneWidget);

    await tester.tap(find.text('연동 없이 계속하기'));
    await tester.pump();

    expect(nextCalled, isTrue);
  });

  testWidgets('카드를 선택하면 선택 개수가 버튼 문구에 반영된다', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('구글 캘린더'));
    await tester.pump();

    expect(find.text('다음 (1개 연동)'), findsOneWidget);

    await tester.tap(find.text('네이버 캘린더'));
    await tester.pump();

    expect(find.text('다음 (2개 연동)'), findsOneWidget);
  });

  testWidgets('하루칩 자체 캘린더는 항상 켜져 있다는 안내가 노출된다', (tester) async {
    await pumpScreen(tester);

    expect(find.text('하루칩 캘린더는 항상 켜져 있어요'), findsOneWidget);
  });
}
