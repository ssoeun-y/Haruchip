import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../providers/couple_provider.dart';
import '../widgets/anniversary_list_tile.dart';
import 'couple_screen.dart';

/// 메인 셸 "우리의방" 탭 — CLAUDE.md §8(커플 방: 아바타 매칭 애니메이션,
/// 공동 꾸미기, 기념일 자동계산, 사진첩).
///
/// haruchip_app.html 588~639줄 `renderCoupleRoomHTML()`을 그대로 재현한다
/// (§5/§6): 상단 타이틀 + D+일수 배지, 핑크→옐로 그라디언트 가상 방
/// 캔버스(액자 데코 텍스트 + 마주보는 아바타 2개 + 하트), 하단 "다가오는
/// 기념일 자동 예측" 카드(기존 `AnniversaryListTile` 재사용).
///
/// 아바타 매칭 애니메이션은 html의 `animate-pulse`(확대/축소 반복)와
/// `animate-bounce`(하트 통통 튐)를 [AnimationController] 하나로 근사
/// 재현한다 — CSS 애니메이션 곡선까지 완벽히 재현하진 않는다(리더 지시:
/// "완벽 재현에 과한 시간 쓰지 마라").
///
/// 사진첩(§7-2/§8)은 haruchip_app.html 원본에도 없는 별도 화면 범위라
/// 이번엔 만들지 않는다. 대신 리더가 승인한 "기록 관리" 버튼(html에는
/// 없는 추가 진입점)을 우측 상단에 추가해, 기존 [CoupleScreen](이별/재회
/// 기록 + 요약형/타임라인형 토글 — 이 파일은 절대 수정하지 않는다)으로
/// push한다.
///
/// (2부 연결) [MainShellScreen]의 "우리의방" 탭 자리(기존
/// `_CoupleRoomPlaceholder`)가 이 화면으로 교체된다.
class CoupleRoomScreen extends ConsumerWidget {
  const CoupleRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDays = ref.watch(totalDaysTogetherProvider);
    final anniversaries = ref.watch(upcomingAnniversariesProvider);
    final relationship = ref.watch(coupleProvider);

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
                          '우리의 방 (커플룸)',
                          style: AppTypography.heading1.copyWith(
                            color: AppColors.protoHeading,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '쥬니어네이버 파니룸 콘셉트 가상 공간',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.protoCoupleText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.protoCoupleBgMuted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'D+$totalDays일째 💕',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.protoCoupleText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _VirtualRoomCanvas(
                selfIcon: '🐥',
                selfName: '하루',
                partnerIcon: relationship.partnerIcon,
                partnerName: relationship.partnerName,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CoupleScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.protoCoupleTextStrong,
                    side: const BorderSide(
                      color: AppColors.protoCoupleBgMuted,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: const Text('기록 관리'),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.protoCardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.protoCardBorder,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: AppColors.protoCoupleTextStrong,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '다가오는 기념일 자동 예측',
                          style: AppTypography.cardLabel.copyWith(
                            color: AppColors.protoHeading,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (anniversaries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '다가오는 기념일이 없어요',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.protoSubtitle,
                          ),
                        ),
                      )
                    else
                      // html은 2건만 미리보기로 보여준다(626~636줄) —
                      // 전체 목록은 "기록 관리" → CoupleScreen에서 확인.
                      for (final m in anniversaries.take(2))
                        AnniversaryListTile(milestone: m),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 가상 방 캔버스 — 액자 데코 + 마주보는 아바타 2개 + 하트 애니메이션.
class _VirtualRoomCanvas extends StatefulWidget {
  const _VirtualRoomCanvas({
    required this.selfIcon,
    required this.selfName,
    required this.partnerIcon,
    required this.partnerName,
  });

  final String selfIcon;
  final String selfName;
  final String partnerIcon;
  final String partnerName;

  @override
  State<_VirtualRoomCanvas> createState() => _VirtualRoomCanvasState();
}

class _VirtualRoomCanvasState extends State<_VirtualRoomCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.protoCoupleBgMuted,
            AppColors.protoCardSelectedBg,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.protoCoupleBgMuted, width: 2),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.protoCardBg.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '🖼️ 우리의 신혼집 안방 액자',
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoCoupleTextStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Transform.scale(
                      scale: 0.94 + _controller.value * 0.08,
                      child: child,
                    ),
                    child: _RoomAvatar(
                      icon: widget.selfIcon,
                      name: widget.selfName,
                    ),
                  ),
                  const SizedBox(width: 24),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, -6 * _controller.value),
                      child: child,
                    ),
                    child: const Text('💖', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 24),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Transform.scale(
                      scale: 0.94 + (1 - _controller.value) * 0.08,
                      child: child,
                    ),
                    child: _RoomAvatar(
                      icon: widget.partnerIcon,
                      name: widget.partnerName,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.protoCardBg.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '✨ 가구 배치 및 액자 사진 등록 기능 지원',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.protoCoupleTextStrong,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomAvatar extends StatelessWidget {
  const _RoomAvatar({required this.icon, required this.name});

  final String icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.protoCardBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.protoCoupleBgMuted, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(icon, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.protoCardBg.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            name,
            style: AppTypography.caption.copyWith(
              color: AppColors.protoHeading,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
