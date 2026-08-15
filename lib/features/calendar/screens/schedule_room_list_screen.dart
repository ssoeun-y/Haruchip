import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../providers/schedule_room_provider.dart';
import '../widgets/room_card.dart';
import 'schedule_room_detail_screen.dart';

/// 일정 조율 & 정산 방 목록 화면 — CLAUDE.md §7-5, §8(일정·정산방).
///
/// haruchip_app.html 545~587줄 "renderRoomsHTML" 마크업을 재현한다
/// (§5/§6). 방 카드를 탭하면 방 상세([ScheduleRoomDetailScreen])로 push.
///
/// "+ 방 만들기" 버튼은 방 카드 톤을 맞추기 위해 UI만 두되, 실제 방
/// 생성 로직/폼은 이 화면 담당 범위 밖(로직 담당자 provider에 아직
/// `createRoom` 같은 API가 없다) — [onCreateRoom]을 넘기지 않으면 안내
/// 스낵바만 띄운다.
class ScheduleRoomListScreen extends ConsumerWidget {
  const ScheduleRoomListScreen({super.key, this.onCreateRoom});

  final VoidCallback? onCreateRoom;

  void _handleCreateRoom(BuildContext context) {
    if (onCreateRoom != null) {
      onCreateRoom!();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('방 만들기는 준비 중이에요')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(scheduleRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '일정 조율 & 정산 방',
                          style: AppTypography.heading1.copyWith(
                            color: AppColors.protoHeading,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '모임 멤버들과 과반수 추천 및 정산',
                          style: AppTypography.bodyMuted.copyWith(
                            color: AppColors.protoSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleCreateRoom(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.protoButtonBg,
                      foregroundColor: AppColors.protoButtonText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('+ 방 만들기'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (rooms.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '아직 참여 중인 방이 없어요',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                  ),
                )
              else
                for (final room in rooms) ...[
                  RoomCard(
                    room: room,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ScheduleRoomDetailScreen(roomId: room.id),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
