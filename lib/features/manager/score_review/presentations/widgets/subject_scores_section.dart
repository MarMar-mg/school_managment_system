import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class SubjectScoresSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const SubjectScoresSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'میانگین نمرات درسی',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          ...((data['subjectScores'] as List<dynamic>?) ?? [])
              .map((subject) => SubjectScoreRow(subject: subject))
              ,
        ],
      ),
    );
  }
}

class SubjectScoreRow extends StatelessWidget {
  final dynamic subject;

  const SubjectScoreRow({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final avgScore = (subject['avgScore'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            subject['name'] ?? 'نامشخص',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.purple.withOpacity(0.3)),
            ),
            child: Text(
              avgScore.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColor.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}