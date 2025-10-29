import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import 'login_page.dart';

TextEditingController nameController = TextEditingController();
TextEditingController passController = TextEditingController();

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // To control focus and avoid keyboard overflow
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  @override
  void dispose() {
    _nameFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      resizeToAvoidBottomInset: true, // Important for keyboard
      body: SafeArea(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: SingleChildScrollView(
            reverse: true, // Start from bottom when keyboard opens
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100), // Keeps top spacing

                // Logo & Title
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColor.purple, AppColor.lightPurple],
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
                    Text(
                      'پورتال آموزشی',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor.purple,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'نقش خود را برای ادامه انتخاب کنید',
                      style: TextStyle(fontSize: 14, color: AppColor.lightGray),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Role Cards
                Column(
                  children: [
                    _buildRoleCard(
                      context: context,
                      icon: Icons.school_rounded,
                      title: 'دانش‌آموز',
                      subtitle: 'دسترسی به درس‌ها، نمرات',
                      gradientColors: [
                        AppColor.studentBaseColor,
                        AppColor.studentSecondColor,
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context: context,
                      icon: Icons.menu_book_rounded,
                      title: 'معلم',
                      subtitle: 'مدیریت کلاس‌ها و دانش‌آموزان',
                      gradientColors: const [
                        AppColor.teacherBaseColor,
                        AppColor.teacherSecondColor,
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context: context,
                      icon: Icons.person_outline_rounded,
                      title: 'مدیر',
                      subtitle: 'پورتال مدیریت مدرسه',
                      gradientColors: const [
                        AppColor.adminBaseColor,
                        AppColor.adminSecondColor,
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Footer
                const Text(
                  'دسترسی امن به پورتال آموزشی',
                  style: TextStyle(fontSize: 12, color: AppColor.lightGray),
                  textDirection: TextDirection.rtl,
                ),

                // Extra space at the bottom so the last item isn't hidden under keyboard
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
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
  }) {
    return InkWell(
      onTap: () async {
        final output = await Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext ctx) => LoginPage(icon: icon,
                title: title, subtitle: subtitle, gradientColors: gradientColors)));
        return output;
      },
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
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
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