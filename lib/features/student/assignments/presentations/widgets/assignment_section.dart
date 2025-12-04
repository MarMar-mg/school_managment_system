import 'package:flutter/material.dart';
import '../../data/models/assignment_model.dart.dart';
import 'assignment_card.dart';

/// Expandable section for assignments – exactly like ExamSection
/// Separates assignments into Pending, Submitted, and Graded sections
class AssignmentSection extends StatelessWidget {
  final String title;
  final int userId;
  final Color color;
  final List<AssignmentItemm> items;
  final int startIndex;
  final String sectionKey;
  final bool isExpanded;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onRefresh;
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
    required this.userId,
    required this.onRefresh,
    required this.isDone,
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

        // === CARDS (only when expanded) ===
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final globalIndex = startIndex + i;

            return AnimatedBuilder(
              animation: globalIndex < animations.length
                  ? animations[globalIndex]
                  : AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                final anim = globalIndex < animations.length
                    ? animations[globalIndex]
                    : const AlwaysStoppedAnimation(1.0);

                return Opacity(
                  opacity: anim.value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - anim.value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AssignmentCard(
                  item: item,
                  userId: userId,
                  onRefresh: onRefresh,
                  isDone: isDone,
                ),
              ),
            );
          }),
        ],

        // === EMPTY STATE ===
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
