import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haruchip/features/categories/logic/repeat_rule.dart';
import 'package:haruchip/features/categories/models/exam_timeline.dart';
import 'package:haruchip/features/categories/providers/category_provider.dart';
import 'package:haruchip/features/couple/models/couple_relationship.dart';
import 'package:haruchip/features/couple/providers/couple_provider.dart';
import 'package:haruchip/features/plan/data/plan_mock_data.dart';
import 'package:haruchip/features/plan/models/plan_item.dart';
import 'package:haruchip/features/plan/providers/plan_provider.dart';
import 'package:haruchip/features/trash/models/trash_item.dart';
import 'package:haruchip/features/trash/providers/trash_provider.dart';
import 'package:haruchip/services/storage/local_store.dart';

/// 같은 [store]로 새 컨테이너를 만든다 = 앱 재시작 시뮬레이션.
ProviderContainer _boot(LocalStore store) {
  final c = ProviderContainer(overrides: [localStoreProvider.overrideWithValue(store)]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('PlanItem JSON', () {
    test('반복/시간/외부동기화/시험타임라인까지 손실 없이 왕복한다', () {
      final item = PlanItem(
        id: 'p1',
        title: '정처기 필기',
        date: DateTime(2026, 2, 28),
        categoryKey: 'exam',
        repeatConfig: const RepeatConfig(type: RepeatType.weekly, weekdays: [1, 3]),
        calendarSync: const CalendarSyncFlags(google: true, haruchip: true),
        reminder: EventReminder.before1h,
        examTimeline: [ExamTimelineEntry(stage: ExamStage.writtenTest, date: DateTime(2026, 3, 1))],
        deadlineTime: const TimeOfDay(hour: 23, minute: 59),
        endDate: DateTime(2026, 3, 1),
        endDeadlineTime: const TimeOfDay(hour: 0, minute: 5),
      );

      final back = PlanItem.fromJson(item.toJson());

      expect(back.repeatConfig.type, RepeatType.weekly);
      expect(back.repeatConfig.weekdays, [1, 3]);
      expect(back.calendarSync.google, isTrue);
      expect(back.calendarSync.naver, isFalse);
      expect(back.reminder, EventReminder.before1h);
      expect(back.examTimeline.single.stage, ExamStage.writtenTest);
      expect(back.deadlineTime, const TimeOfDay(hour: 23, minute: 59));
      expect(back.endDeadlineTime, const TimeOfDay(hour: 0, minute: 5));
      expect(back.endDate, DateTime(2026, 3, 1));
    });

    test('이전 버전 백업 JSON(신규 키 없음)도 기본값으로 읽힌다', () {
      final back = PlanItem.fromJson({
        'id': 'old',
        'title': '옛날 백업',
        'date': '2025-01-01T00:00:00.000',
        'categoryKey': 'plan',
      });
      expect(back.repeatConfig.isRepeating, isFalse);
      expect(back.deadlineTime, isNull);
      expect(back.examTimeline, isEmpty);
    });
  });

  group('재시작 후 복원', () {
    test('첫 실행은 기존 목업 일정으로 시작한다', () {
      final c = _boot(InMemoryLocalStore());
      expect(c.read(planListProvider).length, mockPlanItems.length);
    });

    test('추가한 일정이 재시작 후에도 남는다', () {
      final store = InMemoryLocalStore();
      _boot(store).read(planListProvider.notifier).addItem(
            PlanItem(id: 'new-1', title: '새 일정', date: DateTime(2026, 12, 25), categoryKey: 'plan'),
          );

      final after = _boot(store).read(planListProvider);
      expect(after.any((p) => p.id == 'new-1'), isTrue);
    });

    test('카테고리와 숨김 상태가 재시작 후에도 남는다', () {
      final store = InMemoryLocalStore();
      final c1 = _boot(store);
      final cat = c1.read(categoryListProvider.notifier).addCategory(
            categoryKey: 'couple',
            name: '우리',
            emoji: '💕',
            colorHex: '#FF2D55',
          );
      c1.read(categoryListProvider.notifier).hideCategory(cat.id);

      final c2 = _boot(store);
      expect(c2.read(categoryListProvider).single.name, '우리');
      expect(c2.read(hiddenCategoriesProvider).single.id, cat.id);
    });

    test('휴지통이 재시작 후에도 남고, 30일 지난 항목은 로드 시 정리된다', () {
      final store = InMemoryLocalStore();
      final c1 = _boot(store);
      c1.read(trashBinProvider.notifier).emptyTrash();
      c1.read(trashBinProvider.notifier).moveToTrash(TrashItem(
            id: 't-fresh',
            entityType: TrashEntityType.goal,
            originalTitle: '최근 삭제',
            deletedAt: DateTime.now(),
            originalData: const {},
          ));
      // 저장소에 31일 전 항목을 직접 끼워 넣는다 (기기를 한 달 넘게 안 켠 상황).
      final stale = TrashItem(
        id: 't-stale',
        entityType: TrashEntityType.goal,
        originalTitle: '오래된 삭제',
        deletedAt: DateTime.now().subtract(const Duration(days: 31)),
        originalData: const {},
      );
      writeJsonList(store, LocalStoreKeys.trash, [...c1.read(trashBinProvider), stale], (t) => t.toJson());

      final ids = _boot(store).read(trashBinProvider).map((t) => t.id);
      expect(ids, ['t-fresh']);
    });

    test('커플 만난 날/재회 기록이 재시작 후에도 남는다', () {
      final store = InMemoryLocalStore();
      _boot(store).read(coupleProvider.notifier).updateRelationship(
            startDate: DateTime(2025, 3, 14),
            reunions: [ReunionPeriod(breakupDate: DateTime(2025, 8, 1), reuniteDate: DateTime(2025, 8, 20))],
          );

      final after = _boot(store).read(coupleProvider);
      expect(after.startDate, DateTime(2025, 3, 14));
      expect(after.reunions.single.reuniteDate, DateTime(2025, 8, 20));
    });

    test('저장 데이터가 깨져 있으면 앱이 죽지 않고 기본값으로 시작한다', () {
      final store = InMemoryLocalStore({LocalStoreKeys.plans: '{not json'});
      expect(_boot(store).read(planListProvider).length, mockPlanItems.length);
    });

    test('일부 항목만 깨져 있으면 그 항목만 건너뛴다', () {
      final store = InMemoryLocalStore({
        LocalStoreKeys.categories:
            '[{"id":"ok","categoryKey":"pet","name":"멍멍","icon":"🐶","createdAt":"2026-01-01T00:00:00.000"}, 42]',
      });
      expect(_boot(store).read(categoryListProvider).single.id, 'ok');
    });
  });
}
