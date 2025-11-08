import 'package:flutter/material.dart';
import '../../../../applications/app_logo.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../widgets/role_card_widget.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                  const SizedBox(height: 60),

                  // Logo and Title Section
                  const AppLogo(
                    title: 'پورتال آموزشی',
                    subtitle: 'نقش خود را برای ادامه انتخاب کنید',
                  ),

                  const SizedBox(height: 56),

                  // Role Selection Cards
                  RoleCard(
                    role: Role.student,
                    icon: Icons.school_rounded,
                    title: 'دانش‌آموز',
                    subtitle: 'دسترسی به درس‌ها و نمرات',
                    onTap: () => _navigateToLogin(
                      context,
                      role: Role.student,
                      icon: Icons.school_rounded,
                      title: 'دانش‌آموز',
                      subtitle: 'دسترسی به درس‌ها و نمرات',
                    ),
                  ),

                  const SizedBox(height: 16),

                  RoleCard(
                    role: Role.teacher,
                    icon: Icons.menu_book_rounded,
                    title: 'معلم',
                    subtitle: 'مدیریت کلاس‌ها و دانش‌آموزان',
                    onTap: () => _navigateToLogin(
                      context,
                      role: Role.teacher,
                      icon: Icons.menu_book_rounded,
                      title: 'معلم',
                      subtitle: 'مدیریت کلاس‌ها و دانش‌آموزان',
                    ),
                  ),

                  const SizedBox(height: 16),

                  RoleCard(
                    role: Role.manager,
                    icon: Icons.person_outline_rounded,
                    title: 'مدیر',
                    subtitle: 'پورتال مدیریت مدرسه',
                    onTap: () => _navigateToLogin(
                      context,
                      role: Role.manager,
                      icon: Icons.person_outline_rounded,
                      title: 'مدیر',
                      subtitle: 'پورتال مدیریت مدرسه',
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer Text
                  const Text(
                    'دسترسی امن به پورتال آموزشی',
                    style: TextStyle(fontSize: 12, color: AppColor.lightGray),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
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

  void _navigateToLogin(
    BuildContext context, {
    required Role role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          role: role,
          icon: icon,
          title: title,
          subtitle: subtitle,
          gradientColors: role.gradient,
        ),
      ),
    );
  }
}
