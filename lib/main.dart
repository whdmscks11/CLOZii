import 'package:clozii/core/theme/theme.dart';
import 'package:clozii/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

/// 앱 진입점(main 함수)
/// - MyApp 위젯 실행
void main() {
  runApp(const MyApp());
}

/// 최상위 위젯 (StatelessWidget)
/// - MaterialApp으로 앱 전체 테마 및 초기 화면 설정
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 우측 상단 디버그 배너 숨김
      themeMode: ThemeMode.system,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: OnBoardingScreen(), // 앱 최초 진입 화면(HomeScreen) 지정
    );
  }
}
