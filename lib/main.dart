import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/colors.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'firebase_options.dart';

/// Firebase 프로젝트: `haruchip-6a5aa` (flutterfire configure로 생성된
/// `firebase_options.dart` 사용). 앱 위젯 트리를 그리기 전에 Firebase를
/// 반드시 초기화해야 하므로 `main()`을 async로 바꾸고
/// `WidgetsFlutterBinding.ensureInitialized()`를 먼저 호출한다 — 이게
/// 없으면 플랫폼 채널이 아직 준비되지 않아 `Firebase.initializeApp()`이
/// 실패한다.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: HaruChipApp()));
}

class HaruChipApp extends StatelessWidget {
  const HaruChipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루칩',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      // 온보딩 순서(CLAUDE.md §8, reference/haruchip_app.html 기준 재배선):
      // 스플래시 → 로그인 → 카테고리 선택 → 대시보드 뷰모드 → 완료 →
      // 메인 셸(대시보드/캘린더/일정·정산방/우리의방 4탭). 권한요청 단계는
      // 네이티브 권한 다이얼로그가 필요해 이번 범위 밖이라 스플래시가
      // 곧바로 로그인으로 넘어간다.
      home: const SplashScreen(),
    );
  }
}
