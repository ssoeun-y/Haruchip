import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/onboarding/screens/calendar_integration_screen.dart';

/// (2부 갱신) 이 화면은 더 이상 온보딩 스텝이 아니라 캘린더 탭의
/// "연동 설정" 버튼으로 열리는 설정 화면이다 — `onNext` 콜백이 사라지고
/// 뒤로가기 가능한 화면(하단 CTA는 그냥 닫는 "확인")이 됐다.
void main() {
  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CalendarIntegrationScreen()),
      ),
    );
  }

  testWidgets('구글/네이버 카드를 하나도 선택하지 않아도 확인 버튼으로 닫을 수 있다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CalendarIntegrationScreen(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('확인'), findsOneWidget);
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarIntegrationScreen), findsNothing);
  });

  testWidgets('카드를 탭하면 선택 상태(체크 아이콘)로 바뀐다', (tester) async {
    await pumpScreen(tester);

    // "하루칩 캘린더는 항상 켜져 있어요" 안내에도 같은 아이콘이 쓰이므로
    // findsNothing이 아니라 탭 전후 개수 차이(+1)로 확인한다.
    final before = find.byIcon(Icons.check_circle_rounded).evaluate().length;

    await tester.tap(find.text('구글 캘린더'));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle_rounded).evaluate().length, before + 1);
  });

  testWidgets('하루칩 자체 캘린더는 항상 켜져 있다는 안내가 노출된다', (tester) async {
    await pumpScreen(tester);

    expect(find.text('하루칩 캘린더는 항상 켜져 있어요'), findsOneWidget);
  });
}
