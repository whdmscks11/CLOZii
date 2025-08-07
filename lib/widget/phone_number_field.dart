import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // inputFormatters 쓰려면 필요

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.onChanged,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final TextEditingController _controller = TextEditingController();

  bool _readOnly = true;

  final _phoneNumberFomatter = MaskTextInputFormatter(
    mask: '##-###-####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  void _onTap() {
    setState(() {
      _readOnly = false;
    });
  }

  void _onTapOutside(PointerDownEvent event) {
    setState(() {
      _readOnly = true;
    });
  }

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
      enabled: widget.enabled,
      readOnly: _readOnly,
      maxLength: 13,
      onTap: _onTap,
      onTapOutside: _onTapOutside,
      onChanged: widget.onChanged,
      buildCounter: _hideCounter,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _phoneNumberFomatter,
      ],
      decoration: InputDecoration(
        prefixText: !_readOnly || _controller.text.length > 1 ? '09' : '',
        prefixStyle: TextStyle(
          color: widget.enabled ? Colors.black : Colors.grey,
          fontSize: 15.75,
        ),
        hintText: _readOnly ? 'Enter your phone number without \'-\'' : null,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
