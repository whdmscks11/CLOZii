import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // 전화번호 입력 포맷팅에 필요한 패키지

/// 전화번호 입력 필드 위젯
/// - 기본적으로 읽기 전용(readOnly) 상태로 시작
///   - 탭하면 입력 가능 상태로 전환
///   - 외부를 탭하면 다시 읽기 전용으로 전환
/// - 전화번호 입력 시 '09' 프리픽스 자동 추가
/// - 하이픈(-) 자동 포맷 적용
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.onChanged,
    this.enabled = true,
  });

  /// 입력값 변경 시 호출되는 콜백
  final ValueChanged<String> onChanged;

  /// 필드 활성/비활성 상태
  /// 인증 번호 버튼 눌리면 비활성화
  final bool enabled;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final TextEditingController _controller = TextEditingController();

  /// 읽기 전용 상태 여부
  bool _readOnly = true;

  /// 전화번호 포맷 (예: 09##-###-###)
  /// - '#' 자리에 숫자만 입력 가능
  /// - MaskAutoCompletionType.lazy → 입력한 숫자에 맞춰 자동으로 하이픈(-) 삽입
  final _phoneNumberFomatter = MaskTextInputFormatter(
    mask: '##-###-####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  /// 필드 내부 탭 시 입력 가능 상태로 전환
  void _onTap() {
    setState(() {
      _readOnly = false;
    });
  }

  /// 필드 외부 탭 시 다시 읽기 전용 상태로 전환
  void _onTapOutside(PointerDownEvent event) {
    setState(() {
      _readOnly = true;
    });
  }

  /// TextField의 기본 글자수 카운터 숨기기
  Widget? _hideCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled, // 인증번호 요청 버튼 눌림 상태에 따라 활성 또는 비활성화
      readOnly: _readOnly, // 읽기 전용 상태 반영
      maxLength: 13, // "09##-###-####" 형식 최대 길이
      onTap: _onTap, 
      onTapOutside: _onTapOutside,
      onChanged: widget.onChanged,
      buildCounter: _hideCounter, // 글자수 카운터 숨김
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 허용
        _phoneNumberFomatter, // 하이픈 자동 포맷 적용
      ],
      decoration: InputDecoration(
        /// 읽기 전용이 아니거나 이미 값이 있을 때 '09' 자동 표시
        prefixText: !_readOnly || _controller.text.isNotEmpty ? '09' : '',
        prefixStyle: TextStyle(
          /// 필드 활성화 시 - 숫자색 검정 / 필드 비활성화 시 - 숫자색 회색
          color: widget.enabled ? Colors.black : Colors.grey, 
          fontSize: 15.75,
        ),

        /// 힌트 텍스트는 읽기 전용일 때만 표시
        hintText: _readOnly ? 'Enter your phone number without \'-\'' : null,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(),

        // 포커스 상태 필드 테두리 색 지정 
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 메모리 누수 방지를 위해 컨트롤러 해제
    super.dispose();
  }
}
