import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../models/calendar_event.dart';

/// 선택한 날짜의 일정 목록 행 1개 — CLAUDE.md §7-4, §8(캘린더 화면).
///
/// haruchip_app.html 512~527줄 "Schedule List for Selected Day" 행
/// 마크업을 재현한다(§5/§6): 출처 문구(구글/네이버 연동됨, 하루칩 단독
/// 일정) + 시간 배지. 배지/좌측 강조 색은 하드코딩 팔레트가 아니라 일정
/// 자체에 저장된 [CalendarEvent.colorHex](캘린더 등록 시 고른 색 — §6
/// 무료 프리셋 7개 중 하나)를 그대로 반영한다.
class EventListTile extends StatelessWidget {
  const EventListTile({super.key, required this.event});

  final CalendarEvent event;

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    return value != null ? Color(value) : AppColors.protoStepLabel;
  }

  String get _sourceLabel {
    switch (event.source) {
      case 'google':
        return '구글 캘린더 연동됨';
      case 'naver':
        return '네이버 캘린더 연동됨';
      default:
        return '하루칩 단독 일정';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _parseColor(event.colorHex);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _sourceLabel,
                  style: AppTypography.caption.copyWith(
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          if (event.time != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event.time!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.protoHeading,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
