import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_mock_data.dart';
import '../models/notification_item.dart';

/// 알림 센터 목록 provider. 지금은 mock을 그대로 노출하는 단순 목록이다
/// (실시간 Firestore 구독은 이번 범위 밖 — 화면 담당자가 필요해지면
/// StreamProvider로 교체할 수 있게 형태만 `List<NotificationItem>`로 맞췄다).
final notificationListProvider = Provider<List<NotificationItem>>((ref) {
  return mockNotifications;
});
