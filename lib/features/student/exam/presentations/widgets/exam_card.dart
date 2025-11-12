import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../models/exam_model.dart';

class ExamCard extends StatelessWidget {
  final ExamItem item;

  const ExamCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final due = item.dueDate != null ? _formatJalali(item.dueDate!) : null;
    final submitted = item.submittedDate != null
        ? _formatJalali(item.submittedDate!)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            // Header: Icon + Title + Course + Grade (if scored)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _headerColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: _headerColor(),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.courseName,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (item.status == ExamStatus.scored && item.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _gradeColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _gradeLetter(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // State-specific content
            if (item.status == ExamStatus.pending) ..._pendingContent(due),
            if (item.status == ExamStatus.answered)
              ..._answeredContent(submitted),
            if (item.status == ExamStatus.scored) ..._scoredContent(),

            const SizedBox(height: 16),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: item.status == ExamStatus.pending
                  ? ElevatedButton.icon(
                      onPressed: item.onReminderTap,
                      icon: const Icon(Icons.alarm, size: 18),
                      label: const Text("تنظیم یادآوری"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.purple.withOpacity(0.1),
                        foregroundColor: AppColor.purple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: item.onViewAnswer,
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: Text(item.filename ?? "مشاهده پاسخ"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.purple,
                        side: BorderSide(
                          color: AppColor.purple.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _pendingContent(String? due) => [
    Row(
      children: [
        _infoChip("ساعت", "نامشخص", Icons.access_time),
        const SizedBox(width: 12),
        _infoChip("تاریخ", due ?? "نامشخص", Icons.calendar_today),
      ],
    ),
    const SizedBox(height: 16),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          "امتحان کل 100",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    const SizedBox(height: 12),
    const Text(
      "در حال بررسی",
      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
    ),
  ];

  List<Widget> _answeredContent(String? submitted) => [
    const Text(
      "ارسال شده - در انتظار نمره",
      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
    ),
    const SizedBox(height: 8),
    Text(
      submitted ?? "نامشخص",
      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
    ),
  ];

  List<Widget> _scoredContent() {
    final percent = (item.score! / item.totalScore) * 100;
    return [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _gradeColor().withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gradeColor().withOpacity(0.3)),
            ),
            child: Text(
              "${item.score}/${item.totalScore}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _gradeColor(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${percent.toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _gradeColor(),
                ),
              ),
              Text(
                _gradeLetter(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  Widget _infoChip(String label, String value, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            "$label: $value",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    ),
  );

  Color _headerColor() => switch (item.status) {
    ExamStatus.pending => Colors.orange,
    ExamStatus.answered => Colors.blue,
    ExamStatus.scored => Colors.green,
  };

  Color _gradeColor() {
    final p = (item.score! / item.totalScore) * 100;
    if (p >= 90) return Colors.green;
    if (p >= 80) return Colors.lightGreen;
    if (p >= 70) return Colors.orange;
    if (p >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _gradeLetter() {
    final p = (item.score! / item.totalScore) * 100;
    if (p >= 90) return "A";
    if (p >= 80) return "B";
    if (p >= 70) return "C";
    if (p >= 60) return "D";
    return "F";
  }

  String _formatJalali(String jalali) {
    try {
      final y = int.parse(jalali.substring(0, 4));
      final m = int.parse(jalali.substring(4, 6));
      final d = int.parse(jalali.substring(6, 8));
      final date = Jalali(y, m, d);
      return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}'; // 1403/09/01
      // OR use full name: return date.formatter.wN; // چهارشنبه ۱ شهریور ۱۴۰۳
    } catch (e) {
      return jalali;
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
