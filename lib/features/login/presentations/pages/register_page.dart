import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),

                  // ── Logo & Title ───────────────────────
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColor.purple, AppColor.lightPurple],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'پورتال آموزشی',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColor.purple),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'نقش خود را برای ادامه انتخاب کنید',
                        style:
                        TextStyle(fontSize: 14, color: AppColor.lightGray),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // ── Role Cards ─────────────────────────────
                  _buildRoleCard(
                    context: context,
                    role: Role.student,
                    icon: Icons.school_rounded,
                    title: 'دانش‌آموز',
                    subtitle: 'دسترسی به درس‌ها، نمرات',
                  ),
                  const SizedBox(height: 16),
                  _buildRoleCard(
                    context: context,
                    role: Role.teacher,
                    icon: Icons.menu_book_rounded,
                    title: 'معلم',
                    subtitle: 'مدیریت کلاس‌ها و دانش‌آموزان',
                  ),
                  const SizedBox(height: 16),
                  _buildRoleCard(
                    context: context,
                    role: Role.admin,
                    icon: Icons.person_outline_rounded,
                    title: 'مدیر',
                    subtitle: 'پورتال مدیریت مدرسه',
                  ),

                  const SizedBox(height: 32),

                  // ── Footer ─────────────────────────────────────
                  const Text(
                    'دسترسی امن به پورتال آموزشی',
                    style: TextStyle(fontSize: 12, color: AppColor.lightGray),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),

                  // extra space for keyboard
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  Widget _buildRoleCard({
    required BuildContext context,
    required Role role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final gradient = role.gradient; // from RoleExtension

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(
              role: role,
              icon: icon,
              title: title,
              subtitle: subtitle,
              gradientColors: gradient,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // ── Icon ─────────────────────────────────────
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),

            // ── Texts ────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            // ── Arrow ────────────────────────────────────
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}