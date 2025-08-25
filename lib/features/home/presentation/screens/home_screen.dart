import 'package:flutter/material.dart';

/// 앱 메인 화면 - 로그인 이후 화면 (게시글 목록 화면이 될 가능성이 큼)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Main Page')));
  }
}
