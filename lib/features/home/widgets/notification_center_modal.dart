import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../providers/notification_provider.dart';

/// 알림 센터 모달 — CLAUDE.md §8(공통 UI 모달 닫기 규칙).
///
/// haruchip_app.html 683~706줄 `notificationModal` 마크업을 그대로
/// 재현한다(§5/§6): 제목/본문 카드 리스트 + 하단 "닫기" 버튼.
/// [notificationListProvider](로직 담당자 구현, mock 목록)를 그대로
/// 렌더링만 한다 — 읽음 처리/딥링크는 이번 범위 밖.
Future<void> showNotificationCenterModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _NotificationCenterModal(),
  );
}

class _NotificationCenterModal extends ConsumerWidget {
  const _NotificationCenterModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
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
                Text(
                  '알림 센터',
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.protoSubtitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '아직 도착한 알림이 없어요',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.protoSubtitle,
                  ),
                ),
              )
            else
              for (final n in notifications)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.protoCardSelectedBg.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: AppTypography.cardLabel.copyWith(
                          color: AppColors.protoHeading,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        n.body,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.protoSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.protoButtonBg,
                  foregroundColor: AppColors.protoButtonText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
