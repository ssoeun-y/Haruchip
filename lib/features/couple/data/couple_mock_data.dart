import '../models/couple_relationship.dart';

/// 초기 커플 관계 mock.
///
/// haruchip_app.html의 커플 mock(파트너 "민수", 시작일 2024-05-14)과 같은
/// 톤으로 맞췄다. 아이콘은 haruchip_app.html 일정 방 mock에서 "민수"가 쓰는
/// 🐶 이모지를 그대로 가져왔다.
final CoupleRelationship mockCoupleRelationship = CoupleRelationship(
  startDate: DateTime(2024, 5, 14),
  partnerName: '민수',
  partnerIcon: '🐶',
  reunions: const [],
);
