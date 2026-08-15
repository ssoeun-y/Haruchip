import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../calendar/widgets/calendar_sync_dialog.dart';
import '../../categories/providers/category_provider.dart';
import '../../couple/providers/couple_provider.dart';
import '../../military/widgets/military_dashboard_card.dart';
import '../../onboarding/providers/dashboard_view_mode_provider.dart';
import '../../plan/providers/plan_provider.dart';
import '../providers/main_tab_provider.dart';
import '../widgets/add_category_dashboard_card.dart';
import '../widgets/add_category_dashboard_modal.dart';
import '../widgets/add_category_item_dialog.dart';
import '../widgets/baby_dashboard_card.dart';
import '../widgets/birthday_dashboard_card.dart';
import '../widgets/couple_dashboard_card.dart';
import '../widgets/dashboard_greeting_card.dart';
import '../widgets/dashboard_view_mode_toggle.dart';
import '../widgets/exam_dashboard_card.dart';
import '../widgets/generic_category_dashboard_card.dart';
import '../widgets/pet_dashboard_card.dart';

/// 메인 셸의 "대시보드" 탭 — CLAUDE.md §8(대시보드: 인사 + 뷰모드 전환 +
/// 카테고리 카드(전용/범용) + "+ 새 카테고리 추가하기").
///
/// haruchip_app.html 280~404줄 `renderDashboardHTML()` + 406~434줄
/// `renderGenericCategoryCard()` 헬퍼를 그대로 재현한다(§5/§6): 그라디언트
/// 인사 카드 → 뷰모드 토글 → 카테고리 카드 피드(세로형/박스형) 순서.
///
/// 로그인 provider가 아직 없어 유저 이름/아바타는 html mock
/// ("김하루"/"🌻")을 그대로 하드코딩한다 — 실제 로그인 연동은 이 담당자
/// 범위 밖이다.
///
/// 어떤 카드를 보여줄지는 `categoryListProvider`(사용자가 만든
/// [Category] 인스턴스 목록)를 기준으로 판단한다 — 전용 카드(커플/시험/
/// 생일/반려동물)는 `hasCategoryOfKeyProvider(key)`로, 나머지는 인스턴스별
/// 범용 카드로 그린다.
///
/// (2부 연결) 1부가 남긴 스낵바 스텁을 모두 실제 기능으로 교체했다:
/// - 커플 카드 탭 → `mainTabIndexProvider`를 3(우리의방)으로 바꿔 메인
///   셸 탭을 전환한다.
/// - 커플/시험 카드의 "캘린더 연동"/"연동" → [showCalendarSyncDialog].
/// - 시험/생일 카드의 "+ 추가" → [showAddCategoryItemDialog]
///   (categoryKey='exam'|'birthday').
/// - "+ 새 카테고리 추가하기" 카드 → [showAddCategoryDashboardModal].
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const String _mockUserName = '김하루';
  static const String _mockUserAvatar = '🌻';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(resolvedDashboardViewModeProvider);
    final totalDays = ref.watch(totalDaysTogetherProvider);
    final anniversaries = ref.watch(upcomingAnniversariesProvider);

    final cards = <Widget>[];

    if (ref.watch(hasCategoryOfKeyProvider('couple'))) {
      cards.add(
        CoupleDashboardCard(
          totalDays: totalDays,
          nextAnniversary: anniversaries.isEmpty ? null : anniversaries.first,
          // §8 커플 카드를 탭하면 "우리의방" 탭(index 3)으로 전환한다 —
          // mainTabIndexProvider는 이 담당자가 예외적으로 만든 UI 전용
          // provider(main_tab_provider.dart 참고).
          onTap: () => ref.read(mainTabIndexProvider.notifier).select(3),
          onSyncCalendar: () => showCalendarSyncDialog(context, '커플 1주년'),
        ),
      );
    }

    if (ref.watch(hasCategoryOfKeyProvider('exam'))) {
      final examItems = ref.watch(planItemsByCategoryProvider('exam'));
      cards.add(
        ExamDashboardCard(
          items: examItems,
          onAdd: () =>
              showAddCategoryItemDialog(context, categoryKey: 'exam'),
          onSyncItem: (item) => showCalendarSyncDialog(context, item.title),
        ),
      );
    }

    if (ref.watch(hasCategoryOfKeyProvider('birthday'))) {
      final birthdayItems = ref.watch(planItemsByCategoryProvider('birthday'));
      cards.add(
        BirthdayDashboardCard(
          items: birthdayItems,
          onAdd: () =>
              showAddCategoryItemDialog(context, categoryKey: 'birthday'),
        ),
      );
    }

    if (ref.watch(hasCategoryOfKeyProvider('pet'))) {
      final petItems = ref.watch(planItemsByCategoryProvider('pet'));
      cards.add(PetDashboardCard(items: petItems));
    }

    if (ref.watch(hasCategoryOfKeyProvider('military'))) {
      cards.add(const MilitaryDashboardCard());
    }

    if (ref.watch(hasCategoryOfKeyProvider('baby'))) {
      final babyItems = ref.watch(planItemsByCategoryProvider('baby'));
      cards.add(BabyDashboardCard(items: babyItems));
    }

    // 전용 카드가 없는 나머지 카테고리(솔로/계획 등) — 범용 카드로.
    // 사용자가 만든 카테고리 인스턴스별로 카드를 하나씩 그린다(다중
    // 인스턴스 허용 — CLAUDE.md §5).
    const dedicatedKeys = {'couple', 'exam', 'birthday', 'pet', 'military', 'baby'};
    final categories = ref.watch(categoryListProvider);
    for (final category in categories) {
      if (dedicatedKeys.contains(category.categoryKey)) continue;
      final items =
          ref.watch(planItemsByCategoryInstanceProvider(category.id));
      cards.add(
        GenericCategoryDashboardCard(category: category, items: items),
      );
    }

    cards.add(
      AddCategoryDashboardCard(
        onTap: () => showAddCategoryDashboardModal(context),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardGreetingCard(
                userName: _mockUserName,
                avatarEmoji: _mockUserAvatar,
              ),
              const SizedBox(height: 24),
              DashboardViewModeToggle(
                selectedKey: viewMode,
                onSelect: (key) =>
                    ref.read(dashboardViewModeProvider.notifier).select(key),
              ),
              const SizedBox(height: 16),
              if (viewMode == 'box')
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: cards,
                )
              else
                Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
