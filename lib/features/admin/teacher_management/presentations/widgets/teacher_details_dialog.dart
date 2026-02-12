import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../data/models/teacher_model.dart';

class TeacherDetailsDialog extends StatelessWidget {
  final TeacherModel teacher;

  const TeacherDetailsDialog({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person, color: AppColor.purple),
          const SizedBox(width: 12),
          Expanded(child: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(Icons.badge, 'شناسه', teacher.teacherId.toString()),
            _buildRow(Icons.phone, 'شماره موبایل', teacher.phone ?? 'ثبت نشده'),
            _buildRow(Icons.credit_card, 'کد ملی', teacher.nationalCode ?? 'ثبت نشده'),
            _buildRow(Icons.email, 'ایمیل', teacher.email ?? 'ثبت نشده'),
            _buildRow(Icons.psychology, 'تخصص', teacher.specialty ?? 'ثبت نشده'),

            const Divider(height: 24),

            // Show login info only if available
            if (teacher.username != null) ...[
              _buildRow(Icons.account_circle, 'نام کاربری', teacher.username!, bold: true),
            ],
            if (teacher.password != null) ...[
              _buildRow(Icons.lock, 'رمز عبور اولیه', teacher.password!, color: (teacher.password == '12345678')? Colors.red: Colors.black, bold: true),
              if (teacher.password == '12345678')
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 40),
                child: Text(
                  'این رمز فقط برای بار اول است. لطفاً فوراً تغییر دهید.',
                  style: TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic),
                ),
              ),
            ],

            if (teacher.username == null && teacher.password == null)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'حساب کاربری برای این معلم ایجاد نشده است',
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ),
            //
            // const Divider(height: 24),
            // _buildRow(Icons.calendar_today, 'تاریخ ایجاد', teacher.createdAt?.toString() ?? 'نامشخص'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بستن'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildRow(IconData icon, String label, String value, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    color: color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}