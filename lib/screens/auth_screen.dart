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

  void onPhoneNumberTyped(String value) {
    setState(() {
      phoneNumber = value;
    });
  }

  void onSendCodeButtonPressed() {
    setState(() {
      verifButtonPressed = true;
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
                child: Text('Send verification code'),
              ),
            ),
            const SizedBox(height: 8.0),

            if (verifButtonPressed)
              VerificationField(onChanged: onVerificationCodeTyped),

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
}
