import 'package:flutter/material.dart';

enum ExamStatus { pending, answered, scored }

class ExamItem {
  final String title;
  final String courseName;
  final String? dueDate;
  final String? startTime;
  final String? endTime;
  final String? submittedDate;
  final int? score;
  final int totalScore;
  final ExamStatus status;
  final String? answerImage;
  final String? filename;
  final VoidCallback? onReminderTap;
  final VoidCallback? onViewAnswer;

  ExamItem({
    required this.title,
    required this.courseName,
    this.dueDate,
    this.submittedDate,
    this.score,
    this.totalScore = 100,
    required this.status,
    this.answerImage,
    this.filename,
    this.onReminderTap,
    this.onViewAnswer,
    this.startTime,
    this.endTime,
  });
}
