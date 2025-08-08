import 'dart:async';

import 'package:carrot_login/data/enums.dart';
import 'package:carrot_login/widget/custom_button.dart';
import 'package:carrot_login/widget/custom_text_link.dart';
import 'package:carrot_login/widget/phone_number_field.dart';
import 'package:carrot_login/widget/verification_field.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.authType});

  final AuthType authType;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String phoneNumber = '';
  String verificationCode = '';
  bool verifButtonPressed = false;

  Timer? _timer;
  int minutes = 1;
  int seconds = 0;

  void _startTimer() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
      minutes = 1;
      seconds = 0;
    }

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (!mounted) return;
        if (seconds > 0) {
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

  void onPhoneNumberTyped(String value) {
    setState(() {
      phoneNumber = value;
    });
  }

  void onSendCodeButtonPressed() {
    _startTimer();

    setState(() {
      verifButtonPressed = true;
      ScaffoldMessenger.of(context).showSnackBar(
        // 좀더 세밀하게 제어할 수 있는 스낵바를 사용하고 싶다면 -> FlushBar 사용! (외부 라이브러리)
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20.0),
          ),
          content: Text('verification code sent!'),
        ),
      );
    });
  }

  void onVerificationCodeTyped(String value) {
    setState(() {
      verificationCode = value;
    });
  }

  void navigateToMain() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isLogin = widget.authType == AuthType.login;
    final label = isLogin ? 'login' : 'signup';

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello!',
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Please $label with your phone number.',
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Your phone number is kept safe and not be shared with neighbors.',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8.0),
            PhoneNumberField(
              onChanged: onPhoneNumberTyped,
              enabled: !verifButtonPressed,
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                onPressed: phoneNumber.length == 11
                    ? onSendCodeButtonPressed
                    : null,
                child: verifButtonPressed
                    ? Text('Send code again')
                    : Text('Send verification code'),
              ),
            ),
            const SizedBox(height: 8.0),

            if (verifButtonPressed)
              VerificationField(
                minutes: minutes,
                seconds: seconds,
                onChanged: onVerificationCodeTyped,
              ),

            const SizedBox(height: 8.0),
            if (verifButtonPressed)
              CustomButton(
                onTap: verificationCode.isNotEmpty ? navigateToMain : null,
                text: 'Get Started!',
              ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Changed number?', style: theme.textTheme.labelMedium),
                const SizedBox(width: 4.0),
                CustomTextLink(
                  text: 'find account with email',
                  style: theme.textTheme.labelMedium!.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }
}
