import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../logic/settlement_calculator.dart';
import '../models/schedule_room.dart';
import '../providers/schedule_room_provider.dart';

/// 정산 화면 — CLAUDE.md §7-6(정산 로직), §8(일정·정산방: 정산
/// 차액계산+딥링크).
///
/// haruchip_app.html 916~964줄 `openSettlementModal()`/`sendViaDeeplink()`를
/// 전체 화면 형태로 재현한다(§5/§6): 방 이름/인원수/1인당 금액 → 총금액 +
/// 결제자 요약 박스 → `calculateSettlement()`(로직 담당자 구현, html
/// 로직 그대로 포팅됨)가 계산한 최소 송금 tx 리스트 → 송금 건마다 카카오
/// 페이/토스 버튼 2개.
///
/// 카카오페이/토스 버튼은 실제 딥링크(URL 스킴)를 절대 열지 않는다 —
/// 실제 결제·송금 제휴/딥링크 연동은 CLAUDE.md 다섯 칸 ⑤("결제·송금
/// 관련 실제 API·제휴 연동을 붙이기 전 사람에게 확인")에 해당해 이 화면
/// 담당 범위 밖이다. 대신 안내 스낵바만 띄우고, §7-6 "확정 시점 = 실제
/// 송금 진행 시점" 규칙대로 버튼을 누른 시점에
/// `recordSettlementConfirmation()`을 호출한다(확정 후에도 재계산은
/// 항상 허용되므로 이 화면 자체를 잠그지 않는다).
///
/// 색상 갭: 원본 카카오페이 버튼은 `#FEE500`/`#3C1E1E`, 토스 버튼은
/// `#1B64DA`/흰색을 쓰는데 `colors.dart`엔 정확히 대응하는 토큰이 없다.
/// 카카오는 톤이 가장 가까운 `protoButtonBg`/`protoButtonText`(노랑
/// 계열)로, 토스는 브랜드 블루에 가장 가까운 `practicalAccent`(§5 실용형
/// 액센트 블루)로 근사했다.
class SettlementScreen extends ConsumerWidget {
  const SettlementScreen({super.key, required this.roomId});

  final String roomId;

  void _handleSend(
    BuildContext context,
    WidgetRef ref,
    String provider,
    String toName,
    int amount,
  ) {
    final label = provider == 'kakao' ? '카카오페이' : '토스';
    ref
        .read(scheduleRoomsProvider.notifier)
        .recordSettlementConfirmation(roomId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '💸 $label 딥링크 오픈 — $toName에게 $amount원 (송금 완료 시 정산 확정)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(scheduleRoomsProvider);
    final room = rooms.firstWhere(
      (r) => r.id == roomId,
      orElse: () => ScheduleRoom(
        id: roomId,
        name: '알 수 없는 방',
        inviteCode: '-',
        members: const [],
        dates: const {},
      ),
    );
    final memberUids = room.members.map((m) => m.uid).toList();
    final result = calculateSettlement(room.payments, memberUids);

    String iconOf(String uid) {
      final match = room.members.where((m) => m.uid == uid);
      return match.isEmpty ? '👤' : match.first.icon;
    }

    String nameOf(String uid) {
      final match = room.members.where((m) => m.uid == uid);
      return match.isEmpty ? uid : match.first.name;
    }

    final paidBy = room.payments.entries
        .map((e) => '${nameOf(e.key)} ${e.value}원')
        .join(' · ');

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      appBar: AppBar(
        backgroundColor: AppColors.protoBackground,
        elevation: 0,
        foregroundColor: AppColors.protoHeading,
        title: Text(
          '정산하기',
          style: AppTypography.cardLabel.copyWith(color: AppColors.protoHeading),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${room.name} · ${memberUids.length}명 · 1인당 ${result.share}원',
                style: AppTypography.bodyMuted.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.protoCardSelectedBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 금액',
                          style: AppTypography.cardLabel.copyWith(
                            color: AppColors.protoHeading,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${result.total}원',
                          style: AppTypography.cardLabel.copyWith(
                            color: AppColors.protoCardSelectedText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paidBy.isEmpty ? '결제자 정보가 없어요' : '결제자: $paidBy',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '보내야 할 금액 (최소 송금 횟수로 자동 계산)',
                style: AppTypography.cardLabel.copyWith(
                  color: AppColors.protoHeading,
                ),
              ),
              const SizedBox(height: 10),
              if (result.tx.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      '정산할 차액이 없습니다 🎉',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                  ),
                )
              else
                for (final t in result.tx)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${iconOf(t.from)} ${nameOf(t.from)}',
                                      style: AppTypography.cardLabel.copyWith(
                                        color: AppColors.protoHeading,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppColors.protoSubtitle,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${iconOf(t.to)} ${nameOf(t.to)}',
                                      style: AppTypography.cardLabel.copyWith(
                                        color: AppColors.protoHeading,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${t.amount}원',
                              style: AppTypography.cardLabel.copyWith(
                                color: AppColors.protoCardSelectedText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleSend(
                                  context,
                                  ref,
                                  'kakao',
                                  nameOf(t.to),
                                  t.amount,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.protoButtonBg,
                                  foregroundColor: AppColors.protoButtonText,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  '카카오페이로 보내기',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleSend(
                                  context,
                                  ref,
                                  'toss',
                                  nameOf(t.to),
                                  t.amount,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.practicalAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  '토스로 보내기',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 8),
              Text(
                '송금 버튼을 누르면 금액이 미리 채워진 상태로 카카오페이/토스가 '
                '열려요. 실제 송금을 진행한 시점에 정산이 확정되고, 이후에도 '
                '언제든 재계산할 수 있어요.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoSubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
