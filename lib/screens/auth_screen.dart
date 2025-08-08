import 'dart:async';

import 'package:carrot_login/data/enums.dart';
import 'package:carrot_login/screens/main_screen.dart';
import 'package:carrot_login/screens/select_location_screen.dart';
import 'package:carrot_login/widget/custom_button.dart';
import 'package:carrot_login/widget/custom_text_link.dart';
import 'package:carrot_login/widget/phone_number_field.dart';
import 'package:carrot_login/widget/verification_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    }
    minutes = 1;
    seconds = 0;

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

  /// SharedPreferences는 Flutter에서 간단한 데이터를 기기에 영구 저장할 수 있게 해주는 플러그인
  /// 예를 들어, 앱 설정, 로그인 상태, 인증번호 요청 횟수 같은 작은 데이터를 디스크에 저장했다가 앱을 재실행해도 유지할 수 있게 해준다.
  Future<int> requestCodeCount() async {
    final requestCooldown = Duration(minutes: 1).inMilliseconds;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    // 전화번호 별로 제한시간 지정해야 함 - 현재는 번호에 상관없이 최초 요청시 1분동안 5회 제한 
    int firstRequestTime = prefs.getInt('firstRequestTime') ?? 0;
    int countRemaining = prefs.getInt('countRemaining') ?? 5;
    int diff = now - firstRequestTime;

    if (diff > requestCooldown) {
      await prefs.setInt('firstRequestTime', now);
      countRemaining = 5;
    }

    countRemaining--;
    await prefs.setInt('countRemaining', countRemaining);
    return countRemaining;
  }

  void onSendCodeButtonPressed() async {
    _startTimer();
    int count = await requestCodeCount();

    // 실제 인증번호를 전송하는 로직 구현해야 함 
    // 그리고 count < 0일때는, 인증번호 전송 X
    // 가장 마지막에 전송한 인증번호를 상태로 저장 -> 인증번호 검증 로직에서 사용


    setState(() {
      verifButtonPressed = true;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        // 좀더 세밀하게 제어할 수 있는 스낵바를 사용하고 싶다면 -> FlushBar 사용! (외부 라이브러리)
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20.0),
          ),
          content: count >= 0
              ? Row(
                  children: [
                    Text('Verification code sent.'),
                    Spacer(flex: 1),
                    Text('$count remaining'),
                  ],
                )
              : Text('Try again later'),
        ),
      );
    });
  }

  void onVerificationCodeTyped(String value) {
    setState(() {
      verificationCode = value;
    });
  }

  void navigateToNext() {
    if (widget.authType == AuthType.login && _validateCode()) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => MainScreen()));
    }
    if (widget.authType == AuthType.signup && _validateCode()) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => SelectLocationScreen()));
    }
  }

  bool _validateCode() {
    // 전송된 인증번호 == verificationCode 확인하는 로직 구현
    return true;
  }

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
                onTap: verificationCode.isNotEmpty ? navigateToNext : null,
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
