import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/couple/models/couple_relationship.dart';
import 'package:haruchip/features/couple/providers/couple_provider.dart';

void main() {
  group('coupleProvider', () {
    test('초기 상태는 mock 데이터(재회 이력 없음)이다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final couple = container.read(coupleProvider);
      expect(couple.reunions, isEmpty);
      expect(container.read(isCurrentlyOnBreakProvider), isFalse);
      expect(container.read(daysSinceReuniteProvider), isNull);
    });

    test('totalDaysTogetherProvider는 (오늘-시작일)에서 이별기간을 뺀 값이다', () {
      final container = ProviderContainer(
        overrides: [
          coupleProvider.overrideWith(() => _FixedCoupleNotifier(
                CoupleRelationship(
                  startDate: DateTime.now().subtract(const Duration(days: 100)),
                  partnerName: '테스트',
                  partnerIcon: '🐶',
                  reunions: [
                    ReunionPeriod(
                      breakupDate:
                          DateTime.now().subtract(const Duration(days: 50)),
                      reuniteDate:
                          DateTime.now().subtract(const Duration(days: 40)),
                    ),
                  ],
                ),
              )),
        ],
      );
      addTearDown(container.dispose);

      // 100일 중 이별기간 10일을 뺀 90일이어야 한다.
      expect(container.read(totalDaysTogetherProvider), 90);
    });

    test('addBreakup: 역전된 날짜(직전 이벤트보다 이르거나 같음)는 거부하고 false를 반환한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(coupleProvider.notifier);
      final startDate = container.read(coupleProvider).startDate;

      final ok = notifier.addBreakup(
        startDate.subtract(const Duration(days: 1)),
      );

      expect(ok, isFalse);
      expect(container.read(coupleProvider).reunions, isEmpty);
    });

    test('addBreakup 성공 후 addReunite 성공 시 상태가 반영된다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(coupleProvider.notifier);
      final startDate = container.read(coupleProvider).startDate;

      final breakupDate = startDate.add(const Duration(days: 10));
      final reuniteDate = startDate.add(const Duration(days: 20));

      expect(notifier.addBreakup(breakupDate), isTrue);
      expect(container.read(isCurrentlyOnBreakProvider), isTrue);

      expect(notifier.addReunite(reuniteDate), isTrue);
      expect(container.read(isCurrentlyOnBreakProvider), isFalse);
      expect(container.read(coupleProvider).reunions.single.reuniteDate,
          reuniteDate);
    });

    test('addReunite: 이별 중이 아니면 거부한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(coupleProvider.notifier);
      final startDate = container.read(coupleProvider).startDate;

      final ok = notifier.addReunite(startDate.add(const Duration(days: 5)));

      expect(ok, isFalse);
    });

    test('isPendingDeletion: 재회 없이 30일 초과하면 true', () {
      final period = ReunionPeriod(
        breakupDate: DateTime.now().subtract(const Duration(days: 31)),
      );
      expect(period.isPendingDeletion, isTrue);

      final recent = ReunionPeriod(
        breakupDate: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(recent.isPendingDeletion, isFalse);
    });

    test('upcomingAnniversariesProvider는 아직 지나지 않은 기념일을 날짜 오름차순으로 반환한다', () {
      final container = ProviderContainer(
        overrides: [
          coupleProvider.overrideWith(() => _FixedCoupleNotifier(
                CoupleRelationship(
                  startDate: DateTime.now().subtract(const Duration(days: 99)),
                  partnerName: '테스트',
                  partnerIcon: '🐶',
                ),
              )),
        ],
      );
      addTearDown(container.dispose);

      final list = container.read(upcomingAnniversariesProvider);

      expect(list, isNotEmpty);
      expect(list.first.label, '100일');
      for (var i = 1; i < list.length; i++) {
        expect(
          list[i].date.isAfter(list[i - 1].date) ||
              list[i].date.isAtSameMomentAs(list[i - 1].date),
          isTrue,
        );
      }
      expect(list.every((m) => m.dDay >= 0), isTrue);
    });
  });
}

/// 테스트에서 고정된 CoupleRelationship으로 시작하기 위한 override용 Notifier.
class _FixedCoupleNotifier extends CoupleNotifier {
  _FixedCoupleNotifier(this._initial);

  final CoupleRelationship _initial;

  @override
  CoupleRelationship build() => _initial;
}
