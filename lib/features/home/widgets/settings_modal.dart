import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../onboarding/screens/widget_guide_screen.dart';

/// 설정 모달 — CLAUDE.md §8(공통 UI 모달 닫기 규칙).
///
/// haruchip_app.html 656~682줄 `settingsModal` 마크업을 그대로 재현한다
/// (§5/§6): 구글/네이버 캘린더 연동 상태, 토스/카카오뱅크 정산 연동 상태
/// 정적 텍스트(실제 연동 상태 조회 API가 없어 html 문구 그대로 — 실연동은
/// 다섯 칸 ⑤라 이번 범위 밖) + "홈 화면 위젯 가이드 → 보기"(탭하면
/// [WidgetGuideScreen]으로 push).
///
/// 색상 갭: 원본은 "활성화" 텍스트에 `text-green-600`을 쓰는데
/// `colors.dart`엔 green 계열 토큰이 없다. 새 토큰을 만들지 않고 가장
/// 가까운 기존 proto* 톤(`protoStepLabel`, amber-600)으로 통일했다 —
/// 두 상태 텍스트 모두 같은 색을 쓴다는 점이 원본과 다르다.
Future<void> showSettingsModal(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _SettingsModal(),
  );
}

class _SettingsModal extends StatelessWidget {
  const _SettingsModal();

  void _openWidgetGuide(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(builder: (_) => const WidgetGuideScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  '환경 설정 및 관리',
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
            _SettingsRow(
              label: '구글 / 네이버 캘린더 연동',
              valueText: '연동됨 (구글)',
              bg: AppColors.protoCardSelectedBg,
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              label: '토스 / 카카오뱅크 정산 연동',
              valueText: '활성화',
              bg: AppColors.surfaceMuted,
            ),
            const SizedBox(height: 8),
            _SettingsRow(
              label: '홈 화면 위젯 가이드',
              valueText: '보기',
              bg: AppColors.surfaceMuted,
              onTap: () => _openWidgetGuide(context),
            ),
            const SizedBox(height: 16),
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
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.valueText,
    required this.bg,
    this.onTap,
  });

  final String label;
  final String valueText;
  final Color bg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.protoCardText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            valueText,
            style: AppTypography.caption.copyWith(
              color: AppColors.protoStepLabel,
              fontWeight: FontWeight.w700,
              decoration:
                  onTap != null ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }
}
