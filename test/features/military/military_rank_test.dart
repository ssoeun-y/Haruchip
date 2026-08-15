import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/military/models/military_rank.dart';

void main() {
  final enlist = DateTime(2024, 3, 10);

  group('currentRank', () {
    test('입대일에는 이병', () {
      expect(currentRank(enlist, today: enlist), MilitaryRank.private);
    });

    test('2개월차 시작일에 일병으로 진급', () {
      expect(
        currentRank(enlist, today: DateTime(2024, 5, 10)),
        MilitaryRank.privateFirstClass,
      );
      // 진급 하루 전은 아직 이병.
      expect(
        currentRank(enlist, today: DateTime(2024, 5, 9)),
        MilitaryRank.private,
      );
    });

    test('8개월차 시작일에 상병으로 진급', () {
      expect(
        currentRank(enlist, today: DateTime(2024, 11, 10)),
        MilitaryRank.corporal,
      );
    });

    test('14개월차 시작일에 병장으로 진급하고 그 이후로도 계속 병장', () {
      expect(
        currentRank(enlist, today: DateTime(2025, 5, 10)),
        MilitaryRank.sergeant,
      );
      expect(
        currentRank(enlist, today: DateTime(2026, 1, 1)),
        MilitaryRank.sergeant,
      );
    });
  });

  group('nextRankMilestone', () {
    test('이병 구간에서는 다음 진급(일병) 시점을 돌려준다', () {
      final milestone = nextRankMilestone(enlist, today: enlist);
      expect(milestone, isNotNull);
      expect(milestone!.rank, MilitaryRank.privateFirstClass);
      expect(milestone.startDate, DateTime(2024, 5, 10));
    });

    test('병장이 되면 더 이상 진급이 없어 null', () {
      final milestone =
          nextRankMilestone(enlist, today: DateTime(2025, 5, 10));
      expect(milestone, isNull);
    });
  });

  group('defaultDischargeDate', () {
    test('군종별 총 복무기간(§5.3)만큼 입대일에 더한다', () {
      expect(
        defaultDischargeDate(enlist, MilitaryBranch.army),
        DateTime(2025, 9, 10),
      );
      expect(
        defaultDischargeDate(enlist, MilitaryBranch.navy),
        DateTime(2025, 11, 10),
      );
      expect(
        defaultDischargeDate(enlist, MilitaryBranch.airForce),
        DateTime(2025, 12, 10),
      );
    });
  });
}
