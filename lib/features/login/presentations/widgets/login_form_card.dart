import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../commons/widgets/custom_text_field.dart';
import 'demo_info_card.dart';

/// Premium login form with glassmorphism-style card, smooth entrance animations,
/// password visibility toggle, loading state, and role-specific demo credentials.
class LoginFormCard extends StatefulWidget {
  final Role role;
  final IconData icon;
  final String title;
  final List<Color> gradientColors;

  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onLogin;
  final bool isLoading;

  const LoginFormCard({
    super.key,
    required this.role,
    required this.icon,
    required this.title,
    required this.gradientColors,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;

  // Animation controller for entrance sequence
  late final AnimationController _controller;

  // Card slides up from bottom
  late final Animation<double> _cardSlide;

  // Card fades in
  late final Animation<double> _cardFade;

  // Inner content fades in after card settles
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Card slides up from +700px with bounce
    _cardSlide = Tween<double>(begin: 700.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Card opacity
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Form fields appear sequentially
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation on mount
    _controller.forward();
  }

  /// Re-animate content when loading finishes (to re-reveal fields after error/success)
  @override
  void didUpdateWidget(covariant LoginFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading && !widget.isLoading) {
      _controller.forward(from: 0.4);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlide.value),
          child: Opacity(
            opacity: _cardFade.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Opacity(
                opacity: _contentFade.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRoleHeader(),
                    const SizedBox(height: 28),

                    // Username Field
                    _buildFieldWithDelay(
                      delay: 0.0,
                      child: CustomTextField(
                        controller: widget.emailController,
                        label: 'نام کاربری',
                        hintText: 'نام کاربری خود را وارد کنید',
                        icon: Icons.person_outlined,
                        keyboardType: TextInputType.text,
                        enabled: !widget.isLoading,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    _buildFieldWithDelay(
                      delay: 0.1,
                      child: CustomTextField(
                        controller: widget.passwordController,
                        label: 'رمز عبور',
                        hintText: 'رمز عبور خود را وارد کنید',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        enabled: !widget.isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColor.lightGray,
                          ),
                          onPressed: widget.isLoading
                              ? null
                              : () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Remember Me + Forgot Password
                    _buildFieldWithDelay(
                      delay: 0.2,
                      child: _buildRememberMeRow(),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    _buildLoginButton(),

                    const SizedBox(height: 20),

                    // Demo Credentials
                    _buildDemoCard(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Role header with gradient icon
  Widget _buildRoleHeader() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.gradientColors),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ورود به عنوان',
                style: TextStyle(fontSize: 13, color: AppColor.lightGray),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Staggered fade + slide for form fields
  Widget _buildFieldWithDelay({
    required double delay,
    required Widget child,
  }) {
    final start = 0.4 + delay;
    final end = (start + 0.3).clamp(0.0, 1.0);

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
        child: child,
      ),
    );
  }

  /// Remember Me + Forgot Password row
  Widget _buildRememberMeRow() {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: widget.rememberMe,
                onChanged: widget.isLoading ? null : widget.onRememberMeChanged,
                activeColor: widget.gradientColors.first,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'مرا به خاطر بسپار',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        GestureDetector(
          onTap: widget.isLoading
              ? null
              : () => debugPrint('Forgot password tapped'),
          child: Text(
            'فراموشی رمز عبور؟',
            style: TextStyle(
              fontSize: 13,
              color: widget.isLoading
                  ? Colors.grey
                  : widget.gradientColors.first,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Gradient login button with loading spinner
  Widget _buildLoginButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: widget.isLoading ? null : widget.onLogin,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [Colors.grey.shade400, Colors.grey.shade600]
                  : widget.gradientColors,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (widget.isLoading
                    ? Colors.grey
                    : widget.gradientColors.first)
                    .withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Text(
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
    );
  }

  /// Role-specific demo credentials card
  Widget _buildDemoCard() {
    return switch (widget.role) {
      Role.student => const DemoInfoCard(userName: 'شماره دانش آموزی', password: '123'),
      Role.teacher => const DemoInfoCard(userName: 'کد استادی', password: '123'),
      Role.manager => const DemoInfoCard(userName: 'کد معاونت', password: '123'),
    };
  }
}