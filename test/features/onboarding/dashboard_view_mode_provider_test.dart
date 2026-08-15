import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/onboarding/providers/dashboard_view_mode_provider.dart';

void main() {
  group('dashboardViewModeProvider', () {
    test('초기 상태는 null이다 (아직 아무것도 선택 안 함)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(dashboardViewModeProvider), isNull);
      expect(container.read(canProceedFromDashboardViewModeProvider), isFalse);
    });

    test('select 호출 시 단일 값으로 상태가 바뀐다 (라디오형, 이전 선택은 대체됨)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(dashboardViewModeProvider.notifier);

      notifier.select('vertical');
      expect(container.read(dashboardViewModeProvider), 'vertical');
      expect(notifier.isSelected('vertical'), isTrue);
      expect(notifier.isSelected('box'), isFalse);

      notifier.select('box');
      expect(container.read(dashboardViewModeProvider), 'box');
      expect(notifier.isSelected('vertical'), isFalse);
      expect(notifier.isSelected('box'), isTrue);
    });

    test('하나라도 선택하면 다음 단계로 진행할 수 있다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(dashboardViewModeProvider.notifier).select('vertical');

      expect(container.read(canProceedFromDashboardViewModeProvider), isTrue);
    });
  });
}
