import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../models/assignment_model.dart.dart';

class AnimatedAssignmentCard extends StatelessWidget {
  final AssignmentItemm item;
  final Animation<double> animation;
  const AnimatedAssignmentCard({super.key, required this.item, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 60 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: AssignmentCard(item: item),
    );
  }
}

class AssignmentCard extends StatelessWidget {
  final AssignmentItemm item;
  const AssignmentCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: item.badgeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                child: Icon(item.icon, color: item.badgeColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.darkText)),
                  Text(item.subject, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: item.badgeColor, borderRadius: BorderRadius.circular(12)),
                child: Text(item.badgeText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (item.description?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(item.description!, style: TextStyle(color: Colors.grey[700], height: 1.5)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (item.dueDate != null)
                Row(children: [
                  const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(item.dueDate!, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                ]),
              const Spacer(),
              if (item.totalScore != null && item.totalScore != 'نامشخص')
                Text('${item.totalScore}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          if (item.status == 'pending') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file, size: 20, color: Colors.white),
                label: Text('ارسال پاسخ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.badgeColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
          if (item.status == 'graded' && item.finalScore != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(item.finalScore!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[700])),
                // const SizedBox(width: 12),
                // Text('', style: TextStyle(fontSize: 18, color: Colors.green[700])),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}