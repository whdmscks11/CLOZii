import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomTextLink extends StatefulWidget {
  const CustomTextLink({
    super.key,
    required this.linkText,
    this.linkTextStyle,
    this.displayText,
    this.additionalText,
    this.style,
    required this.onTap,
  });

  final String linkText;
  final TextStyle? linkTextStyle;
  final String? displayText;
  final String? additionalText;
  final TextStyle? style;
  final VoidCallback onTap;

  @override
  State<CustomTextLink> createState() => _CustomTextLinkState();
}

class _CustomTextLinkState extends State<CustomTextLink> {
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = widget.onTap;
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: widget.displayText,
        style: widget.style,
        children: [
          TextSpan(
            text: widget.linkText,
            style: widget.linkTextStyle,
            recognizer: _tapRecognizer,
          ),
          TextSpan(text: widget.additionalText, style: widget.style),
        ],
      ),
    );
  }
}
