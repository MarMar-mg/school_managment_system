// features/student/assignments/presentation/widgets/stats_row.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class StatsRow extends StatelessWidget {
  final int pending, submitted, graded;

  const StatsRow({
    super.key,
    required this.pending,
    required this.submitted,
    required this.graded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          count: pending,
          label: 'در انتظار',
          icon: Icons.timer_rounded,
          color: const Color(0xFF34C759), // سبز نعنایی
          gradient: const LinearGradient(
            colors: [Color(0xFF34C759), Color(0xFF2BBF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(
          count: submitted,
          label: 'ارسال شده',
          icon: Icons.description_rounded,
          color: const Color(0xFF007AFF), // آبی کلاسیک
          gradient: const LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF0056D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(
          count: graded,
          label: 'نمره‌دار',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFFFF9500), // نارنجی گرم
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        )),
      ],
    );
  }

  Widget _buildStatCard({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // آیکون
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // عدد
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          // متن
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}