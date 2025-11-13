import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/commons/untils.dart';

import '../../../dashboard/presentation/widgets/stats_grid.dart'; // Assuming this is imported from provided files

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

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _sectionAnims;

  @override
  void initState() {
    super.initState();

    // 1800ms total animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Create staggered animations for each section
    _sectionAnims = List.generate(6, (index) {
      final start = 0.15 + (index * 0.12); // 0.15, 0.27, 0.39...
      final end = (start + 0.4).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Start animation on load
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            _buildUserInfoCard(),
            const SizedBox(height: 24),

            // Grid of Quick Access Buttons (role-based)
            _buildQuickAccessGrid(context),

            const SizedBox(height: 24),

            // Search Bar (role-based hint)
            _buildSearchBar(),

            const SizedBox(height: 16),

            // Additional Content (e.g., list items, role-based)
            if (widget.role == Role.teacher || widget.role == Role.manager)
              _buildAdditionalList(),
          ],
        ),
      ),
    );
  }

  /// User Info Card with gradient background
  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            widget.userName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, color: Colors.white70, size: 16),
              SizedBox(width: 4),
              Text(
                'ali.ahmadi@school.edu',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_outlined, color: Colors.white70, size: 16),
              SizedBox(width: 4),
              Text(
                '۰۹۱۱-۱۲۳-۴۵۶۷',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
              SizedBox(width: 4),
              Text(
                'تهران، خیابان انقلاب، پلاک ۱۲۳',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 16),
              SizedBox(width: 4),
              Text(
                '۱۴۰۰/۰۱/۰۱',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Grid of Quick Access Buttons (2x2, role-based)
  Widget _buildQuickAccessGrid(BuildContext context) {
    return  // ====================== STATS GRID ======================
      _buildAnimatedSection(
        index: 0,
        child: StatsGrid(role: widget.role, userId: widget.userId.toInt()),
      );
  }

  /// Search Bar with role-based hint
  Widget _buildSearchBar() {
    String hintText;
    IconData suffixIcon = Icons.search;

    switch (widget.role) {
      case Role.student:
        hintText = 'جستجوی تکالیف و امتحانات';
        suffixIcon = Icons.notifications_none;
        break;
      case Role.teacher:
        hintText = 'جستجو حضور و غیاب و نمرات';
        suffixIcon = Icons.lock_outline;
        break;
      case Role.manager:
        hintText = 'اطلاعات دانش آموزان';
        suffixIcon = Icons.notifications_none;
        break;
    }

    return TextField(
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColor.lightGray),
        suffixIcon: Icon(suffixIcon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  /// Additional List Items (for teacher/manager, as per screenshots)
  Widget _buildAdditionalList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2, // Example items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'ریاضیات و فیزیک',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: AppColor.lightGray, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Wraps any section with fade + slide-up animation
  Widget _buildAnimatedSection({
    required int index,
    required Widget child,
  }) {
    final animation = _sectionAnims[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;
        return Transform.translate(
          offset: Offset(0, 80 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}