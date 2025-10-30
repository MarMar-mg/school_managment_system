import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form_card.dart';
import '../../../dashboard/presentation/pages/dashboard.dart';

class LoginPage extends StatefulWidget {
  final Role role;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const LoginPage({
    super.key,
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً همه فیلدها را پر کنید'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    debugPrint('Login → Role: ${widget.role}, Email: $email');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Dashboard(
          role: widget.role,
          userName: 'علی احمدی',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Back Button Header
                  LoginHeader(
                    onBackPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 32),

                  // Login Form Card
                  LoginFormCard(
                    role: widget.role,
                    icon: widget.icon,
                    title: widget.title,
                    gradientColors: widget.gradientColors,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    rememberMe: _rememberMe,
                    onRememberMeChanged: (value) {
                      setState(() => _rememberMe = value ?? false);
                    },
                    onLogin: _handleLogin,
                  ),

                  const SizedBox(height: 32),

                  // Footer Text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'با ورود شما با شرایط خدمات و سیاست حریم خصوصی موافقت می‌کنید',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.lightGray,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}