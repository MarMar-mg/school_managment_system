import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form_card.dart';
import '../../../dashboard/presentation/pages/dashboard.dart';
// Add to existing imports
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';


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


  void _handleLogin() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً همه فیلدها را پر کنید')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await ApiService.login(username, password);
      print(username);
      print(password);
      print(widget.role.title);

      Navigator.pop(context); // Close loading dialog

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Dashboard(
              role: _roleFromString(response['role']),
              userName: response['username'] ?? 'کاربر',
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      if (mounted) {
        print(username);
        print(password);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  Role _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return Role.student;
      case 'teacher':
        return Role.teacher;
      case 'admin':
        return Role.admin;
      default:
        return Role.student;
    }
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