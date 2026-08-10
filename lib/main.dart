import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/colors.dart';
import 'features/onboarding/screens/category_selection_screen.dart';

void main() {
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
      // TODO(onboarding): 스플래시 → 권한요청 → 로그인 화면이 만들어지면
      // 그 뒤에 이 화면(카테고리 선택)을 라우트로 연결한다. 지금은 이
      // 단계부터 바로 확인할 수 있도록 앱 진입점을 여기로 둔다.
      home: const CategorySelectionScreen(),
    );
  }
}
