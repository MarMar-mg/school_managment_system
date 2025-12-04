import 'package:flutter/material.dart';

enum ExamStatus { pending, answered, scored }

class ExamItem {
  final String title;
  final String courseName;
  final String? dueDate;
  final String? startTime;
  final String? endTime;
  final String? submittedDate;
  final String? submittedTime;
  final int? score;
  final int examId;
  final String? totalScore;
  final String? duration;
  final String? description;
  final ExamStatus status;
  final String? answerImage;
  final String? filename;
  final VoidCallback? onReminderTap;
  final VoidCallback? onViewAnswer;
  final String? submittedDescription;

  ExamItem({
    required this.title,
    required this.examId,
    required this.courseName,
    this.dueDate,
    this.submittedDate,
    this.submittedTime,
    this.score,
    required this.totalScore,
    required this.duration,
    required this.description,
    required this.status,
    this.answerImage,
    this.filename,
    this.onReminderTap,
    this.onViewAnswer,
    this.startTime,
    this.endTime,
    this.submittedDescription,
  });
}
