import 'package:flutter/foundation.dart';

import 'military_rank.dart';

/// 군대(곰신) 카테고리 도메인 모델 — 핸드오프 문서 §5.3.
///
/// [CoupleRelationship]과 같은 이유로 [Category]/[PlanItem]에 억지로
/// 끼워 넣지 않고 별도 모델로 뺐다 — 입대일/전역일 두 날짜가 한 쌍으로
/// 붙어 있어야 진급 게이지를 계산할 수 있는데, `PlanItem`은 날짜 하나만
/// 갖는 구조라 맞지 않는다.
///
/// "계급별 D-Day 자동 계산"(§5.3)은 최초 구현 시점엔 실제 진급 규정을
/// 몰라 TODO로 남겨뒀었는데, 이후 핸드오프 문서에 군종별 규정(§5.3
/// `totalServiceMonths`/`monthsTo*`)이 추가돼 [military_rank.dart]의
/// [rankMilestones]/[currentRank]/[nextRankMilestone]로 계산한다 —
/// [branch]가 그 계산의 입력값이다.
@immutable
class MilitaryService {
  const MilitaryService({
    required this.enlistDate,
    required this.dischargeDate,
    this.branch = MilitaryBranch.army,
    this.nextLeaveDate,
  });

  final DateTime enlistDate;
  final DateTime dischargeDate;

  /// 군종 — 계급별 진급 시점 자체는 군종 공통이지만, 설정 다이얼로그가
  /// 전역일을 자동 제안할 때(`defaultDischargeDate`) 군종별 총
  /// 복무기간(§5.3)을 참조한다.
  final MilitaryBranch branch;

  /// 다음 휴가일 — 자동 계산이 아니라 사용자가 직접 입력한다(§5.3
  /// "휴가는 복무기간 제외 계산 안 하고 별도 '휴가까지 D-Day' 탭 분리").
  final DateTime? nextLeaveDate;

  MilitaryService copyWith({
    DateTime? enlistDate,
    DateTime? dischargeDate,
    MilitaryBranch? branch,
    DateTime? nextLeaveDate,
    bool clearNextLeaveDate = false,
  }) {
    return MilitaryService(
      enlistDate: enlistDate ?? this.enlistDate,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      branch: branch ?? this.branch,
      nextLeaveDate:
          clearNextLeaveDate ? null : (nextLeaveDate ?? this.nextLeaveDate),
    );
  }
}
