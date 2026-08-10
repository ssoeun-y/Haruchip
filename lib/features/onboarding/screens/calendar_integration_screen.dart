import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../data/calendar_integration_options.dart';
import '../providers/calendar_integration_provider.dart';
import '../widgets/calendar_integration_card.dart';

/// 온보딩 플로우의 "캘린더 연동 선택" 단계.
///
/// 전체 온보딩 순서(CLAUDE.md §8):
/// 스플래시 → 권한요청 → 로그인 → 카테고리 선택(다중) → **캘린더 연동
/// 선택** → 대시보드 뷰모드 → 위젯 안내
///
/// 이 화면은 그중 5번째 단계만 담당한다. 하루칩 자체 캘린더는 항상 켜져
/// 있으므로(§7-4) 토글을 만들지 않고, 여기서는 구글/네이버 등 *외부*
/// 캘린더 연동 의사만 고른다. 최소 선택 제약이 없어(0개=연동 없이 계속) 항상
/// 다음 단계로 진행할 수 있다. 다음 단계(대시보드 뷰모드)는 아직 구현되지
/// 않았으므로, [onNext]를 넘기지 않으면 실제 이동 대신 안내만 띄운다.
class CalendarIntegrationScreen extends ConsumerWidget {
  const CalendarIntegrationScreen({super.key, this.onNext});

  /// 다음 단계(대시보드 뷰모드)로 넘어갈 때 호출된다.
  final VoidCallback? onNext;

  static const int _stepIndex = 4; // 0-based, 7단계 중 5번째
  static const int _stepCount = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKeys = ref.watch(calendarIntegrationProvider);

    void handleToggle(String key) {
      ref.read(calendarIntegrationProvider.notifier).toggle(key);
    }

    void handleNext() {
      if (onNext != null) {
        onNext!();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('다음 단계(대시보드 뷰모드)는 아직 준비 중이에요'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _StepIndicator(current: _stepIndex, count: _stepCount),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('연동할 캘린더가\n있나요?', style: AppTypography.heading1),
                    const SizedBox(height: 8),
                    Text(
                      '구글/네이버 캘린더 일정을 하루칩에서 함께 볼 수 있어요. '
                      '나중에 설정에서 언제든 바꿀 수 있어요.',
                      style: AppTypography.bodyMuted,
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
            _BottomCta(
              selectedCount: selectedKeys.length,
              onPressed: handleNext,
            ),
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
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '하루칩 캘린더는 항상 켜져 있어요',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.count});

  final int current;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.primary : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i != count - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.selectedCount,
    required this.onPressed,
  });

  final int selectedCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              selectedCount > 0 ? '다음 ($selectedCount개 연동)' : '연동 없이 계속하기',
              style: AppTypography.button.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
