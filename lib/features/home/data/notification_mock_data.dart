import '../models/notification_item.dart';

/// haruchip_app.html의 알림 센터 모달(683~706줄) mock 2건을 그대로 옮겼다.
final List<NotificationItem> mockNotifications = [
  NotificationItem(
    id: 'noti-1',
    title: '🎉 1주년 기념일 D-15',
    body: '커플룸에서 다가오는 기념일을 확인하세요!',
  ),
  NotificationItem(
    id: 'noti-2',
    title: '💸 정산 요청 도착',
    body: '주말 대학 동창 모임 정산이 완료되었습니다.',
  ),
];
