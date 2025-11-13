import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';

// ────────────────────── MODELS ──────────────────────

class StatCard {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  factory StatCard.fromJson(Map<String, dynamic> json) {
    return StatCard(
      label: json['label'] ?? '',
      value: json['value'] ?? '0',
      subtitle: json['subtitle'] ?? '',
      icon: _getIcon(json['icon'] ?? 'info'),
      color: _getColor(json['color'] ?? 'blue'),
    );
  }

  static IconData _getIcon(String name) {
    switch (name) {
      case 'person': return Icons.person;
      case 'group': return Icons.group;
      case 'school': return Icons.school;
      case 'course': return Icons.menu_book;
      case 'score': return Icons.star;
      case 'grade': return Icons.score;
      case 'assignment': return Icons.assignment;
      case 'event': return Icons.event;
      default: return Icons.info;
    }
  }

  static Color _getColor(String name) {
    switch (name) {
      case 'purple': return Colors.purple;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'red': return Colors.red;
      default: return Colors.blue;
    }
  }
}

class NewsItem {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color iconColor;

  NewsItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconColor,
  });
}

class EventItem {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color iconColor;

  EventItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconColor,
  });
}

class AssignmentItem {
  final String title;
  final String subject;
  final String badge;
  final Color badgeColor;
  final IconData icon;
  final String endTime;

  AssignmentItem({
    required this.title,
    required this.subject,
    required this.badge,
    required this.badgeColor,
    required this.icon,
    required  this.endTime,
  });
}

class ProgressItem {
  final String subject;
  final double percentage;
  final String grade;
  final Color color;

  ProgressItem({
    required this.subject,
    required this.percentage,
    required this.grade,
    required this.color,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    final percent = (json['average'] as num).toDouble();
    final grade = _getGrade(percent);
    final color = _getColor(percent);

    return ProgressItem(
      subject: json['courseName'] ?? 'نامشخص',
      percentage: percent,
      grade: grade,
      color: color,
    );
  }

  static String _getGrade(double percent) {
    if (percent >= 90) return 'A';
    if (percent >= 80) return 'B';
    if (percent >= 70) return 'C';
    if (percent >= 60) return 'D';
    return 'F';
  }

  static Color _getColor(double percent) {
    if (percent >= 90) return Colors.green;
    if (percent >= 80) return Colors.lightGreen;
    if (percent >= 70) return Colors.yellow;
    if (percent >= 60) return Colors.orange;
    return Colors.red;
  }
}

// ────────────────────── DATA PROVIDER ──────────────────────
//
// class DashboardData {
//   static List<StatCard> getStats() {
//     return [
//       StatCard(
//         value: '۶',
//         label: 'دروس',
//         subtitle: 'ترم پاییز ۱۴۰۴',
//         color: const Color(0xFF4A90E2),
//         icon: Icons.book_rounded,
//       ),
//       StatCard(
//         value: '۱۸.۵',
//         label: 'معدل',
//         subtitle: 'در ۸۰ واحد درسی',
//         color: const Color(0xFF9B59B6),
//         icon: Icons.school_rounded,
//       ),
//       StatCard(
//         value: '۱۵',
//         label: 'واحد',
//         subtitle: 'ترم جاری',
//         color: const Color(0xFF50C878),
//         icon: Icons.schedule_rounded,
//       ),
//       StatCard(
//         value: '۴',
//         label: 'تکالیف',
//         subtitle: '۲ تایم هفتگی',
//         color: const Color(0xFFFF6B35),
//         icon: Icons.alarm_rounded,
//       ),
//     ];
//   }
//
//   static List<NewsItem> getNews() {
//     return [
//       NewsItem(
//         title: 'آغاز ثبت‌نام ترم بهار',
//         subtitle: '۱۴۰۴ آبان ۲۰',
//         date: 'امروز',
//         icon: Icons.campaign_rounded,
//         iconColor: AppColor.purple,
//       ),
//       NewsItem(
//         title: 'مهلت انتخاب واحد تا ۲۵ آبان',
//         subtitle: '۱۴۰۴ آبان ۱۸',
//         date: 'دیروز',
//         icon: Icons.event_note_rounded,
//         iconColor: Colors.blue,
//       ),
//     ];
//   }

  // static List<EventItem> getEvents() {
  //   return [
  //     EventItem(
  //       title: 'امتحانات میان‌ترم',
  //       subtitle: 'از ۱۴ آذر آغاز می‌شود',
  //       date: '۱۴۰۴ آذر ۱۴',
  //       icon: Icons.assignment_outlined,
  //       iconColor: Colors.red,
  //     ),
  //     EventItem(
  //       title: 'تعطیلات نیمسال',
  //       subtitle: '۱ تا ۱۴ آذر',
  //       date: '۱۴۰۴ آذر ۱',
  //       icon: Icons.event_rounded,
  //       iconColor: Colors.orange,
  //     ),
  //   ];
  // }

  // static List<AssignmentItem> getAssignments() {
  //   return [
  //     AssignmentItem(
  //       subject: 'ریاضی ۳',
  //       title: 'آزمون ریاضی ۳',
  //       badge: 'فوری',
  //       badgeColor: Colors.red,
  //       icon: Icons.calculate_rounded,
  //     ),
  //     AssignmentItem(
  //       subject: 'شیمی',
  //       title: 'گزارش آزمایشگاه',
  //       badge: '۴ آبان',
  //       badgeColor: Colors.orange,
  //       icon: Icons.science_rounded,
  //     ),
  //     AssignmentItem(
  //       subject: 'تاریخ',
  //       title: 'پیش‌نویس مقاله',
  //       badge: '۶ آبان',
  //       badgeColor: Colors.blue,
  //       icon: Icons.history_edu_rounded,
  //     ),
  //   ];
  // }

//   static List<ProgressItem> getProgress() {
//     return [
//       ProgressItem(
//         subject: 'ریاضی ۳',
//         grade: '-۸',
//         percentage: 88,
//         color: Colors.red,
//       ),
//       ProgressItem(
//         subject: 'شیمی ۱',
//         grade: 'A',
//         percentage: 92,
//         color: Colors.blue,
//       ),
//       ProgressItem(
//         subject: 'تاریخ جهان',
//         grade: '+۸',
//         percentage: 85,
//         color: Colors.green,
//       ),
//       ProgressItem(
//         subject: 'علوم کامپیوتر',
//         grade: 'A',
//         percentage: 94,
//         color: Colors.blue,
//       ),
//     ];
//   }
// }