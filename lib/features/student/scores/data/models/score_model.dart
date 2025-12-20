// lib/features/student/scores/models/score_model.dart
import 'package:flutter/material.dart';

class DashboardData {
  final String studentName;
  final double gpa;
  final int bells, courses, units;
  final List<SubjectGrade> grades;

  DashboardData({
    required this.studentName,
    required this.gpa,
    required this.bells,
    required this.courses,
    required this.units,
    required this.grades,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> g = json['grades'] ?? [];
    return DashboardData(
      studentName: json['studentName'] ?? 'نامشخص',
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0,
      bells: json['bells'] ?? 0,
      courses: json['courses'] ?? 0,
      units: json['units'] ?? 0,
      grades: g.map((e) => SubjectGrade.fromJson(e)).toList(),
    );
  }
}

class SubjectGrade {
  final String name;
  final int percent;
  final double avgExam;
  final double avgExercise;
  final String letter;
  final Color color;
  final bool isTop;

  SubjectGrade({
    required this.name,
    required this.percent,
    required this.avgExam,
    required this.avgExercise,
    required this.letter,
    required this.color,
    this.isTop = false,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    final p = (json['percent'] as num).toInt();
    return SubjectGrade(
      name: json['name'] ?? '',
      percent: p,
      letter: p ==0? 'بدون نمره': _letter(p),
      color: _color(p),
      isTop: json['isTop'] == true,
      avgExam: json['avgExams'],
      avgExercise: json['avgExercises'],
    );
  }

  static String _letter(int p) => p >= 90
      ? 'A'
      : p >= 85
      ? 'A-'
      : p >= 80
      ? 'B+'
      : p >= 75
      ? 'B'
      : p >= 70
      ? 'B-'
      : p >= 60
      ? 'C'
      : 'F';

  static Color _color(int p) => p >= 90
      ? const Color(0xFF9C27B0)
      : p >= 80
      ? Colors.green
      : p >= 70
      ? Colors.orange
      : Colors.red;
}
