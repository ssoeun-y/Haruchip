import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/onboarding/screens/calendar_integration_screen.dart';
import 'package:haruchip/features/onboarding/screens/category_selection_screen.dart';

void main() {
  testWidgets('카테고리를 1개 이상 고르기 전에는 다음 단계로 이동하지 않는다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CategorySelectionScreen()),
      ),
    );

    expect(find.text('카테고리를 1개 이상 선택해주세요'), findsOneWidget);
    expect(find.byType(CalendarIntegrationScreen), findsNothing);
  });

  testWidgets('카테고리를 고르고 다음을 누르면 캘린더 연동 선택 화면으로 실제 이동한다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CategorySelectionScreen()),
      ),
    );

    await tester.tap(find.text('커플'));
    await tester.pump();

    await tester.tap(find.text('다음 (1개 선택)'));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarIntegrationScreen), findsOneWidget);
  });
}
