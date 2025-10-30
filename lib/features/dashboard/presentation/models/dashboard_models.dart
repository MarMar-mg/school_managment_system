import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';

// ────────────────────── MODELS ──────────────────────

class StatCard {
  final String value;
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;

  StatCard({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
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
  final String subject;
  final String title;
  final String dueDate;
  final String badge;
  final Color badgeColor;
  final IconData icon;

  AssignmentItem({
    required this.subject,
    required this.title,
    required this.dueDate,
    required this.badge,
    required this.badgeColor,
    required this.icon,
  });
}

class ProgressItem {
  final String subject;
  final String grade;
  final double percentage;
  final Color color;

  ProgressItem({
    required this.subject,
    required this.grade,
    required this.percentage,
    required this.color,
  });
}

// ────────────────────── DATA PROVIDER ──────────────────────

class DashboardData {
  static List<StatCard> getStats() {
    return [
      StatCard(
        value: '۶',
        label: 'دروس',
        subtitle: 'ترم پاییز ۱۴۰۴',
        color: const Color(0xFF4A90E2),
        icon: Icons.book_rounded,
      ),
      StatCard(
        value: '۱۸.۵',
        label: 'معدل',
        subtitle: 'در ۸۰ واحد درسی',
        color: const Color(0xFF9B59B6),
        icon: Icons.school_rounded,
      ),
      StatCard(
        value: '۱۵',
        label: 'واحد',
        subtitle: 'ترم جاری',
        color: const Color(0xFF50C878),
        icon: Icons.schedule_rounded,
      ),
      StatCard(
        value: '۴',
        label: 'تکالیف',
        subtitle: '۲ تایم هفتگی',
        color: const Color(0xFFFF6B35),
        icon: Icons.alarm_rounded,
      ),
    ];
  }

  static List<NewsItem> getNews() {
    return [
      NewsItem(
        title: 'آغاز ثبت‌نام ترم بهار',
        subtitle: '۱۴۰۴ آبان ۲۰',
        date: 'امروز',
        icon: Icons.campaign_rounded,
        iconColor: AppColor.purple,
      ),
      NewsItem(
        title: 'مهلت انتخاب واحد تا ۲۵ آبان',
        subtitle: '۱۴۰۴ آبان ۱۸',
        date: 'دیروز',
        icon: Icons.event_note_rounded,
        iconColor: Colors.blue,
      ),
    ];
  }

  static List<EventItem> getEvents() {
    return [
      EventItem(
        title: 'امتحانات میان‌ترم',
        subtitle: 'از ۱۴ آذر آغاز می‌شود',
        date: '۱۴۰۴ آذر ۱۴',
        icon: Icons.assignment_outlined,
        iconColor: Colors.red,
      ),
      EventItem(
        title: 'تعطیلات نیمسال',
        subtitle: '۱ تا ۱۴ آذر',
        date: '۱۴۰۴ آذر ۱',
        icon: Icons.event_rounded,
        iconColor: Colors.orange,
      ),
    ];
  }

  static List<AssignmentItem> getAssignments() {
    return [
      AssignmentItem(
        subject: 'ریاضی ۳',
        title: 'آزمون ریاضی ۳',
        dueDate: 'فردا',
        badge: 'فوری',
        badgeColor: Colors.red,
        icon: Icons.calculate_rounded,
      ),
      AssignmentItem(
        subject: 'شیمی',
        title: 'گزارش آزمایشگاه',
        dueDate: '۴ آبان',
        badge: '۴ آبان',
        badgeColor: Colors.orange,
        icon: Icons.science_rounded,
      ),
      AssignmentItem(
        subject: 'تاریخ',
        title: 'پیش‌نویس مقاله',
        dueDate: '۶ آبان',
        badge: '۶ آبان',
        badgeColor: Colors.blue,
        icon: Icons.history_edu_rounded,
      ),
    ];
  }

  static List<ProgressItem> getProgress() {
    return [
      ProgressItem(
        subject: 'ریاضی ۳',
        grade: '-۸',
        percentage: 88,
        color: Colors.red,
      ),
      ProgressItem(
        subject: 'شیمی ۱',
        grade: 'A',
        percentage: 92,
        color: Colors.blue,
      ),
      ProgressItem(
        subject: 'تاریخ جهان',
        grade: '+۸',
        percentage: 85,
        color: Colors.green,
      ),
      ProgressItem(
        subject: 'علوم کامپیوتر',
        grade: 'A',
        percentage: 94,
        color: Colors.blue,
      ),
    ];
  }
}