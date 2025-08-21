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
    required this.onChanged, // 값 변경 콜백
  });

  final int minutes;
  final int seconds;
  final ValueChanged<String> onChanged;

  @override
  State<VerificationField> createState() => _VerificationFieldState();
}

class _VerificationFieldState extends State<VerificationField> {
  final TextEditingController _controller = TextEditingController();

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
    return TextField(
      controller: _controller,
      readOnly: _readOnly,
      onTap: _onTap,
      onTapOutside: _onTapOutside,
      onChanged: widget.onChanged,
      buildCounter: _hideCounter,
      keyboardType: TextInputType.number, // 숫자 키패드 사용
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 허용
      ],
      decoration: InputDecoration(
        /// 인증 타이머 표시
        suffixIcon: Padding(
          padding: const EdgeInsets.only(top: 13.0, right: 20.0), /// 타이머 위치 조정 
          /// 타이머 레이아웃 위젯
          /// 예) '00:00'
          child: VerificationTimer(
            minutes: widget.minutes,
            seconds: widget.seconds,
          ),
        ),
        hintText: 'Enter verification code',
        hintStyle: TextStyle(color: Colors.grey),
        helperText: 'Don\'t share your verification code',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 메모리 해제
    super.dispose();
  }
}