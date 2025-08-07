import 'package:flutter/material.dart';

class CustomTextLink extends StatelessWidget {
  const CustomTextLink({
    super.key,
    required this.text,
    this.style,
    required this.onTap,
  });

  final String text;
  final TextStyle? style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
