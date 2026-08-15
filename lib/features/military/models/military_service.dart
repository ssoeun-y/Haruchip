import 'package:flutter/foundation.dart';

/// 군대(곰신) 카테고리 도메인 모델 — 핸드오프 문서 §5.3.
///
/// [CoupleRelationship]과 같은 이유로 [Category]/[PlanItem]에 억지로
/// 끼워 넣지 않고 별도 모델로 뺐다 — 입대일/전역일 두 날짜가 한 쌍으로
/// 붙어 있어야 진급 게이지를 계산할 수 있는데, `PlanItem`은 날짜 하나만
/// 갖는 구조라 맞지 않는다.
///
/// NOTE: "계급별 D-Day 자동 계산"(§5.3)은 이번 범위에서 만들지 않는다 —
/// 실제 진급 규정(군별로 다름)이 이번 세션에 없어서다. 규정을 받으면
/// 이 모델에 `List<RankMilestone>` 같은 필드를 추가해 확장하면 된다.
@immutable
class MilitaryService {
  const MilitaryService({
    required this.enlistDate,
    required this.dischargeDate,
    this.nextLeaveDate,
  });

  final DateTime enlistDate;
  final DateTime dischargeDate;

  /// 다음 휴가일 — 자동 계산이 아니라 사용자가 직접 입력한다(§5.3
  /// "휴가는 복무기간 제외 계산 안 하고 별도 '휴가까지 D-Day' 탭 분리").
  final DateTime? nextLeaveDate;

  MilitaryService copyWith({
    DateTime? enlistDate,
    DateTime? dischargeDate,
    DateTime? nextLeaveDate,
    bool clearNextLeaveDate = false,
  }) {
    return MilitaryService(
      enlistDate: enlistDate ?? this.enlistDate,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      nextLeaveDate:
          clearNextLeaveDate ? null : (nextLeaveDate ?? this.nextLeaveDate),
    );
  }
}
