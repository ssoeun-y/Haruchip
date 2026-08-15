import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 온보딩 "대시보드 뷰모드" 단계 상태.
///
/// 값은 [DashboardViewModeOption.key] 단일 선택(라디오형) —
/// [CalendarIntegrationNotifier]와 달리 Set이 아니라 nullable 단일 값이다.
/// 아직 아무것도 고르지 않은 초기 상태는 null. 이 값은 온보딩 완료 시
/// 유저 설정(기본 대시보드 뷰모드)으로 저장하는 데 그대로 노출해 쓴다.
class DashboardViewModeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String key) {
    state = key;
  }

  bool isSelected(String key) => state == key;
}

final dashboardViewModeProvider =
    NotifierProvider<DashboardViewModeNotifier, String?>(
  DashboardViewModeNotifier.new,
);

/// 뷰모드를 하나 골라야 다음 단계(위젯 안내)로 진행할 수 있다.
final canProceedFromDashboardViewModeProvider = Provider<bool>((ref) {
  return ref.watch(dashboardViewModeProvider) != null;
});

/// 대시보드(온보딩 밖)에서 안전하게 쓰기 위한 null-safe 파생 provider.
///
/// 온보딩은 계속 null 강제 선택을 유지해야 하므로 [dashboardViewModeProvider]
/// 자체는 건드리지 않는다 — 여기서는 null일 때 haruchip_app.html 기본값인
/// 'vertical'로만 대체해서 노출한다.
final resolvedDashboardViewModeProvider = Provider<String>((ref) {
  return ref.watch(dashboardViewModeProvider) ?? 'vertical';
});
