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
  final int? estId;
  final String? totalScore;
  final String? duration;
  final String? description;
  final ExamStatus status;
  final String? answerImage;
  final String? filenameQ;
  final String? filename;
  final String? file;
  final VoidCallback? onReminderTap;
  final VoidCallback? onViewAnswer;
  final String? submittedDescription;

  ExamItem({
    required this.title,
    required this.examId,
    this.estId,
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
    this.filenameQ,
    this.filename,
    this.file,
    this.onReminderTap,
    this.onViewAnswer,
    this.startTime,
    this.endTime,
    this.submittedDescription,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final isAnswered = json['submittedDate'];
    ExamStatus parsedStatus;
    switch (statusStr.toLowerCase()) {
      case 'pending':
        parsedStatus = ExamStatus.pending;
        break;
      case 'answered':
      case 'answered_submitted':
      case 'answered_not_submitted':
        parsedStatus = ExamStatus.answered;
        break;
      case 'scored':
        parsedStatus = ExamStatus.scored;
        break;
      default:
        parsedStatus = isAnswered == null
            ? ExamStatus.pending
            : ExamStatus.answered;
    }

    parsedStatus = isAnswered == null
        ? ExamStatus.pending
        : ExamStatus.answered;

    return ExamItem(
      title: json['title'] ?? 'بدون عنوان',
      examId: json['examId'] ?? 0,
      estId: json['estId'],
      courseName: json['courseName'] ?? 'نامشخص',
      dueDate: json['dueDate'],
      submittedDate: json['submittedDate'],
      submittedTime: json['submittedTime'],
      score: json['score'],
      totalScore: json['totalScore'],
      duration: json['duration'],
      description: json['description'],
      status: parsedStatus,
      answerImage: json['answerImage'],
      filenameQ: json['filenameQ'],
      filename: json['filename'],
      file: json['file'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      submittedDescription: json['submittedDescription'],
    );
  }
}
