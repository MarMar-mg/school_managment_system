import 'package:flutter/material.dart';
import '../../../../applications/bottom_nav_bar.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
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
  bool _isLoading = false;


  void _handleLogin() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('لطفاً همه فیلدها را پر کنید');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(username, password);
      print(username);
      print(password);

      if (!mounted) return;
      if((response['role']).toString().toLowerCase() != widget.role.title.toString().toLowerCase()){
        print((response['role']).toString().toLowerCase());
        print(widget.role.title.toString().toLowerCase());
        throw Exception('این حساب برای ${widget.role.title} نیست');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BottomNavBar(
            role: _roleFromString(response['role'] ?? 'student'),
            userName: response['username'] ?? 'کاربر',
            userId: response['userid']?.toString() ?? '0',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString());
      print(e.toString());
      print(username);
      print(password);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Role _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return Role.student;
      case 'teacher':
        return Role.teacher;
      case 'admin':
        return Role.manager;
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