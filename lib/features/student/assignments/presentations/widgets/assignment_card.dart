import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../../../../commons/utils/manager/date_manager.dart';
import '../../../shared/presentations/widgets/submit_answer_dialog.dart';
import '../../data/models/assignment_model.dart.dart';

/// Subtle, elegant entrance animation – feels premium, not flashy
class AnimatedAssignmentCard extends StatelessWidget {
  final int userId;
  final VoidCallback? onRefresh;
  final AssignmentItemm item;
  final Animation<double> animation;

  const AnimatedAssignmentCard({
    super.key,
    required this.item,
    required this.animation,
    required this.userId,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - animation.value)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        );
      },
      child: AssignmentCard(item: item, userId: userId,),
    );
  }
}

/// Clean, modern, perfectly balanced AssignmentCard
class AssignmentCard extends StatelessWidget {
  final AssignmentItemm item;
  final int userId;
  final VoidCallback? onRefresh;

  const AssignmentCard({
    super.key,
    required this.item,
    required this.userId,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Badge
          Row(
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: item.badgeColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: item.badgeColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(item.icon, color: item.badgeColor, size: 32),
              ),

              const SizedBox(width: 16),

              // Title & Subject
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subject,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: item.badgeColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  item.badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          // Description
          if (item.description?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              'توضبحات: ${item.description!}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Due Date + Score
          Row(
            children: [
              if (item.dueDate != null) ...[
                Icon(
                  Icons.calendar_today_rounded,
                  size: 19,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormatManager.formatDate(item.dueDate!)}(${item.endTime})',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              if (item.totalScore != null && item.totalScore != 'نامشخص')
                Text(
                  'نمره از ${item.totalScore!}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
            ],
          ),

          // Action Button (Pending)
          if (item.status == 'pending') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) => SubmitAnswerDialog(
                      type: 'assignment',
                      id: item.id,
                      userId: userId,
                      onSubmitted: onRefresh,
                    ),
                  );
                },
                icon: const Icon(Icons.upload_file_rounded, size: 22),
                label: const Text(
                  'ارسال پاسخ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.badgeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],

          // Final Grade (Graded)
          if (item.status == 'graded' && item.finalScore != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  item.finalScore!,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
