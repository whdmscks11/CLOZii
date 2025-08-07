import 'package:carrot_login/data/enums.dart';
import 'package:carrot_login/screens/auth_screen.dart';
import 'package:carrot_login/widget/custom_button.dart';
import 'package:carrot_login/widget/custom_text_link.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthScreen(authType: AuthType.login),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 254, 247, 235),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ImageLogo(),
            _TitleAndSlogan(),
            const SizedBox(height: 32.0),
            _SignUpButton(),
            _LoginPromt(onPressed: () => navigateToLogin(context)),
          ],
        ),
      ),
    );
  }
}

class _ImageLogo extends StatelessWidget {
  const _ImageLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/img/nearbayan.png', width: 250, height: 250);
  }
}

class _TitleAndSlogan extends StatelessWidget {
  const _TitleAndSlogan();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Near Bayan',
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4.0),
        const Text(
          'Your bayan, your marketplace.',
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton();

  @override
  Widget build(BuildContext context) {
    return CustomButton(onTap: () {}, text: 'Sign Up');
  }
}

class _LoginPromt extends StatelessWidget {
  const _LoginPromt({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Do you already have an existing account?'),
        const SizedBox(width: 8.0),
        CustomTextLink(
          text: 'Login',
          style: TextStyle(
            color: Colors.amber[900],
            fontWeight: FontWeight.w500,
          ),
          onTap: onPressed,
        ),
      ],
    );
  }
}
