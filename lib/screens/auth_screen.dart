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

/// AuthScreen
/// - 로그인 또는 회원가입 시 전화번호로 인증을 진행하는 화면
/// - [AuthType.login] → 인증 성공 시 MainScreen(앱 메인 화면) 이동
/// - [AuthType.signup] → 인증 성공 시 SelectLocationScreen(거래 지역 선택 화면) 이동
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.authType});

  final AuthType authType;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  /// 사용자가 입력한 전화번호
  String _phoneNumber = '';

  /// 사용자가 입력한 인증번호
  String _verificationCode = '';

  /// 인증번호 발송 버튼 클릭 여부
  bool _verifButtonPressed = false;

  /// 인증번호 유효 시간 - 타이머
  Timer? _timer;
  int _minutes = 1;
  int _seconds = 0;

  /// 인증번호 유효시간 카운트다운 시작
  void _startTimer() {
    // 기존 타이머가 동작 중이면 취소
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    // 초기값 1분
    _minutes = 1;
    _seconds = 0;

    // 타이머 초기화 - Timer.periodic (일정 주기마다 특정 로직 수행)
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (!mounted) return; // 화면이 사라진 상태라면 아무것도 안 함

        if (_seconds > 0) {
          _seconds--;
        } else {
          _minutes--;
          _seconds = 59;
        }
      });

      // 시간이 다 되면 타이머 종료
      if (_minutes == 0 && _seconds == 0) {
        timer.cancel();
      }
    });
  }

  /// 전화번호 입력 이벤트 처리
  /// 매 입력마다 호출됨 
  void _onPhoneNumberTyped(String value) {
    setState(() {
      _phoneNumber = value;
    });
  }

  /// 인증번호 요청 횟수 제한 관리
  /// - SharedPreferences를 사용해 앱 종료 후에도 횟수 저장
  /// - 1분(임시) 동안 최대 5회 제한 (현재 전화번호 구분 로직은 구현 안함)
  Future<int> _requestCodeCount() async {
    final requestCooldown = Duration(minutes: 1).inMilliseconds; // 제한 시간 1분
    final prefs = await SharedPreferences.getInstance(); // 네이티브 저장소 연결 
    final now = DateTime.now().millisecondsSinceEpoch; // 메서드가 호출된 시간 (밀리초)

    int firstRequestTime = prefs.getInt('firstRequestTime') ?? 0; // 제한 횟수 5회 중 첫번째로 요청한 시각  
    int countRemaining = prefs.getInt('countRemaining') ?? 5; // 남은 제한 횟수 
    int diff = now - firstRequestTime; // 메서드가 호출된 시간 - 첫 인증번호 요청 시간 

    // 1분이 지났으면 횟수 초기화
    if (diff > requestCooldown) {
      await prefs.setInt('firstRequestTime', now); // 제한 시간이 지나면 첫 요청 시간 갱신
      countRemaining = 5; // 요청 횟수 카운트도 초기화
    }

    // 핵심 로직‼️
    // 남은 횟수 감소 후 저장
    countRemaining--;
    await prefs.setInt('countRemaining', countRemaining);

    return countRemaining;
  }

  /// "인증번호 전송" 버튼 클릭 처리
  void _onSendCodeButtonPressed() async {
    _startTimer(); // 타이머 시작
    int count = await _requestCodeCount(); // 요청 제한 횟수 카운트

    // TODO: 실제 인증번호 전송 로직 구현
    // TODO: count < 0 이면 전송 차단
    // TODO: 전송된 인증번호를 상태에 저장해 검증 시 사용

    setState(() {
      _verifButtonPressed = true; // 인증번호 발송 버튼 - 눌림 (true)

      // 기존 스낵바 제거 - 기존 스낵바가 제거되기 전에 다시 스낵바가 호출될 경우를 대비
      ScaffoldMessenger.of(context).clearSnackBars();

      // 새 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating, 
          duration: Duration(seconds: 2),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20.0),
          ),

          // 스낵바 내용 : 
          // - 제한 횟수가 남아 있는 경우, "인증번호 전송됨" 문자와 남은 요청 가능 횟수 표시
          // - 제한 횟수가 0이면, "나중에 다시 시도해주세요" 표시
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

  /// 인증번호 입력 이벤트 처리
  /// 매 입력마다 처리
  void _onVerificationCodeTyped(String value) {
    setState(() {
      _verificationCode = value;
    });
  }

  /// 인증 성공 시 다음 화면으로 이동
  void _navigateToNext() {

    if (widget.authType == AuthType.login && _validateCode()) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
    if (widget.authType == AuthType.signup && _validateCode()) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SelectLocationScreen()),
      );
    }

    /// TODO: validation 실패시 팝업 메시지 표시 및 입력 폼 에러 디자인 적용 
  }

  /// 인증번호 검증 로직
  /// TODO: 실제 전송된 번호와 입력값 비교 필요
  bool _validateCode() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 로그인/회원가입 여부에 따라 텍스트 변경
    final isLogin = widget.authType == AuthType.login;
    final label = isLogin ? 'login' : 'signup';

    return Scaffold(
      appBar: AppBar(),

      // 작은 기기에서 키보드 올라올때 UI 짤림 방지
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 인사말
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

            /// 개인정보 안내문
            Text(
              'Your phone number is kept safe and not be shared with neighbors.',
              style: theme.textTheme.labelMedium,
            ),

            const SizedBox(height: 8.0),

            /// 전화번호 입력 필드
            PhoneNumberField(
              onChanged: _onPhoneNumberTyped,
              enabled: !_verifButtonPressed, // 인증요청 후 비활성화
            ),

            const SizedBox(height: 8.0),

            /// 인증번호 전송 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                // 전화번호가 유효하면 버튼 활성화 (추후에 유효성 검사 로직 작성 필요)
                onPressed: _phoneNumber.length == 11
                    ? _onSendCodeButtonPressed
                    : null,
                
                // 인증번호 요청 버튼이 한번 눌렸으면 "Send code again" 표시 
                child: _verifButtonPressed
                    ? Text('Send code again')
                    : Text('Send verification code'),
              ),
            ),

            const SizedBox(height: 8.0),

            /// 인증번호 입력 필드 (인증번호 요청 버튼 클릭 후에만 표시)
            if (_verifButtonPressed)
              VerificationField(
                minutes: _minutes,
                seconds: _seconds,
                onChanged: _onVerificationCodeTyped,
              ),

            const SizedBox(height: 8.0),

            /// 다음 단계로 이동 버튼 (인증번호 입력 시 활성화)
            if (_verifButtonPressed)
              CustomButton(
                /// TODO: 인증번호 불일치 시 Error 표시
                onTap: _verificationCode.isNotEmpty ? _navigateToNext : null,
                text: 'Get Started!',
              ),

            /// 이메일 찾기 링크
            Center(
              child: CustomTextLink(
                prefixText: 'Changed number? ',
                style: theme.textTheme.labelMedium,
                linkText: 'find account with email',
                linkTextStyle: theme.textTheme.labelMedium!.copyWith(
                  decoration: TextDecoration.underline,
                ),

                // TODO: 이메일로 계정 찾기 로직 구현 
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 타이머 해제
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }
}