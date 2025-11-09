// features/assignments/presentation/widgets/assignment_section.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../models/assignment_model.dart.dart';
import 'assignment_card.dart';

/// Clean, elegant, perfectly animated collapsible section
class AssignmentSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<AssignmentItemm> items;
  final int startIndex;
  final String sectionKey;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Animation<double>> animations;

  const AssignmentSection({
    super.key,
    required this.title,
    required this.color,
    required this.items,
    required this.startIndex,
    required this.sectionKey,
    required this.isExpanded,
    required this.onToggle,
    required this.animations,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final displayCount = isExpanded ? items.length : (items.length > 2 ? 2 : items.length);
    final hasMore = items.length > 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${items.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Cards
        ...List.generate(displayCount, (i) {
          final globalIndex = startIndex + i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AnimatedAssignmentCard(
              item: items[i],
              animation: animations[globalIndex],
            ),
          );
        }),

        // Show More / Less Button
        if (hasMore) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onToggle,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                backgroundColor: color.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'نمایش کمتر' : 'نمایش همه (${items.length})',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: color,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '0',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.assignment_late_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'موردی یافت نشد',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}