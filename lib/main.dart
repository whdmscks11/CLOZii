import 'package:carrot_login/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';

/// 앱 전체에서 사용할 컬러 스킴 정의
/// - seedColor를 기준으로 밝은 테마 생성
/// - surface 컬러 별도 지정 (기본 배경색)
final kColorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFFFF8566),
  brightness: Brightness.light,
  surface: Color(0xFFFFF5E7),
);

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
      theme: ThemeData(colorScheme: kColorScheme), // 정의한 컬러 스킴 적용
      home: OnBoardingScreen(), // 앱 최초 진입 화면(HomeScreen) 지정
    );
  }
}
