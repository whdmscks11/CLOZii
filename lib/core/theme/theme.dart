import 'package:flutter/material.dart';

const brandColor = Color(0xFFFF8585);
const secondaryColor = Color(0xFFFFC9C2);

TextTheme _buildTextTheme(Brightness b) {
  // 본문 기본은 시스템 폰트(가독성), 제목/버튼은 Baloo로 브랜드감
  const baloo = TextStyle(fontFamily: 'CLOZii_BalooThambi2');

  return TextTheme(
    // 헤드라인(큰 타이틀)
    headlineLarge: baloo.copyWith(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: baloo.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
    headlineSmall: baloo.copyWith(fontSize: 24, fontWeight: FontWeight.w700),

    // 섹션 타이틀/앱바 타이틀
    titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleSmall: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),

    // 본문(시스템 폰트 유지: fontFamily 지정 X)
    bodyLarge: const TextStyle(fontSize: 16, height: 1.45),
    bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
    bodySmall: const TextStyle(fontSize: 12, height: 1.4),

    // 라벨/버튼 (조금 굵게)
    labelLarge: baloo.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: baloo.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: baloo.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
  ).apply(
    // 다크/라이트에 맞춰 기본 텍스트 컬러 자동 적용
    bodyColor: b == Brightness.dark ? Colors.white70 : Colors.black87,
    displayColor: b == Brightness.dark ? Colors.white : Colors.black,
  );
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.light(
    primary: brandColor,
    secondary: secondaryColor,
    surface: Colors.white,
    onSurface: Colors.black87,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    textTheme: _buildTextTheme(Brightness.light),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: _buildTextTheme(Brightness.light).titleLarge,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        textStyle: _buildTextTheme(Brightness.light).labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.dark(
    primary: brandColor,
    secondary: secondaryColor,
    surface: const Color(0xFF1E1E1E),
    onSurface: Colors.white70,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    textTheme: _buildTextTheme(Brightness.dark),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: _buildTextTheme(Brightness.dark).titleLarge,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        textStyle: _buildTextTheme(Brightness.dark).labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}
