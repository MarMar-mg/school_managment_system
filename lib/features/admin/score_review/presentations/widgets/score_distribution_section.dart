import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class ScoreDistributionSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const ScoreDistributionSection({super.key, required this.data});

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
            'توزیع تفصیلی نمرات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          ...((data['scoreRanges'] as List<dynamic>?) ?? [])
              .map((range) => ScoreRangeRow(range: range))
              .toList(),
        ],
      ),
    );
  }
}

class ScoreRangeRow extends StatelessWidget {
  final dynamic range;

  const ScoreRangeRow({required this.range});

  @override
  Widget build(BuildContext context) {
    final count = (range['count'] as num?)?.toInt() ?? 0;
    final percentage = (range['percentage'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              range['range'] ?? 'نامشخص',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor:
                    percentage > 0 ? (percentage / 100.0) : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$count نفر ($percentage%)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}