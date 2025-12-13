import 'package:flutter/material.dart';
import '../../../../../applications/colors.dart';
import '../../../../../commons/utils/manager/date_manager.dart';


class AssignmentItemm {
  final int id;
  final int? estId;
  final String title;
  final String subject;
  final String? description;
  final String? dueDate; // "1403-08-25"
  final String? endTime;
  final String? totalScore;
  final bool isUrgent;
  final String status; // pending | submitted | graded
  final String? finalScore;
  final String? filenameQ;
  final String? filename;
  final String? file;
  final String? submittedDescription;

  const AssignmentItemm({
    required this.id,
    this.estId,
    required this.title,
    required this.subject,
    this.description,
    this.dueDate,
    this.totalScore,
    this.isUrgent = false,
    required this.status,
    this.finalScore,
    this.endTime,
    this.file,
    this.filenameQ,
    this.filename,
    this.submittedDescription,
  });

  factory AssignmentItemm.fromJson(Map<String, dynamic> json) {
    final String status = json['status'] ?? 'pending';
    final bool urgent = json['isUrgent'] == true;

    return AssignmentItemm(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      subject: json['courseName'] ?? 'نامشخص',
      description: json['description'],
      dueDate: json['dueDate'],
      endTime: json['endTime'],
      totalScore: json['totalScore'],
      isUrgent: urgent,
      status: status,
      finalScore: json['finalScore'],
      filenameQ: json['filenameQ'],
      filename: json['filename'],
      file: json['file'],
      submittedDescription: json['submittedDescription'],
      estId: json['estId'],
    );
  }

  // برای سازگاری کامل با همه ویجت‌ها
  String get badge => switch (status) {
    'graded' => finalScore ?? 'نمره‌دار',
    'submitted' => 'ارسال شده',
    'notSubmitted' => 'ارسال نشده',
    _ =>
    isUrgent
        ? 'فوری'
        : dueDate != null
        ? DateFormatManager.formatDate(dueDate!)
        : 'در انتظار',
  };

  String get badgeText => badge; // این خط خطا رو حل می‌کنه!

  Color get badgeColor => switch (status) {
    'graded' => Colors.green,
    'submitted' => Colors.orange,
    _ => isUrgent ? Colors.red : AppColor.blue,
  };

  IconData get icon => switch (status) {
    'graded' => Icons.check_circle_rounded,
    'submitted' => Icons.send_rounded,
    _ => isUrgent ? Icons.warning_rounded : Icons.assignment_rounded,
  };
}

