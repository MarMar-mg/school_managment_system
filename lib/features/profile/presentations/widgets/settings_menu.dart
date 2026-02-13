import 'package:flutter/material.dart';

import '../../../../applications/role.dart';
import '../pages/about_page.dart';
import '../pages/notification_page.dart';
import '../pages/privacy_page.dart';

class SettingsMenu extends StatefulWidget {
  final Role role;
  final String userName;
  final VoidCallback onLogout;
  final int userId;

  const SettingsMenu({
    super.key,
    required this.onLogout,
    required this.userId,
    required this.role,
    required this.userName,
  });

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingsItem(
          index: 0,
          icon: Icons.notifications_none,
          label: 'اعلان‌ها',
          iconBgColor: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsPage(userId: widget.userId, role: widget.role, userName: widget.userName,),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          index: 1,
          icon: Icons.lock_outline,
          label: 'حریم خصوصی و امنیت',
          iconBgColor: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PrivacyPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          index: 2,
          icon: Icons.help_outline,
          label: 'راهنما و پشتیبانی',
          iconBgColor: Colors.teal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutPage()),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildSettingsItem({
    required int index,
    required IconData icon,
    required String label,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hoveredIndex = index),
        onTapUp: (_) {
          setState(() => _hoveredIndex = null);
          onTap();
        },
        onTapCancel: () => setState(() => _hoveredIndex = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHovered ? iconBgColor.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? iconBgColor.withOpacity(0.6)
                  : Colors.grey.shade200,
              width: isHovered ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? iconBgColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isHovered ? 20 : 8,
                offset: isHovered ? const Offset(0, 10) : const Offset(0, 2),
                spreadRadius: isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon with gradient and scale
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHovered
                        ? [
                            iconBgColor.withOpacity(0.4),
                            iconBgColor.withOpacity(0.15),
                          ]
                        : [
                            iconBgColor.withOpacity(0.15),
                            iconBgColor.withOpacity(0.08),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconBgColor.withOpacity(isHovered ? 0.5 : 0.2),
                  ),
                ),
                child: Transform.scale(
                  scale: isHovered ? 1.2 : 1.0,
                  child: Icon(icon, color: iconBgColor, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              // Label with underline animation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isHovered
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isHovered ? iconBgColor : Colors.black87,
                        letterSpacing: isHovered ? 0.3 : 0,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    if (isHovered)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 2,
                          width: 40,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Sliding arrow with color change
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: isHovered ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: Transform.translate(
                      offset: Offset(isHovered ? 15 : 0, 0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade300,
                        size: 16,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: isHovered ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Transform.translate(
                      offset: Offset(isHovered ? 0 : -15, 0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: iconBgColor,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: widget.onLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.shade200, width: 1.5),
            ),
          ),
          icon: const Icon(Icons.logout),
          label: const Text(
            'خروج از حساب',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
    );
  }
}
