/// 알림 센터(haruchip_app.html openModal('notificationModal'), 683~706줄)
/// 에 뜨는 알림 1건. 지금은 목록 노출만 다루므로 제목/본문 두 필드로 충분하다
/// — 읽음 여부·딥링크 등은 화면 담당자가 필요해지면 별도로 확장한다.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;

  /// 이모지 포함 제목. 예: "🎉 1주년 기념일 D-15".
  final String title;

  /// 본문 설명. 예: "커플룸에서 다가오는 기념일을 확인하세요!".
  final String body;
}
