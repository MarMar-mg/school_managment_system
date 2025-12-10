import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class SubmissionStats extends StatelessWidget {
  final List<dynamic> submissions;
  final dynamic maxScore;

  const SubmissionStats({
    super.key,
    required this.submissions,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    int graded = 0;
    double totalScore = 0;
    List<int> scores = [];

    for (var student in submissions) {
      if (student['hasSubmitted'] == true && student['score'] != null) {
        graded++;
        int score = student['score'] is int
            ? student['score']
            : int.tryParse(student['score'].toString()) ?? 0;
        scores.add(score);
        totalScore += score;
      }
    }

    double average = graded > 0 ? totalScore / graded : 0;
    int minScore = scores.isNotEmpty ? scores.reduce((a, b) => a < b ? a : b) : 0;
    int maxScoreVal = scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 0;

    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'پایین‌ترین',
            value: '$minScore',
            color: AppColor.purple,
            icon: Icons.trending_down_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            label: 'بالاترین',
            value: '$maxScoreVal',
            color: Colors.green,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            label: 'میانگین',
            value: average.toStringAsFixed(1),
            color: AppColor.purple,
            icon: Icons.equalizer_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColor.lightGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}