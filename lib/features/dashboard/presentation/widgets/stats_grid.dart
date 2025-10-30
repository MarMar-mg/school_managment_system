import 'package:flutter/material.dart';
import '../../../../applications/role.dart';
import '../models/dashboard_models.dart';

class StatsGrid extends StatelessWidget {
  final Role role;

  const StatsGrid({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = DashboardData.getStats();
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic crossAxisCount based on screen size
    int crossAxisCount = screenWidth > 600 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Remove fixed aspect ratio — let content define height
        childAspectRatio: screenWidth > 600 ? 1.4 : 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return StatCardWidget(stat: stats[index]);
      },
    );
  }
}

class StatCardWidget extends StatelessWidget {
  final StatCard stat;

  const StatCardWidget({
    Key? key,
    required this.stat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 80,   // Minimum height
        maxHeight: 160,   // Maximum height to prevent overflow
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stat.color,
            stat.color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  stat.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Spacer(),
              // Value
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          // Value + Label + Subtitle (wrapped in Flexible to avoid overflow)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              Text(
                stat.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Spacer(),
              // Subtitle
              Text(
                stat.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                ),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}