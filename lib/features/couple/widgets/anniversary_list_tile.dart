import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/couple_relationship.dart';

/// 다가오는 기념일 목록의 행 1개.
///
/// haruchip_app.html 626~637줄 "다가오는 기념일 자동 예측" 리스트 마크업을
/// 그대로 재현한다(§5/§6): `bg-pink-50/50 rounded-xl` 행 + `bg-pink-100
/// text-pink-700` D-day 배지. 커플 화면 전용 핑크 토큰(`protoCouple*`)만
/// 사용한다 — 새 컬러를 만들지 않는다.
class AnniversaryListTile extends StatelessWidget {
  const AnniversaryListTile({super.key, required this.milestone});

  final AnniversaryMilestone milestone;

  String get _dDayLabel {
    if (milestone.dDay == 0) return 'D-Day';
    return milestone.dDay > 0 ? 'D-${milestone.dDay}' : 'D+${-milestone.dDay}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.protoCoupleBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              milestone.label,
              style: AppTypography.cardLabel.copyWith(
                color: AppColors.protoHeading,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.protoCoupleBgMuted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _dDayLabel,
              style: AppTypography.caption.copyWith(
                color: AppColors.protoCoupleTextStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
