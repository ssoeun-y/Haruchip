// 앱 최상위 스모크 테스트: 온보딩 진입점이 크래시 없이 뜨는지만 확인한다.
// (이전 버전은 flutter create 기본 카운터 템플릿을 그대로 남긴 것으로,
// 존재하지 않는 MyApp을 참조해 컴파일이 깨져 있었다.)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:haruchip/main.dart';

void main() {
  testWidgets('앱 진입 시 온보딩 카테고리 선택 화면이 뜬다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HaruChipApp()),
    );

    expect(find.text('관심있는 카테고리를\n골라주세요'), findsOneWidget);
  });
}
