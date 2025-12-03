import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../../../../commons/utils/manager/date_manager.dart';
import '../../../shared/presentations/widgets/submit_answer_dialog.dart';
import '../../data/models/assignment_model.dart.dart';

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
    final due = item.dueDate != null ? DateFormatManager.formatDate(item.dueDate!) : null;
    final time = item.endTime ?? 'نامشخص';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Header: Icon + Title + Course + Badge ===
            Row(
              children: [
                // Icon Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    color: item.badgeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Course
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subject,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.lightGray,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: item.badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // === Details Row ===
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'تاریخ تحویل',
                    due ?? 'نامشخص',
                    Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailItem(
                    'ساعت تحویل',
                    time,
                    Icons.access_time_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailItem(
                    'امتیاز',
                    item.totalScore?.toString() ?? 'نامشخص',
                    Icons.grade_outlined,
                  ),
                ),
              ],
            ),

            // === Description ===
            if (item.description?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'توضیحات',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.lightGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColor.darkText,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // === Action Button ===
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: item.badgeColor.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColor.lightGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    // Pending: no deadline - show "ارسال پاسخ"
    if (item.status == 'pending') {
      return SizedBox(
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
                isEditing: false,
              ),
            );
          },
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('ارسال پاسخ'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Answered: deadline passed AND has answer - show "تغییر پاسخ"
    if (item.status == 'submitted') {
      return SizedBox(
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
                isEditing: true,
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('تغییر پاسخ'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Not Answered: deadline passed but NO answer - show "ارسال پاسخ"
    if (item.status == 'notSubmitted') {
      return SizedBox(
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
                isEditing: false,
              ),
            );
          },
          icon: const Icon(Icons.upload_file_rounded, size: 18),
          label: const Text('ارسال پاسخ'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Graded: deadline passed AND answered AND graded - show final score
    if (item.status == 'graded' && item.finalScore != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            children: [
              Text(
                'نمره نهایی',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.finalScore!,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default: View button
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          debugPrint('View submission: ${item.title}');
        },
        icon: const Icon(Icons.visibility_outlined, size: 18),
        label: const Text('مشاهده'),
        style: OutlinedButton.styleFrom(
          foregroundColor: item.badgeColor,
          side: BorderSide(color: item.badgeColor.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}