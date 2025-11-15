import 'package:flutter/material.dart';
import '../../entities/models/exam_model.dart';
import 'exam_card.dart' hide ExamItem;

class ExamSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<ExamItem> items;
  final int startIndex;
  final String sectionKey;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Animation<double>> animations;

  const ExamSection({
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
      children: [
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          ...items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final globalIndex = startIndex + i;
            return AnimatedBuilder(
              animation: animations[globalIndex],
              builder: (_, child) => Opacity(
                opacity: animations[globalIndex].value,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - animations[globalIndex].value)),
                  child: child,
                ),
              ),
              child: ExamCard(item: item),
            );
          }),
        ],
        // Empty state
        if (isExpanded && items.isEmpty) _buildEmptyState(),
        const SizedBox(height: 8),
      ],
    );
  }
}// === EMPTY STATE ===
Column _buildEmptyState() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Container(
        width: 300,
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

