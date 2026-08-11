import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/schedule_room.dart';
import '../providers/schedule_room_provider.dart';
import '../widgets/room_availability_month_grid.dart';
import 'settlement_screen.dart';

/// 방 상세 화면 — CLAUDE.md §7-5 방 상세 플로우.
///
/// haruchip_app.html 840~901줄 `openRoomDetailModal` 마크업/톤을 화면
/// 형태로 재현하되, 가능 날짜 표시 부분은 원본의 8일 고정 카드 그리드
/// 대신 캘린더 탭 `MonthGrid`(html 489~530줄) 스타일의 **미니 월간뷰**로
/// 바꿨다(리더 지시) — 요일 헤더 + 숫자 칸 + 좌우 화살표로 월 이동,
/// 몇 달 뒤 날짜도 미리 잡을 수 있다. 가능 인원은 이모지 나열 대신
/// "n/전체명" 배지 + 배경 진하기(가능 인원 비율)로 표현한다
/// ([RoomAvailabilityMonthGrid] 참고). 날짜 탭 → 본인 가능여부 토글,
/// 전원 겹침/최다인원 강조 로직은 그대로 유지한다.
///
/// §7-5 순서 중 1~3번(그리드 토글, 다른 멤버 표시, 전원 겹침/최다인원
/// 강조)과 5번 앞부분(확정 버튼)까지만 다룬다. 안 겹칠 때의 "과반수
/// 추천 → 5개 후보 24시간 투표"(4번)는 로직 담당자 provider에 아직
/// 해당 API가 없어 이번 화면 범위에서 만들지 않는다(다섯 칸 ⑤) —
/// `bestDateFor`가 겹치는 날짜를 못 찾으면(count == 0) 안내 문구만
/// 보여준다. `bestDateFor`는 `room.dates`의 모든 키(달 제한 없음)를
/// 훑으므로 그리드가 월 단위로 바뀌어도 최다인원 계산은 그대로다.
///
/// NOTE: 로그인/인증 provider가 아직 이 담당자 범위에 없어 "나(myUid)"를
/// 알아낼 방법이 없다 — 임시로 방의 첫 번째 멤버를 "나"로 가정한다.
/// 실제 로그인 연동 시 리더가 이 부분만 교체하면 된다.
///
/// (2부 추가) 하단에 html 896줄 "정산하기로 이동" 버튼을 그대로 재현해
/// [SettlementScreen]으로 push한다 — CLAUDE.md §7-6/§8 정산 화면 진입점.
class ScheduleRoomDetailScreen extends ConsumerStatefulWidget {
  const ScheduleRoomDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<ScheduleRoomDetailScreen> createState() =>
      _ScheduleRoomDetailScreenState();
}

class _ScheduleRoomDetailScreenState
    extends ConsumerState<ScheduleRoomDetailScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _focusedMonth = DateTime(today.year, today.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  String _shortDateLabel(String yyyyMMdd) {
    final parts = yyyyMMdd.split('-');
    if (parts.length != 3) return yyyyMMdd;
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = days[date.weekday - 1];
    return '${date.month}/${date.day}($weekday)';
  }

  Future<void> _handleConfirm(BuildContext context, String date) async {
    ref.read(scheduleRoomsProvider.notifier).confirmDate(widget.roomId, date);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.protoCardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '일정이 확정되었어요',
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.protoHeading,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.protoSubtitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_shortDateLabel(date)} 일정이 개인 캘린더로 전환 등록돼요. '
                '캘린더에서 색상을 선택해 마무리해주세요.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.protoButtonBg,
                    foregroundColor: AppColors.protoButtonText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('확인'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(scheduleRoomsProvider);
    final room = rooms.firstWhere(
      (r) => r.id == widget.roomId,
      orElse: () => ScheduleRoom(
        id: widget.roomId,
        name: '알 수 없는 방',
        inviteCode: '-',
        members: const [],
        dates: const {},
      ),
    );
    final myUid = room.members.isNotEmpty ? room.members.first.uid : '';
    final best = bestDateFor(room);

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      appBar: AppBar(
        backgroundColor: AppColors.protoBackground,
        elevation: 0,
        foregroundColor: AppColors.protoHeading,
        title: Text(
          room.name,
          style: AppTypography.cardLabel.copyWith(
            color: AppColors.protoHeading,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '초대코드 ${room.inviteCode} · 멤버 ${room.members.length}명',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              Text(
                '가능한 날짜를 탭해서 표시해주세요',
                style: AppTypography.cardLabel.copyWith(
                  color: AppColors.protoHeading,
                ),
              ),
              const SizedBox(height: 10),
              RoomAvailabilityMonthGrid(
                focusedMonth: _focusedMonth,
                room: room,
                myUid: myUid,
                onDateToggle: (date) => ref
                    .read(scheduleRoomsProvider.notifier)
                    .toggleAvailability(widget.roomId, date, myUid),
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.protoStepLabel,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '전원 가능',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoSubtitle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.protoRadioSelectedBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '내가 체크함',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoSubtitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (best.date != null && best.count > 0)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.protoCardSelectedBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.protoCardSelectedBorder
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ 최다 인원 가능일: ${_shortDateLabel(best.date!)} '
                        '(${best.count}/${room.members.length}명)',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoCardSelectedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleConfirm(context, best.date!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.protoStepLabel,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('이 날짜로 확정하기'),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '아직 아무도 가능 날짜를 표시하지 않았어요',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoSubtitle,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // haruchip_app.html 896줄 "정산하기로 이동" 버튼 — §7-6/§8
              // (일정·정산방: 정산 화면 진입점).
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettlementScreen(roomId: widget.roomId),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.protoCardBorder,
                    foregroundColor: AppColors.protoCardText,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('정산하기로 이동'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
