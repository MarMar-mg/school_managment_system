// lib/core/widgets/score_header_card.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class ScoreHeaderCard extends StatelessWidget {
  final String studentName;
  final double gpa;

  const ScoreHeaderCard({
    super.key,
    required this.studentName,
    required this.gpa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معدل کل
                const Text(
                  'معدل کل',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),

                // ۱۸.۵
                Text(
                  gpa.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),
          // Avatar + Medal Icon
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: const Icon(
              Icons.emoji_events, // Medal icon
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
