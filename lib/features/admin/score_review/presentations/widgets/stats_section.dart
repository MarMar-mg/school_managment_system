import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class StatsSection extends StatelessWidget {
  final List<dynamic> overviewData;

  const StatsSection({super.key, required this.overviewData});

  @override
  Widget build(BuildContext context) {
    if (overviewData.isEmpty) return const SizedBox();

    double totalAvg = overviewData.fold<double>(
        0,
            (sum, c) =>
        sum + ((c['avgScore'] as num?)?.toDouble() ?? 0)) /
        overviewData.length;
    int totalStudents = overviewData.fold<int>(
        0, (sum, c) => sum + ((c['studentCount'] as num?)?.toInt() ?? 0));
    int totalClasses = overviewData.length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'میانگین کل',
            value: totalAvg.toStringAsFixed(1),
            icon: Icons.trending_up_rounded,
            color: AppColor.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'تعداد دانش‌آموز',
            value: '$totalStudents',
            icon: Icons.group_rounded,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            label: 'تعداد کلاس',
            value: '$totalClasses',
            icon: Icons.school_rounded,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColor.lightGray,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}