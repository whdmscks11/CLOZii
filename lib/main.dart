import 'package:carrot_login/screens/home_screen.dart';
import 'package:flutter/material.dart';

final kColorScheme = ColorScheme.fromSeed(
  seedColor: Colors.amber[800]!,
  brightness: Brightness.light,
  surface: Color.fromARGB(255, 254, 247, 235),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: kColorScheme),
      home: HomeScreen(),
    );
  }
}
