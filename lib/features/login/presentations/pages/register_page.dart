import 'package:flutter/material.dart';
import '../../../../applications/app_logo.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import 'login_page.dart';

/// RegisterPage: Role selection screen with smooth staggered animations
/// Users choose their role (Student / Teacher / Manager) → redirected to LoginPage
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Logo fade + slide-in animation
  late Animation<double> _logoAnim;

  // Staggered card entrance animations (3 cards)
  late List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();

    // Total animation duration: 1.4 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Logo appears first (0.0 → 0.5)
    _logoAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Cards appear sequentially with 150ms delay between each
    _cardAnims = List.generate(
      3,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.5 + index * 0.15, // 0.5, 0.65, 0.80
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    // Start animation on page load
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // ====================== ANIMATED LOGO ======================
                    AnimatedBuilder(
                      animation: _logoAnim,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoAnim.value,
                          child: Transform.translate(
                            offset: Offset(0, 50 * (1 - _logoAnim.value)),
                            child: child,
                          ),
                        );
                      },
                      child: const AppLogo(
                        title: 'پورتال آموزشی',
                        subtitle: 'نقش خود را برای ادامه انتخاب کنید',
                      ),
                    ),

                    const SizedBox(height: 60),

                    // ====================== ROLE CARDS ======================

                    // Student Card
                    _buildRoleCard(
                      index: 0,
                      role: Role.student,
                      icon: Icons.school_rounded,
                      title: 'دانش‌آموز',
                      subtitle: 'دسترسی به درس‌ها و نمرات',
                      colors: const [
                        Color(0xFF6C5CE7), // Purple
                        Color(0xFFA29BFE),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Teacher Card
                    _buildRoleCard(
                      index: 1,
                      role: Role.teacher,
                      icon: Icons.menu_book_rounded,
                      title: 'معلم',
                      subtitle: 'مدیریت کلاس‌ها و دانش‌آموزان',
                      colors: const [
                        Color(0xFF00CEC9), // Turquoise
                        Color(0xFF81ECEC),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Manager Card
                    _buildRoleCard(
                      index: 2,
                      role: Role.manager,
                      icon: Icons.person_outline_rounded,
                      title: 'مدیر',
                      subtitle: 'پورتال مدیریت مدرسه',
                      colors: const [
                        Color(0xFFFD79A8), // Pink
                        Color(0xFFFDCFDA),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // ====================== FOOTER TEXT ======================
                    FadeTransition(
                      opacity: _controller,
                      child: const Text(
                        'دسترسی امن به پورتال آموزشی',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.lightGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single animated role card with gradient, shadow, and tap navigation
  Widget _buildRoleCard({
    required int index,
    required Role role,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
  }) {
    final anim = _cardAnims[index];

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final value = anim.value;
        return Transform.translate(
          offset: Offset(0, 100 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Arrow (decorative)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            // Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ).onTap(() => _navigateToLogin(role, icon, title, subtitle, colors)),
    );
  }

  /// Navigate to LoginPage with smooth fade transition
  void _navigateToLogin(
      Role role,
      IconData icon,
      String title,
      String subtitle,
      List<Color> colors,
      ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => LoginPage(
          role: role,
          icon: icon,
          title: title,
          subtitle: subtitle,
          gradientColors: colors,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

/// Extension to add .onTap() syntax sugar
extension WidgetTapExtension on Widget {
  Widget onTap(VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.opaque,
      child: this,
    );
  }
}