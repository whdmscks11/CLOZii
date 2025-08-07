import 'dart:async';

import 'package:flutter/material.dart';

class VerificationTimer extends StatefulWidget {
  const VerificationTimer({super.key});

  @override
  State<VerificationTimer> createState() => _VerificationTimerState();
}

class _VerificationTimerState extends State<VerificationTimer> {
  Timer? _timer;
  int minutes = 1;
  int seconds = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (!mounted) return;
        if (seconds != 0) {
          seconds--;
        } else {
          minutes--;
          seconds = 59;
        }
      });
      if (minutes == 0 && seconds == 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
    );
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }
}
