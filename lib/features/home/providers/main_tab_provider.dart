import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 메인 셸(하단 탭바)의 현재 선택 탭 인덱스.
///
/// 2부 리더 지시(F) 예외 조항에 따라 화면 담당자(screen-builder)가 만든
/// 파일이다 — 원래 provider는 로직 담당자 영역(`lib/features/*/providers/`)
/// 이지만, 이 상태는 Firestore/도메인 로직과 무관한 순수 UI 상태(현재
/// 보고 있는 탭 번호)라 예외로 허용됐다.
///
/// [MainShellScreen]이 기존에는 `StatefulWidget`으로 `_tabIndex`를 직접
/// 들고 있었는데, 대시보드의 "우리의방" 카드(§8)를 탭했을 때 메인 셸
/// 바깥(다른 위젯 트리)에서 탭을 전환할 방법이 없어 이 provider로
/// 승격했다 — `ref.read(mainTabIndexProvider.notifier).select(3)`처럼
/// 어디서든 호출할 수 있다.
class MainTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    state = index;
  }
}

final mainTabIndexProvider =
    NotifierProvider<MainTabIndexNotifier, int>(MainTabIndexNotifier.new);
