import 'package:flutter/material.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/commons/untils.dart';
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

  bool get _isStaff =>
      widget.role == Role.teacher || widget.role == Role.manager;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _sectionAnims = List.generate(4, (index) {
      final start = 0.1 + (index * 0.15);
      final end = (start + 0.4).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animatedSection(int index, Widget child) {
    final animation = _sectionAnims[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= USER CARD =================
            _animatedSection(0, UserInfoCard(userName: widget.userName)),

            const SizedBox(height: 40),

            // ================= SETTINGS =================
            _animatedSection(1, _buildSectionHeader("تنظیمات")),

            const SizedBox(height: 16),

            _animatedSection(
              2,
              _buildCard(
                child: SettingsMenu(
                  onLogout: _showLogoutDialog,
                  userId: widget.userId.toInt(),
                ),
              ),
            ),

            if (_isStaff) const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ================= CARD WRAPPER =================

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }

  // ================= SECTION HEADER =================

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // ================= LOGOUT DIALOG =================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, color: Colors.red.shade600, size: 32),
                const SizedBox(height: 16),
                const Text(
                  'خروج از حساب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                const Text(
                  'آیا مطمئن هستید که می‌خواهید خروج کنید؟',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('لغو'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        );
                      },
                      child: const Text(
                        'خروج',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
