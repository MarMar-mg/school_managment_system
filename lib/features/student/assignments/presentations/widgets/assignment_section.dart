import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../models/assignment_model.dart.dart';
import 'assignment_card.dart';

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
    if (items.isEmpty) {
      return _emptySection();
    }

    final displayCount = isExpanded ? items.length : (items.length > 2 ? 2 : items.length);
    final showMore = items.length > 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.darkText)),
            if (items.isNotEmpty)
              Text('${items.length} مورد', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        // Container(height: 4, width: 70, color: color),
        const SizedBox(height: 16),
        ...List.generate(displayCount, (i) {
          final index = startIndex + i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedAssignmentCard(item: items[i], animation: animations[index]),
          );
        }),
        if (showMore)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: TextButton.icon(
                onPressed: onToggle,
                icon: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ),
                label: Text(
                  isExpanded ? 'نمایش کمتر' : 'نمایش همه (${items.length})',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: color.withOpacity(0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptySection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(height: 4, width: 70, color: color),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text('موردی یافت نشد', style: TextStyle(color: Colors.grey[500]))),
      ),
    ],
  );
}