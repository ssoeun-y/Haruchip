import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/onboarding/providers/calendar_integration_provider.dart';

void main() {
  group('calendarIntegrationProvider', () {
    test('초기 상태는 빈 집합이다 (하루칩 자체 캘린더는 항상 켜져 있어 선택지에 없음)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(calendarIntegrationProvider), isEmpty);
    });

    test('toggle 호출 시 없으면 추가하고 있으면 제거한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarIntegrationProvider.notifier);

      notifier.toggle('google');
      expect(container.read(calendarIntegrationProvider), {'google'});

      notifier.toggle('naver');
      expect(container.read(calendarIntegrationProvider), {'google', 'naver'});

      notifier.toggle('google');
      expect(container.read(calendarIntegrationProvider), {'naver'});
    });

    test('0개 선택 상태(연동 없이 계속)도 유효한 상태다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(calendarIntegrationProvider.notifier);

      notifier.toggle('google');
      notifier.toggle('google');

      expect(container.read(calendarIntegrationProvider), isEmpty);
      expect(notifier.isSelected('google'), isFalse);
    });
  });
}
