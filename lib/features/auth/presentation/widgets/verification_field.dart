import 'package:carrot_login/core/widgets/custom_button.dart';
import 'package:carrot_login/features/auth/presentation/widgets/verification_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 인증번호 입력 필드 위젯
/// - 타이머 레이아웃 위젯 (`VerificationTimer`)를 포함
/// - 입력 시 숫자만 허용
/// - 기본적으로 읽기 전용 상태이며 탭하면 입력 가능
class VerificationField extends StatefulWidget {
  const VerificationField({
    super.key,
    required this.minutes, // 남은 분
    required this.seconds, // 남은 초
    required this.onSubmitTap,
    required this.onVerified,
  });

  final int minutes;
  final int seconds;
  final VoidCallback onSubmitTap;
  final VoidCallback onVerified;

  @override
  State<VerificationField> createState() => _VerificationFieldState();
}

class _VerificationFieldState extends State<VerificationField> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// 인증번호 유효성 여부
  bool _isValid = false;

  /// 인증번호 입력 필드 활성/비활성
  bool _isEnabled = true;

  /// 필드의 읽기 전용 여부
  /// - 기본값: true (탭하기 전까지 수정 불가)
  bool _readOnly = true;

  /// 필드 탭 시 읽기 전용 해제
  void _onTap() {
    setState(() {
      _readOnly = false;
    });
  }

  /// 필드 외부 탭 시 읽기 전용 모드로 변경
  void _onTapOutside(PointerDownEvent event) {
    setState(() {
      _readOnly = true;
    });
  }

  /// 글자 수 카운터 숨김
  Widget? _hideCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) {
    return null; // null 반환 시 카운터 표시 안 함
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,

      child: Column(
        children: [
          TextFormField(
            controller: _controller,
            readOnly: _readOnly,
            enabled: _isEnabled,

            onTap: _onTap,
            onTapOutside: _onTapOutside,

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the verification code.';
              }
              if (value.length != 6) {
                return 'Please enter a 6-digit verification code.';
              }
              if (value != '000000') {
                return 'The verification code does not match.';
              }
              if (widget.minutes == 0 && widget.seconds == 0) {
                return 'The verification code has expired. Please request a new one.';
              }
              return null;
            },

            buildCounter: _hideCounter,
            keyboardType: TextInputType.number, // 숫자 키패드 사용
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 허용
            ],
            decoration: InputDecoration(
              /// 인증 타이머 표시
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isValid
                        ? Icon(Icons.check, color: Colors.green)
                        : VerificationTimer(
                            minutes: widget.minutes,
                            seconds: widget.seconds,
                          ),
                    const SizedBox(width: 4.0),
                    TextButton(
                      style: TextButton.styleFrom(
                        overlayColor: Colors.grey,
                        minimumSize: Size(0, 0),
                        padding: EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(4.0),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _isValid = true;
                          _isEnabled = false;
                          widget.onVerified();
                        }
                      },
                      child: _isValid
                          ? Text(
                              'Verified',
                              style: TextStyle(color: Colors.green),
                            )
                          : Text('Verify'),
                    ),
                  ],
                ),
              ),
              hintText: 'Enter verification code',
              hintStyle: TextStyle(color: Theme.of(context).disabledColor),
              helperText: 'Don\'t share your verification code',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
            ),
          ),

          // 다음 단계로 이동 버튼 (인증번호 입력 시 활성화)
          CustomButton(
            onTap: _isValid
                ? () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSubmitTap();
                    }
                  }
                : null,
            text: 'Get Started!',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 메모리 해제
    super.dispose();
  }
}
