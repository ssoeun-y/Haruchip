import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/schedule_room.dart';

/// 방 목록의 방 카드 1개 — CLAUDE.md §7-5, §8(일정·정산방 화면).
///
/// haruchip_app.html 556~586줄 방 카드 마크업을 재현한다(§5/§6): 멤버
/// 아바타 칩 + "탭해서 가능한 날짜 표시하기" 추천 박스. 원본에는 이
/// 카드 안에 "정산하기" 버튼이 함께 있지만, 정산 화면은 이 담당자
/// 범위 밖(`lib/features/settlement/`)이라 이 카드에는 넣지 않는다 —
/// 방 상세로 진입한 뒤 정산으로 이어지는 연결은 리더가 통합한다.
class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room, required this.onTap});

  final ScheduleRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.protoCardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.protoCardBorder, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.protoCardSelectedBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('👥', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: AppTypography.cardLabel.copyWith(
                          color: AppColors.protoHeading,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '초대코드: ${room.inviteCode}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.protoCardSelectedBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '멤버 ${room.members.length}명',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoCardSelectedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in room.members)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${m.icon} ${m.name}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoCardText,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.protoCardSelectedBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.protoCardSelectedBorder.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📅 탭해서 가능한 날짜 표시하기',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.protoCardSelectedText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '멤버들과 겹치는 시간을 자동으로 찾아드려요',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.protoStepLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
