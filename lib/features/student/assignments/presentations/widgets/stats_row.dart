// features/assignments/presentation/widgets/stats_row.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

/// Clean, elegant, modern stats row – perfect for 2025
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
        Expanded(child: _buildStat(
          count: pending,
          label: 'در انتظار',
          icon: Icons.timer_outlined,
          color: const Color(0xFF32D74B), // سبز تازه
        )),
        const SizedBox(width: 14),
        Expanded(child: _buildStat(
          count: submitted,
          label: 'ارسال شده',
          icon: Icons.description_outlined,
          color: const Color(0xFF0A84FF), // آبی اپل
        )),
        const SizedBox(width: 14),
        Expanded(child: _buildStat(
          count: graded,
          label: 'نمره‌دار',
          icon: Icons.check_circle_outline,
          color: const Color(0xFFFF9F0A), // نارنجی گرم
        )),
      ],
    );
  }

  Widget _buildStat({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withOpacity(0.25), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with soft background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          // Count
          Text(
            '$count',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 8),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.darkText.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}