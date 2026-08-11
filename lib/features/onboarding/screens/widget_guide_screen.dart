import 'package:flutter/material.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';

/// "홈 화면 위젯 가이드" 화면.
///
/// (2부 갱신) 원래는 온보딩 플로우의 마지막 단계였지만, 온보딩 재배선을
/// 맡은 1부 담당자가 이 단계를 온보딩 흐름에서 제외했다. 이번 2부에서는
/// 이 화면을 **설정 모달 안에서 열리는 일반 안내 화면**으로 용도를
/// 바꿨다 — [showSettingsModal]의 "홈 화면 위젯 가이드 → 보기" 행을
/// 누르면 이 화면이 push된다. 실제로 홈 화면 위젯을 추가하는 네이티브
/// 로직은 아직 없고, 안내 문구만 보여준다. 온보딩 단계가 아니게 되면서
/// "완료" 개념이 사라졌으므로 [onComplete] 콜백을 제거하고, 상단에
/// 뒤로가기 가능한 [AppBar]를 추가했다 — 하단 CTA는 화면을 닫는
/// "확인" 버튼으로 바뀐다.
///
/// NOTE(§5/§6): haruchip_app.html 온보딩엔 "위젯 안내" 화면이 별도로
/// 존재하지 않는다(완료 화면 안내 문구 한 줄일 뿐). 그래서 이 화면은
/// "정확한 마크업 재현"이 아니라 같은 색상 토큰·컴포넌트 톤만 맞춘 것이다
/// — 원본에 없는 상단 진행바/스텝 라벨은 만들지 않는다.
class WidgetGuideScreen extends StatelessWidget {
  const WidgetGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      appBar: AppBar(
        backgroundColor: AppColors.protoBackground,
        elevation: 0,
        foregroundColor: AppColors.protoHeading,
        title: Text(
          '홈 화면 위젯 가이드',
          style: AppTypography.cardLabel.copyWith(color: AppColors.protoHeading),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '홈 화면에 하루칩\n위젯을 추가해보세요',
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.protoHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'D-day와 오늘 일정을 홈 화면에서 바로 확인할 수 있어요. '
                      '위젯 추가는 나중에 이 화면에서 언제든 다시 볼 수 있어요.',
                      style: AppTypography.bodyMuted.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _WidgetPreviewCard(),
                  ],
                ),
              ),
            ),
            _BottomCta(onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _WidgetPreviewCard extends StatelessWidget {
  const _WidgetPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.protoCardBorder, width: 2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.widgets_rounded,
            size: 26,
            color: AppColors.protoStepLabel,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '홈 화면 길게 누르기',
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoHeading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '위젯 추가 메뉴에서 하루칩을 찾아 추가해주세요',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.protoSubtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.protoButtonBg,
              foregroundColor: AppColors.protoButtonText,
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              '확인',
              style: AppTypography.button.copyWith(
                color: AppColors.protoButtonText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
