import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../commons/widgets/custom_text_field.dart';
import 'demo_info_card.dart';

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
  late AnimationController _animationController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(LoginFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.first.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRoleHeader(),
          const SizedBox(height: 28),
          CustomTextField(
            controller: widget.emailController,
            label: 'نام کاربری',
            hintText: 'نام کاربری خود را وارد کنید',
            icon: Icons.person_outlined,
            keyboardType: TextInputType.text,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),
          CustomTextField(
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
                size: 20,
              ),
              onPressed: widget.isLoading
                  ? null
                  : () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          _buildRememberMeRow(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 20),
          if (widget.role == Role.student) DemoInfoCard(userName: 'شماره دانش آموزی', password: '123') ,
          if (widget.role == Role.manager) DemoInfoCard(userName: 'کد معاونت', password: '123') ,
          if (widget.role == Role.teacher) DemoInfoCard(userName: 'کد استادی', password: '123') ,
        ],
      ),
    );
  }

  Widget _buildRoleHeader() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ورود به عنوان',
                style: TextStyle(fontSize: 13, color: AppColor.lightGray),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
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
              style: TextStyle(fontSize: 13, color: AppColor.darkText),
            ),
          ],
        ),
        GestureDetector(
          onTap: widget.isLoading ? null : () => debugPrint('Forgot password'),
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

  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onLogin,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isLoading
                      ? [Colors.grey.shade400, Colors.grey.shade600]
                      : widget.gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color:
                        (widget.isLoading
                                ? Colors.grey
                                : widget.gradientColors.first)
                            .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: widget.isLoading
                    ? Transform.scale(
                        scale: 0.8,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 3,
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
      },
    );
  }
}
