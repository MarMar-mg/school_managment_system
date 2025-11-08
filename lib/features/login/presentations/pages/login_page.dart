import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:school_managment_system/features/login/presentations/pages/register_page.dart';
import '../../../../applications/bottom_nav_bar.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/login_form_card.dart';
import '../widgets/login_header.dart';


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

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // UI state
  bool _rememberMe = false;
  bool _isLoading = false;

  // Background animation
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();

    // Infinite smooth animation for moving gradient + particles (25 seconds per cycle)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _bgAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles login logic: validation → API call → role check → navigation
  Future<void> _handleLogin() async {
    final username = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('لطفاً همه فیلدها را پر کنید');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(username, password);

      // Prevent memory leaks if widget is disposed during async operation
      if (!mounted) return;

      // Ensure the logged-in user has the correct role for this page
      final userRole = (response['role'] ?? '').toString().toLowerCase();
      if (userRole != widget.role.title.toLowerCase()) {
        throw Exception('این حساب برای ${widget.role.title} نیست');
      }

      // Navigate to main app with user data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BottomNavBar(
            role: widget.role,
            userName: response['username'] ?? 'کاربر',
            userId: response['userid']?.toString() ?? '0',
            userIdi: response['userid'] ?? 0,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Shows a red RTL SnackBar with error/success messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ====================== ANIMATED BACKGROUND ======================
          AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.gradientColors.first.withOpacity(0.9),
                      widget.gradientColors.last.withOpacity(0.7),
                      AppColor.backgroundColor.withOpacity(0.95),
                    ],
                    stops: [0.0, _bgAnimation.value * 0.7, 1.0],
                  ),
                ),
                child: CustomPaint(
                  painter: ParticlePainter(animationValue: _bgAnimation.value),
                  size: MediaQuery.of(context).size,
                ),
              );
            },
          ),

          // ====================== MAIN CONTENT (RTL) ======================
          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // Back button header
                        LoginHeader(onBackPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterPage()
                          ),
                        ),),

                        const SizedBox(height: 50),

                        // ====================== GLASS MORPHISM LOGIN CARD ======================
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: LoginFormCard(
                                  role: widget.role,
                                  icon: widget.icon,
                                  title: widget.title,
                                  gradientColors: widget.gradientColors,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  rememberMe: _rememberMe,
                                  onRememberMeChanged: (v) => setState(() => _rememberMe = v ?? false),
                                  onLogin: _handleLogin,
                                  isLoading: _isLoading,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Terms & Privacy text
                        Text(
                          'با ورود شما با شرایط خدمات و سیاست حریم خصوصی موافقت می‌کنید',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey.withOpacity(0.9),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating white particles that move diagonally across the screen
class ParticlePainter extends CustomPainter {
  final double animationValue;
  ParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed → consistent particle positions

    for (int i = 0; i < 30; i++) {
      // Stagger each particle for wave effect
      final progress = (animationValue + i * 0.1) % 1.0;

      // Horizontal movement (diagonal)
      final x = progress * size.width * 1.5 - size.width * 0.25;

      // Vertical sine wave + random offset
      final y = sin(progress * pi * 2 + i) * 80 +
          size.height * 0.5 +
          random.nextDouble() * 200;

      // Pulsating size
      final radius = 2 + sin(progress * pi) * 3;

      canvas.drawCircle(
        Offset(x.clamp(0.0, size.width), y.clamp(0.0, size.height)),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}