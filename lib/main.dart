import 'package:carrot_login/features/onboarding/presentation/screens/onboarding_screen.dart';
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
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: OnBoardingScreen(), // 앱 최초 진입 화면(HomeScreen) 지정
    );
  }
}

const brandColor = Color(0xFFFF8585);
const secondaryColor = Color(0xFFFFC9C2);

final _lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'BalooThambi2',
  colorScheme: ColorScheme.light(
    primary: brandColor,
    secondary: secondaryColor,
    surface: Colors.white,
    onSurface: Colors.black87,
  ),
);

final _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'BalooThambi2',
  colorScheme: ColorScheme.dark(
    primary: brandColor,
    secondary: secondaryColor,
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white70,
  ),
);
