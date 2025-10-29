import 'package:school_managment_system/commons/untils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../applications/colors.dart';
import '../../../../commons/text_style.dart';
import '../../../../commons/widgets/loading_widget.dart';
import '../../../../main.dart';

TextEditingController nameController = TextEditingController();
TextEditingController passController = TextEditingController();

class RegisterPage extends StatefulWidget {


  const RegisterPage({
    Key? key,}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Title
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6A5AE0), Color(0xFF8B78FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'پورتال آموزشی',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'نقش خود را برای ادامه انتخاب کنید',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B6B6B),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Role Cards
                Expanded(
                  child: Column(
                    children: [
                      _buildRoleCard(
                        context: context,
                        icon: Icons.school_rounded,
                        title: 'دانش‌آموز',
                        subtitle: 'دسترسی به درس‌ها، نمرات',
                        gradientColors: const [Color(0xFF6A5AE0), Color(0xFF8B78FF)],
                        onTap: () {
                          // Navigate to student dashboard
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context: context,
                        icon: Icons.menu_book_rounded,
                        title: 'معلم',
                        subtitle: 'مدیریت کلاس‌ها و دانش‌آموزان',
                        gradientColors: const [Color(0xFF00C2CB), Color(0xFF1E90FF)],
                        onTap: () {
                          // Navigate to teacher dashboard
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildRoleCard(
                        context: context,
                        icon: Icons.person_outline_rounded,
                        title: 'مدیر',
                        subtitle: 'پورتال مدیریت مدرسه',
                        gradientColors: const [Color(0xFFFF6B9D), Color(0xFFFF8FA3)],
                        onTap: () {
                          // Navigate to admin dashboard
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Footer
                const Text(
                  'دسترسی امن به پورتال آموزشی',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9A9A9A),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            // Arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
