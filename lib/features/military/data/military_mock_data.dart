import '../models/military_service.dart';

/// 초기 군대(곰신) mock — haruchip_app.html의 military mock
/// (enlistDate 2024-03-10 / dischargeDate 2025-12-09)과 같은 날짜를 썼다.
final MilitaryService mockMilitaryService = MilitaryService(
  enlistDate: DateTime(2024, 3, 10),
  dischargeDate: DateTime(2025, 12, 9),
);
