import 'package:carrot_login/widget/verification_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerificationField extends StatefulWidget {
  const VerificationField({
    super.key,
    required this.minutes,
    required this.seconds,
    required this.onChanged,
  });

  final int minutes;
  final int seconds;
  final ValueChanged<String> onChanged;

  @override
  State<VerificationField> createState() => _VerificationFieldState();
}

class _VerificationFieldState extends State<VerificationField> {
  final TextEditingController _controller = TextEditingController();

  bool _readOnly = true;

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
      readOnly: _readOnly,
      onTap: _onTap,
      onTapOutside: _onTapOutside,
      onChanged: widget.onChanged,
      buildCounter: _hideCounter,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(top: 13.0, right: 20.0),
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
    _controller.dispose();
    super.dispose();
  }
}
