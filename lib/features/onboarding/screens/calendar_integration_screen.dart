import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../data/calendar_integration_options.dart';
import '../providers/calendar_integration_provider.dart';
import '../widgets/calendar_integration_card.dart';

/// "캘린더 연동 설정" 화면.
///
/// (2부 갱신) 원래는 온보딩 플로우의 5번째 단계였지만, 온보딩 재배선을
/// 맡은 1부 담당자가 이 단계를 온보딩 흐름에서 제외했다. 이번 2부에서는
/// 이 화면을 **캘린더 탭 안에서 열리는 연동 설정 화면**으로 용도를
/// 바꿨다 — [CalendarScreen]의 "연동 설정" 버튼(haruchip_app.html
/// 481~485줄)을 누르면 이 화면이 push된다. 하루칩 자체 캘린더는 항상
/// 켜져 있으므로(§7-4) 토글을 만들지 않고, 여기서는 구글/네이버 등
/// *외부* 캘린더 연동 의사만 고른다. 온보딩 단계가 아니게 되면서
/// "다음으로" 개념이 사라졌으므로 [onNext] 콜백과 관련 로직을 모두
/// 제거하고, 상단에 뒤로가기 가능한 [AppBar]를 추가했다 — 하단 CTA는
/// 선택 상태를 저장하고 화면을 닫는 "확인" 버튼으로 바뀐다(선택은
/// `calendarIntegrationProvider`에 이미 실시간 반영되므로 "확인"은 그냥
/// pop만 하면 된다).
///
/// NOTE(§5/§6): haruchip_app.html에는 이 화면과 정확히 같은 마크업이
/// 없다(온보딩 완료 화면 안내 문구 한 줄일 뿐). 그래서 "정확한 마크업
/// 재현"이 아니라 같은 색상 토큰·컴포넌트 톤만 맞춘 것이다.
class CalendarIntegrationScreen extends ConsumerWidget {
  const CalendarIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKeys = ref.watch(calendarIntegrationProvider);

    void handleToggle(String key) {
      ref.read(calendarIntegrationProvider.notifier).toggle(key);
    }

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      appBar: AppBar(
        backgroundColor: AppColors.protoBackground,
        elevation: 0,
        foregroundColor: AppColors.protoHeading,
        title: Text(
          '캘린더 연동 설정',
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
                      '연동할 캘린더가\n있나요?',
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.protoHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '구글/네이버 캘린더 일정을 하루칩에서 함께 볼 수 있어요. '
                      '나중에 이 화면에서 언제든 바꿀 수 있어요.',
                      style: AppTypography.bodyMuted.copyWith(
                        color: AppColors.protoSubtitle,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _AlwaysOnNotice(),
                    const SizedBox(height: 20),
                    for (final option in kCalendarIntegrationOptions) ...[
                      CalendarIntegrationCard(
                        option: option,
                        selected: selectedKeys.contains(option.key),
                        onTap: () => handleToggle(option.key),
                      ),
                      const SizedBox(height: 12),
                    ],
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

class _AlwaysOnNotice extends StatelessWidget {
  const _AlwaysOnNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.protoCardBorder, width: 2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.protoStepLabel,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '하루칩 캘린더는 항상 켜져 있어요',
              style: AppTypography.caption.copyWith(
                color: AppColors.protoSubtitle,
              ),
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
