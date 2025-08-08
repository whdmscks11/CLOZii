import 'package:flutter/material.dart';

class VerificationTimer extends StatelessWidget {
  const VerificationTimer({super.key, required this.minutes, required this.seconds});

  final int minutes;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
    );
  }
}
