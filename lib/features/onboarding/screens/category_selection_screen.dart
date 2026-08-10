import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../data/onboarding_categories.dart';
import '../models/onboarding_category.dart';
import '../providers/category_selection_provider.dart';
import '../widgets/category_group_section.dart';
import 'calendar_integration_screen.dart';

/// 온보딩 플로우의 "카테고리 선택(다중)" 단계.
///
/// 전체 온보딩 순서(CLAUDE.md §8):
/// 스플래시 → 권한요청 → 로그인 → **카테고리 선택(다중)** → 캘린더 연동
/// 선택 → 대시보드 뷰모드 → 위젯 안내
///
/// 이 화면은 그중 4번째 단계만 담당한다. 앞 단계(로그인)는 아직 구현되지
/// 않았다. [onNext]를 넘기면(주로 테스트) 그 콜백을 대신 호출하고, 넘기지
/// 않으면 다음 단계인 [CalendarIntegrationScreen]으로 실제 이동한다.
class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key, this.onNext});

  /// 다음 단계(캘린더 연동 선택)로 넘어갈 때 호출된다.
  final VoidCallback? onNext;

  static const int _stepIndex = 3; // 0-based, 7단계 중 4번째
  static const int _stepCount = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKeys = ref.watch(categorySelectionProvider);
    final canProceed = ref.watch(canProceedFromCategorySelectionProvider);

    final emotionalCategories = kOnboardingCategories
        .where((c) => c.group == CategoryGroup.emotional)
        .toList(growable: false);
    final practicalCategories = kOnboardingCategories
        .where((c) => c.group == CategoryGroup.practical)
        .toList(growable: false);

    void handleToggle(String key) {
      ref.read(categorySelectionProvider.notifier).toggle(key);
    }

    void handleNext() {
      if (!canProceed) return;
      if (onNext != null) {
        onNext!();
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CalendarIntegrationScreen()),
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
                    Text('관심있는 카테고리를\n골라주세요', style: AppTypography.heading1),
                    const SizedBox(height: 8),
                    Text(
                      '여러 개 선택할 수 있어요. 나중에 대시보드에서 언제든 추가할 수 있어요.',
                      style: AppTypography.bodyMuted,
                    ),
                    const SizedBox(height: 28),
                    CategoryGroupSection(
                      title: '감성형',
                      description: '배경·스티커·애니메이션을 자유롭게 꾸밀 수 있어요',
                      categories: emotionalCategories,
                      selectedKeys: selectedKeys,
                      onToggle: handleToggle,
                    ),
                    const SizedBox(height: 28),
                    CategoryGroupSection(
                      title: '실용형',
                      description: '컬러·폰트만 바꿀 수 있고 레이아웃은 고정이에요',
                      categories: practicalCategories,
                      selectedKeys: selectedKeys,
                      onToggle: handleToggle,
                    ),
                  ],
                ),
              ),
            ),
            _BottomCta(
              enabled: canProceed,
              selectedCount: selectedKeys.length,
              onPressed: handleNext,
            ),
          ],
        ),
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
    required this.enabled,
    required this.selectedCount,
    required this.onPressed,
  });

  final bool enabled;
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
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.surfaceMuted,
              foregroundColor: AppColors.onPrimary,
              disabledForegroundColor: AppColors.textDisabled,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              enabled ? '다음 ($selectedCount개 선택)' : '카테고리를 1개 이상 선택해주세요',
              style: AppTypography.button.copyWith(
                color: enabled ? AppColors.onPrimary : AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
