import '../models/military_rank.dart';
import '../models/military_service.dart';

/// 초기 군대(곰신) mock — haruchip_app.html의 military mock
/// (enlistDate 2024-03-10 / dischargeDate 2025-12-09)과 같은 날짜를 썼다.
/// 두 날짜 차이가 정확히 21개월이라 군종은 공군(§5.3 총 복무기간
/// 21개월)으로 맞췄다.
final MilitaryService mockMilitaryService = MilitaryService(
  enlistDate: DateTime(2024, 3, 10),
  dischargeDate: DateTime(2025, 12, 9),
  branch: MilitaryBranch.airForce,
);
