import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/onboarding/screens/dashboard_view_mode_screen.dart';
import 'package:haruchip/features/onboarding/screens/onboarding_complete_screen.dart';

void main() {
  testWidgets('뷰모드를 고르기 전에는 다음 단계로 이동하지 않는다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DashboardViewModeScreen()),
      ),
    );

    expect(find.text('뷰모드를 선택해주세요'), findsOneWidget);
    expect(find.byType(OnboardingCompleteScreen), findsNothing);
  });

  testWidgets('세로 정렬 스와이프형을 고르고 다음을 누르면 완료 화면으로 실제 이동한다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: DashboardViewModeScreen()),
      ),
    );

    await tester.tap(find.text('세로 정렬 스와이프형'));
    await tester.pump();

    await tester.tap(find.text('다음으로'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingCompleteScreen), findsOneWidget);
  });

  testWidgets('박스형 대시보드를 고르면 세로 정렬 선택이 해제된다 (라디오형 단일 선택)', (tester) async {
    var nextCalled = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DashboardViewModeScreen(onNext: () => nextCalled = true),
        ),
      ),
    );

    await tester.tap(find.text('세로 정렬 스와이프형'));
    await tester.pump();
    await tester.tap(find.text('박스형 대시보드'));
    await tester.pump();

    await tester.tap(find.text('다음으로'));
    await tester.pump();

    expect(nextCalled, isTrue);
  });
}
