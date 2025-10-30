import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../models/dashboard_models.dart';

class AssignmentsList extends StatelessWidget {
  final List<AssignmentItem> assignments;

  const AssignmentsList({
    Key? key,
    required this.assignments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: assignments.map((item) => AssignmentCard(item: item)).toList(),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final AssignmentItem item;

  const AssignmentCard({
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
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.badgeColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.lightGray,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: item.badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.badge,
              style: TextStyle(
                fontSize: 12,
                color: item.badgeColor,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}