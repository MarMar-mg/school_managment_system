// login_page.dart
import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';

class LoginPage extends StatefulWidget {
  /// Icon that appears on the avatar (school, book, person …)
  final IconData icon;

  /// Role title (دانش‌آموز, معلم, مدیر)
  final String title;

  /// Subtitle under the role (optional – not used in the UI you showed)
  final String subtitle;

  /// Gradient colours for the avatar and the login button
  final List<Color> gradientColors;

  const LoginPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers (pre-filled with demo data)
  late final TextEditingController _emailController =
  TextEditingController();
  late final TextEditingController _passController =
  TextEditingController();

  // Password visibility
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Top Bar – Back + Change Role ───────────────────────
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back,
                      color: AppColor.purple,
                    ),
                    Text(
                      'تغییر نقش',
                      style: TextStyle(
                        color: AppColor.purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Main Card (avatar + form) ─────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 64),
                child: Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: widget.gradientColors.first.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Avatar + Role ─────────────────────────────────────
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: widget.gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'ورود به عنوان',
                                    style: TextStyle(
                                        fontSize: 14, color: AppColor.lightGray),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.darkText),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  
                        const SizedBox(height: 32),
                  
                        // ── Email Field ─────────────────────────────────────
                        _buildTextField(
                          controller: _emailController,
                          label: 'کد ملی',
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.number,
                        ),
                  
                        const SizedBox(height: 16),
                  
                        // ── Password Field ───────────────────────────────────
                        _buildTextField(
                          controller: _passController,
                          label: 'رمز عبور',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          isPassword: true,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                  
                        const SizedBox(height: 8),
                  
                        // ── Forgot Password ───────────────────────────────────
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: InkWell(
                        //     onTap: () {
                        //       // TODO: navigate to forgot-password screen
                        //     },
                        //     child: Text(
                        //       'فراموشی رمز عبور؟',
                        //       style: TextStyle(
                        //         fontSize: 13,
                        //         color: AppColor.purple,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //       textDirection: TextDirection.rtl,
                        //     ),
                        //   ),
                        // ),
                  
                        const SizedBox(height: 24),
                  
                        // ── Login Button ─────────────────────────────────────
                        InkWell(
                          onTap: () {
                            final email = _emailController.text.trim();
                            final pass = _passController.text;
                            if (email.isNotEmpty && pass.isNotEmpty) {
                              debugPrint('Login → $email | $pass');
                              // TODO: call your auth API
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('لطفاً همه فیلدها را پر کنید')),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.gradientColors,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'ورود',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // ── Demo Info Card ───────────────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColor.lightYellow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اطلاعات ورود آزمایش:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.darkText,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ایمیل: student@school.edu',
                                style: TextStyle(fontSize: 13, color: AppColor.darkText),
                                textDirection: TextDirection.rtl,
                              ),
                              Text(
                                'رمز عبور: demo123',
                                style: TextStyle(fontSize: 13, color: AppColor.darkText),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Footer ───────────────────────────────────────────────
              
              const Text(
                'با ورود شما شرایط خدمات و سیاست حریم خصوصی موافقت می‌کنید',
                style: TextStyle(fontSize: 12, color: AppColor.lightGray),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable TextField ───────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 16, color: AppColor.darkText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColor.lightGray),
        prefixIcon: Icon(icon, color: AppColor.lightGray, size: 20),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColor.lightGray,
          ),
          onPressed: onToggle,
        )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}