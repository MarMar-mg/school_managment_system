import 'package:flutter/material.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import '../../../login/presentations/pages/register_page.dart';
import '../widgets/settings_menu.dart';
import '../widgets/user_info_card.dart';

class ProfilePage extends StatefulWidget {
  final Role role;
  final String userName;
  final String userId;

  const ProfilePage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _sectionAnims;

  // ========================== LIFECYCLE ==========================

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ========================== ANIMATIONS ==========================

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _sectionAnims = List.generate(8, (index) {
      final start = 0.1 + (index * 0.1);
      final end = (start + 0.35).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _controller.forward();
  }

  Widget _buildAnimatedSection({
    required int index,
    required Widget child,
    double slideDistance = 100,
  }) {
    final animation = _sectionAnims[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;
        return Transform.translate(
          offset: Offset(0, slideDistance * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }

  // ========================== MAIN BUILD ==========================

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedSection(
              index: 0,
              child: UserInfoCard(userName: widget.userName),
            ),
            const SizedBox(height: 32),
            // _buildAnimatedSection(
            //   index: 1,
            //   child: _buildSectionTitle('آمار و اطلاعات'),
            // ),
            // const SizedBox(height: 12),
            // _buildAnimatedSection(
            //   index: 2,
            //   child: StatsGrid(
            //     role: widget.role,
            //     userId: widget.userId.toInt(),
            //   ),
            // ),
            const SizedBox(height: 32),
            _buildAnimatedSection(
              index: 3,
              child: _buildSectionTitle('تنظیمات'),
            ),
            const SizedBox(height: 12),
            _buildAnimatedSection(
              index: 4,
              child: SettingsMenu(onLogout: () => _showLogoutDialog()),
            ),
            const SizedBox(height: 32),
            if (widget.role == Role.teacher || widget.role == Role.manager)
              const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ========================== HELPERS ==========================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  // ========================== DIALOGS ==========================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خروج از حساب', textDirection: TextDirection.rtl),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید خروج کنید؟',
          textDirection: TextDirection.rtl,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => RegisterPage()
                ),
              );
              // Add logout logic here
            },
            child: Text(
              'خروج',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
