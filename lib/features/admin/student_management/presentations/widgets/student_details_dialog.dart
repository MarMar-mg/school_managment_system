import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../data/models/student_model.dart';

class StudentDetailsDialog extends StatelessWidget {
  final StudentModel student;
  final String Function(int?) getClassName;

  const StudentDetailsDialog({
    super.key,
    required this.student,
    required this.getClassName,
  });

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColor.lightGray,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('جزئیات دانش‌آموز'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColor.primary,
            child: Text(
              student.name.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
          ),
          Text(
            'کد: ${student.studentCode}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.lightGray,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('کلاس', getClassName(student.stuClass)),
          _buildDetailRow('تاریخ تولد', student.birthDate ?? 'N/A'),
          _buildDetailRow('شماره تلفن', student.phone ?? 'N/A'),
          _buildDetailRow('شماره ولی', student.parentPhone ?? 'N/A'),
          _buildDetailRow(
            'بدهی',
            student.debt == 0 ? 'بدون بدهی' : '${student.debt} تومان',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بستن'),
        ),
      ],
    );
  }
}