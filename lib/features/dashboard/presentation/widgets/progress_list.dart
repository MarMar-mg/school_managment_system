import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../models/dashboard_models.dart';

class ProgressList extends StatelessWidget {
  final List<ProgressItem> progressItems;

  const ProgressList({
    Key? key,
    required this.progressItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: progressItems.map((item) => ProgressCard(item: item)).toList(),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final ProgressItem item;

  const ProgressCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Grade Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.grade,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Progress Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),

                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: item.percentage / 100,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Percentage
          Text(
            '${item.percentage.toInt()}٪',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}