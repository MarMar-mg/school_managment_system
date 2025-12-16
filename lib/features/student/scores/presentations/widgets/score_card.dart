import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/features/student/scores/presentations/widgets/subject_score_details_dialog.dart';

class ScoreCard extends StatelessWidget {
  final String subject;
  final int percent;
  final String letterGrade;
  final List<SubScore> subScores;
  final int studentId;

  const ScoreCard({
    super.key,
    required this.subject,
    required this.percent,
    required this.letterGrade,
    required this.subScores,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // === Header Row ===
          Row(
            children: [
              // Percent + Subject
              Expanded(
                child: Text(
                  percent == -1? '$subject --': '$subject ($percent%) ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkText,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Book Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColor.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.book, color: Colors.white, size: 24),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Letter Grade
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _gradeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                letterGrade,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _gradeColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // === Sub‑Scores ===
          ...subScores.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSubScoreRow(s),
          )),

          const SizedBox(height: 12),

          // Details Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                showSubjectScoreDetailsDialog(
                  context,
                  subject: subject,
                  studentId: studentId,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('جزئیات نمرات'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubScoreRow(SubScore s) {
    return Row(
      children: [
        // Percent
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              s.percent == -1? '--': '${s.percent}%',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColor.darkText,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Progress Bar
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: s.percent == -1? 0: s.percent / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Label
        Expanded(
          flex: 2,
          child: Text(
            s.label,
            style: const TextStyle(fontSize: 14, color: AppColor.darkText),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color get _gradeColor {
    final p = percent;
    if (p >= 90) return const Color(0xFF9C27B0);
    if (p >= 80) return Colors.green;
    if (p >= 70) return Colors.orange;
    return Colors.red;
  }
}

// === Model ===
class SubScore {
  final int percent;
  final String label;
  SubScore({required this.percent, required this.label});
}