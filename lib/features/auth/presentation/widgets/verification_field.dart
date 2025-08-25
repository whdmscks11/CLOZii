import 'package:carrot_login/core/const/colors.dart';
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
  });

  final int minutes;
  final int seconds;
  final VoidCallback onSubmitTap;

  @override
  State<VerificationField> createState() => _VerificationFieldState();
}

class _VerificationFieldState extends State<VerificationField> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

            onTap: _onTap,
            onTapOutside: _onTapOutside,

            validator: (value) {
              if (value == null || value.isEmpty) {
                return '인증번호를 입력해주세요.';
              }
              if (value.length != 6) {
                return '6자리 인증번호를 입력해주세요.';
              }
              if (value != '000000') {
                return '인증번호가 일치하지 않습니다.';
              }
              if (widget.minutes == 0 && widget.seconds == 0) {
                return '인증번호가 만료되었습니다. 다시 요청해주세요.';
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
                padding: const EdgeInsets.only(top: 13.0, right: 20.0),

                /// 타이머 위치 조정
                /// 타이머 레이아웃 위젯
                /// 예) '00:00'
                child: VerificationTimer(
                  minutes: widget.minutes,
                  seconds: widget.seconds,
                ),
              ),
              hintText: 'Enter verification code',
              hintStyle: TextStyle(color: onDisabled),
              helperText: 'Don\'t share your verification code',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
            ),
          ),

          /// 다음 단계로 이동 버튼 (인증번호 입력 시 활성화)
          CustomButton(
            onTap: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmitTap();
              }
            },
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
