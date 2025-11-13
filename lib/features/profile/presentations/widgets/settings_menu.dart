import 'package:flutter/material.dart';

class SettingsMenu extends StatefulWidget {
  final VoidCallback onLogout;

  const SettingsMenu({super.key, required this.onLogout});

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
            _showSnackBar('اعلان‌ها');
          },
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          index: 1,
          icon: Icons.lock_outline,
          label: 'حریم خصوصی و امنیت',
          iconBgColor: Colors.blue,
          onTap: () {
            _showSnackBar('حریم خصوصی و امنیت');
          },
        ),
        const SizedBox(height: 12),
        _buildSettingsItem(
          index: 2,
          icon: Icons.help_outline,
          label: 'راهنما و پشتیبانی',
          iconBgColor: Colors.teal,
          onTap: () {
            _showSnackBar('راهنما و پشتیبانی');
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
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHovered ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? iconBgColor.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? iconBgColor.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.08),
                blurRadius: isHovered ? 12 : 8,
                offset: isHovered ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isHovered ? 1.1 : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(isHovered ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconBgColor, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isHovered ? iconBgColor : Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              AnimatedRotation(
                turns: isHovered ? 0.25 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: isHovered ? iconBgColor : Colors.grey.shade300,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
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
            side: BorderSide(color: Colors.red.shade200),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          'خروج از حساب',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
      ),
    );
  }
}
