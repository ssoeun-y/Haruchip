import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/models/schedule_room.dart';
import '../../calendar/providers/schedule_room_provider.dart';
import '../../categories/models/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../plan/models/plan_item.dart';
import '../../plan/providers/plan_provider.dart';
import '../models/trash_item.dart';
import '../providers/trash_provider.dart';

/// [before]에는 있는데 [after]에서 빠진 항목 — "삭제된 항목" 판별용.
/// 수정(같은 id 유지)은 삭제로 치지 않는다.
List<T> removedById<T>(List<T> before, List<T> after, String Function(T) idOf) {
  final kept = after.map(idOf).toSet();
  return before.where((e) => !kept.contains(idOf(e))).toList();
}

/// 휴지통으로 보내기 / 휴지통에서 원래 자리로 복구하기를 한곳에서 처리한다.
///
/// 목표·약속·루틴·시험·생일친구는 카테고리 `metadata[metaKey]` 목록 안에
/// 살고, 캘린더 노출용 PlanItem(미러)을 따로 가진다. 휴지통에는 원본 항목
/// JSON + 미러 PlanItem JSON을 함께 보관해서, 복구 시 둘 다 그대로 되살린다.
class TrashService {
  TrashService(this._ref);

  final Ref _ref;

  /// 카테고리 항목 하나를 휴지통으로 보내고, 캘린더 미러 PlanItem을
  /// 일정 목록에서 내린다(휴지통에 보관되므로 복구 가능).
  void trashCategoryEntry({
    required TrashEntityType type,
    required Category category,
    required String metaKey,
    required Map<String, dynamic> entry,
    required String title,
    Set<String> mirrorPlanIds = const {},
  }) {
    final planNotifier = _ref.read(planListProvider.notifier);
    final mirrors = _ref
        .read(planListProvider)
        .where((p) => mirrorPlanIds.contains(p.id))
        .toList();
    for (final p in mirrors) {
      planNotifier.removeItem(p.id);
    }

    _ref.read(trashBinProvider.notifier).moveToTrash(
          TrashItem(
            id: 'trash-${type.name}-${entry['id']}-${DateTime.now().microsecondsSinceEpoch}',
            entityType: type,
            originalTitle: title,
            deletedAt: DateTime.now(),
            categoryKey: category.categoryKey,
            originalData: {
              'categoryInstanceId': category.id,
              'metaKey': metaKey,
              'entry': entry,
              'planItems': mirrors.map((p) => p.toJson()).toList(),
            },
          ),
        );
  }

  /// [item]을 원래 자리로 되돌린다. 성공했을 때만 휴지통에서 빼고 true.
  /// 되돌릴 곳(카테고리/방)이 사라졌거나 지원하지 않는 유형이면 false —
  /// 이때 항목은 휴지통에 그대로 남는다(조용히 데이터가 사라지지 않게).
  bool restore(TrashItem item) {
    final bool ok;
    try {
      ok = _restoreInto(item);
    } catch (_) {
      return false;
    }
    if (ok) {
      _ref.read(trashBinProvider.notifier).restore(item.id);
    }
    return ok;
  }

  bool _restoreInto(TrashItem item) {
    final data = item.originalData;
    if (data.isEmpty) return false;

    // 카테고리 metadata 항목 (목표/약속/루틴/시험/생일친구)
    if (data['metaKey'] is String && data['entry'] is Map) {
      return _restoreCategoryEntry(data);
    }

    switch (item.entityType) {
      case TrashEntityType.plan:
        final json = {
          ...data,
          'categoryKey': data['categoryKey'] ?? item.categoryKey ?? 'plan',
        };
        final plan = PlanItem.fromJson(json);
        if (!_ref.read(planListProvider).any((p) => p.id == plan.id)) {
          _ref.read(planListProvider.notifier).addItem(plan);
        }
        return true;
      case TrashEntityType.settlement:
        if (!_roomExists(item.roomId)) return false;
        _ref
            .read(scheduleRoomsProvider.notifier)
            .restoreSettlementRecord(item.roomId!, SettlementRecord.fromJson(data));
        return true;
      case TrashEntityType.notice:
        if (!_roomExists(item.roomId)) return false;
        _ref.read(scheduleRoomsProvider.notifier).addRoomNotice(item.roomId!, RoomNotice.fromJson(data));
        return true;
      case TrashEntityType.vote:
        if (!_roomExists(item.roomId)) return false;
        _ref.read(scheduleRoomsProvider.notifier).createRoomVote(item.roomId!, RoomVote.fromJson(data));
        return true;
      case TrashEntityType.event:
        if (!_roomExists(item.roomId)) return false;
        _ref
            .read(scheduleRoomsProvider.notifier)
            .addRoomEvent(item.roomId!, RoomSharedEvent.fromJson(data));
        return true;
      default:
        return false;
    }
  }

  bool _roomExists(String? roomId) =>
      roomId != null && _ref.read(scheduleRoomsProvider).any((r) => r.id == roomId);

  bool _restoreCategoryEntry(Map<String, dynamic> data) {
    final categoryId = data['categoryInstanceId'] as String?;
    final metaKey = data['metaKey'] as String;
    final entry = Map<String, dynamic>.from(data['entry'] as Map);

    final matches = _ref.read(categoryListProvider).where((c) => c.id == categoryId);
    if (matches.isEmpty) return false;
    final category = matches.first;

    final meta = Map<String, dynamic>.from(category.metadata ?? {});
    final list = List<dynamic>.from(meta[metaKey] as List<dynamic>? ?? const []);
    final alreadyThere = list.any((e) => e is Map && e['id'] == entry['id']);
    if (!alreadyThere) list.insert(0, entry);
    meta[metaKey] = list;
    meta['isInitialized'] = true;
    _ref.read(categoryListProvider.notifier).updateCategory(category.copyWith(metadata: meta));

    final planNotifier = _ref.read(planListProvider.notifier);
    final existingIds = _ref.read(planListProvider).map((p) => p.id).toSet();
    final mirrors = (data['planItems'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((m) => PlanItem.fromJson(Map<String, dynamic>.from(m)))
        .where((p) => !existingIds.contains(p.id))
        .toList();
    if (mirrors.isNotEmpty) planNotifier.addItems(mirrors);
    return true;
  }
}

final trashServiceProvider = Provider<TrashService>((ref) => TrashService(ref));
