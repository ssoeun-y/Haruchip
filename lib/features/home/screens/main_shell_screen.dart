import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/colors.dart';
import '../../../design_system/typography.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../calendar/screens/schedule_room_list_screen.dart';
import '../../couple/screens/couple_room_screen.dart';
import '../providers/main_tab_provider.dart';
import '../widgets/notification_center_modal.dart';
import '../widgets/settings_modal.dart';
import 'dashboard_screen.dart';

/// 메인 셸 — 로그인 이후 실제 앱의 진입점(§8 대시보드/캘린더/일정·정산방/
/// 우리의방 4탭을 묶는 상단 앱바 + 하단 탭바 껍데기).
///
/// haruchip_app.html 47~94줄 "TOP APP BAR" + "BOTTOM NAVIGATION BAR"
/// 마크업을 그대로 재현한다(§5/§6):
/// - 상단 앱바: 좌측 "H" 로고박스 + "하루칩"/"HaruChip Life & D-Day",
///   우측 알림종(뱃지 점) + 설정톱니 버튼.
/// - 하단 탭바: 대시보드(layout-grid) / 캘린더(calendar) / 일정·정산방
///   (users) / 우리의방(heart) — 라벨/아이콘 순서 원본 그대로.
///
/// 탭 전환은 [IndexedStack]으로 각 탭의 상태(스크롤 위치, 선택 상태 등)를
/// 보존한다.
///
/// (2부 연결) 알림종/설정톱니 버튼이 각각 [showNotificationCenterModal]/
/// [showSettingsModal]을 연다(1부가 남긴 스낵바 스텁을 실제 모달로
/// 교체). "우리의방" 탭은 [CoupleRoomScreen](2부에서 재구성)으로
/// 교체됐다.
///
/// 탭 선택 상태를 로컬 `State`가 아니라 `mainTabIndexProvider`(예외적으로
/// 이 담당자가 만든 UI 전용 provider — 파일 상단 주석 참고)로 승격한
/// 이유는 [DashboardScreen]의 커플 카드를 탭했을 때 메인 셸 바깥에서도
/// "우리의방" 탭(index 3)으로 전환할 방법이 필요했기 때문이다.
class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  static const List<_TabSpec> _tabs = [
    _TabSpec(icon: Icons.grid_view_rounded, label: '대시보드'),
    _TabSpec(icon: Icons.calendar_month_rounded, label: '캘린더'),
    _TabSpec(icon: Icons.people_alt_rounded, label: '일정·정산방'),
    _TabSpec(icon: Icons.favorite_rounded, label: '우리의방'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(mainTabIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.protoBackground,
      body: SafeArea(
        child: Column(
          children: [
            _TopAppBar(
              onNotificationTap: () => showNotificationCenterModal(context),
              onSettingsTap: () => showSettingsModal(context),
            ),
            Expanded(
              child: IndexedStack(
                index: tabIndex,
                children: const [
                  DashboardScreen(),
                  CalendarScreen(),
                  ScheduleRoomListScreen(),
                  CoupleRoomScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: tabIndex,
        tabs: _tabs,
        onSelect: (index) =>
            ref.read(mainTabIndexProvider.notifier).select(index),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar({
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        border: Border(
          bottom: BorderSide(
            color: AppColors.protoCardSelectedBg,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.protoButtonBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'H',
                  style: AppTypography.cardLabel.copyWith(
                    color: AppColors.protoButtonText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '하루칩',
                    style: AppTypography.cardLabel.copyWith(
                      color: AppColors.protoHeading,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'HaruChip Life & D-Day',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.protoStepLabel,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _IconButtonBadge(
                icon: Icons.notifications_rounded,
                onTap: onNotificationTap,
              ),
              const SizedBox(width: 8),
              _AppBarIconButton(
                icon: Icons.settings_rounded,
                onTap: onSettingsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.protoCardSelectedBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppColors.protoStepLabel),
      ),
    );
  }
}

/// 알림 버튼 전용 — 원본의 우측 상단 붉은 점(뱃지)까지 재현한다.
class _IconButtonBadge extends StatelessWidget {
  const _IconButtonBadge({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.protoCardSelectedBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 20, color: AppColors.protoStepLabel),
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.protoStepLabel,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.tabs,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<_TabSpec> tabs;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.protoCardBg,
        border: Border(
          top: BorderSide(color: AppColors.protoCardSelectedBg, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < tabs.length; i++)
              _NavBarButton(
                tab: tabs[i],
                selected: i == selectedIndex,
                onTap: () => onSelect(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  const _NavBarButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.protoStepLabel : AppColors.protoSubtitle;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

