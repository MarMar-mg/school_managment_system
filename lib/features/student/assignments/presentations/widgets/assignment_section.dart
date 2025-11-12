import 'package:flutter/material.dart';
import '../../models/assignment_model.dart.dart';
import 'assignment_card.dart';

/// Expandable section – works exactly like ExamSection
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === HEADER (tap to expand) ===
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: color,
                ),
                const SizedBox(width: 12),
                Text(
                  '$title (${items.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // === CARDS (only when expanded) ===
        if (isExpanded)
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final globalIndex = startIndex + i;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14, right:8, left: 8),
              child: AnimatedAssignmentCard(
                item: item,
                animation: animations[globalIndex],
              ),
            );
          }),
        // Empty state
        if (isExpanded && items.isEmpty) _buildEmptyState(),

        const SizedBox(height: 8),
      ],
    );
  }

  // === EMPTY STATE ===
  Column _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
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
