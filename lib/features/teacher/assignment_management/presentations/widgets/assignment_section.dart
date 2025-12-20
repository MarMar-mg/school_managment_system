import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'assignment_card.dart';

class AssignmentTeacherSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<dynamic> items;
  final int startIndex;
  final String sectionKey;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Animation<double>> animations;
  final Function(dynamic) onEdit;
  final Function(dynamic) onDelete;
  final int userId;

  const AssignmentTeacherSection({
    super.key,
    required this.title,
    required this.color,
    required this.items,
    required this.startIndex,
    required this.sectionKey,
    required this.isExpanded,
    required this.onToggle,
    required this.animations,
    required this.onEdit,
    required this.onDelete,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header - Tap to expand/collapse
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

        // Cards - Only visible when expanded
        if (isExpanded)
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final globalIndex = startIndex + i;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AnimatedAssignmentTeacherCard(
                data: item,
                animation: globalIndex < animations.length
                    ? animations[globalIndex]
                    : AlwaysStoppedAnimation(1.0),
                onEdit: () => onEdit(item),
                onDelete: () => onDelete(item),
                isActive: sectionKey == 'active',
                userId: userId,
              ),
            );
          }),

        // Empty state
        if (isExpanded && items.isEmpty) _buildEmptyState(),

        const SizedBox(height: 8),
      ],
    );
  }

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
                  'تمرینی یافت نشد',
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

class AnimatedAssignmentTeacherCard extends StatelessWidget {
  final dynamic data;
  final Animation<double> animation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isActive;
  final int userId;

  const AnimatedAssignmentTeacherCard({
    super.key,
    required this.data,
    required this.animation,
    required this.onEdit,
    required this.onDelete,
    required this.isActive,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: TeacherAssignmentCard(
        data: data,
        onEdit: onEdit,
        onDelete: onDelete,
        isActive: isActive,
        userId: userId,
      ),
    );
  }
}
