// features/profile/presentations/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/commons/text_style.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // In real app → fetch from API
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'نمره جدید ثبت شد',
      'body': 'نمره درس ریاضی برای شما ثبت گردید.',
      'time': '۲ ساعت پیش',
      'read': false,
      'type': 'grade',
    },
    {
      'title': 'تکلیف جدید',
      'body': 'تکلیف جدید از درس علوم توسط معلم اضافه شد.',
      'time': 'دیروز',
      'read': true,
      'type': 'assignment',
    },
    {
      'title': 'اطلاعیه مدرسه',
      'body': 'تعطیلی مدارس به دلیل شرایط جوی تا اطلاع ثانوی',
      'time': '۳ روز پیش',
      'read': true,
      'type': 'announcement',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلان‌ها'),
        centerTitle: true,
        backgroundColor: AppColor.purple,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveContainer(
        child: _notifications.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off_outlined,
                  size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'هیچ اعلانی وجود ندارد',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notif = _notifications[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: notif['read']
                      ? Colors.grey[300]
                      : AppColor.purple.withOpacity(0.2),
                  child: Icon(
                    _getIcon(notif['type']),
                    color: notif['read']
                        ? Colors.grey[700]
                        : AppColor.purple,
                  ),
                ),
                title: Text(
                  notif['title'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  notif['body'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      notif['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (!notif['read'])
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  // Mark as read + maybe open detail
                  setState(() {
                    _notifications[index]['read'] = true;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'grade':
        return Icons.grade;
      case 'assignment':
        return Icons.assignment;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }
}