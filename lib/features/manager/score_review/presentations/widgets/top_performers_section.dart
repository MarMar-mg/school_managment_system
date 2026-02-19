import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class TopPerformersSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const TopPerformersSection({super.key, required this.data});

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
            'برترین عملکردها',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          ...((data['topPerformers'] as List<dynamic>?) ?? [])
              .map((performer) => PerformerCard(performer: performer))
              .toList(),
        ],
      ),
    );
  }
}

class PerformerCard extends StatelessWidget {
  final dynamic performer;

  const PerformerCard({required this.performer});

  @override
  Widget build(BuildContext context) {
    final avgScore = (performer['avgScore'] as num?)?.toDouble() ?? 0;
    final rank = (performer['rank'] as num?)?.toInt() ?? 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColor.purple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performer['studentName'] ?? 'نامشخص',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkText,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    'نمره: ${avgScore.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.lightGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}