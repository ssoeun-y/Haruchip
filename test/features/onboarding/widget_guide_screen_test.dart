import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/onboarding/screens/widget_guide_screen.dart';

/// (2부 갱신) 이 화면은 더 이상 온보딩 마지막 단계가 아니라 설정 모달의
/// "홈 화면 위젯 가이드 → 보기"로 열리는 안내 화면이다 — `onComplete`
/// 콜백이 사라지고 뒤로가기 가능한 화면(하단 CTA는 그냥 닫는 "확인")이 됐다.
void main() {
  testWidgets('안내 문구가 노출된다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: WidgetGuideScreen()),
    );

    expect(find.text('홈 화면에 하루칩\n위젯을 추가해보세요'), findsOneWidget);
  });

  testWidgets('확인 버튼을 누르면 화면이 닫힌다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WidgetGuideScreen()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    expect(find.byType(WidgetGuideScreen), findsNothing);
  });
}
