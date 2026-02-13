import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../data/models/student_model.dart';

class StudentDetailsDialog extends StatelessWidget {
  final StudentModel student;
  final String Function(int?) getClassName;
  final String? username;
  final String? password;

  const StudentDetailsDialog({
    super.key,
    required this.student,
    required this.getClassName,
    this.username,
    this.password,
  });

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool canCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColor.purple, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColor.lightGray,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkText,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    if (canCopy) _buildCopyButton(value),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(String text) {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.copy_rounded, size: 16),
        color: AppColor.purple,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('کپی شد', textDirection: TextDirection.rtl),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.purple.withOpacity(0.8),
                        AppColor.purple.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.purple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),

                // Login Credentials Section
                if (username != null && password != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.vpn_key_rounded,
                              color: Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'اطلاعات ورود',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'نام کاربری: $username',
                                style: const TextStyle(fontSize: 13),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            _buildCopyButton(username!),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'رمز عبور: $password',
                                style: const TextStyle(fontSize: 13),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            _buildCopyButton(password!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Divider
                Container(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 20),

                // Details
                _buildDetailRow(
                  'کلاس',
                  getClassName(student.stuClass),
                  Icons.class_rounded,
                ),
                _buildDetailRow(
                  'کد ملی',
                  student.studentCode,
                  Icons.credit_card,
                  canCopy: true,
                ),
                _buildDetailRow(
                  'تاریخ تولد',
                  student.birthDate ?? 'نامشخص',
                  Icons.cake_rounded,
                ),
                _buildDetailRow(
                  'شماره تلفن',
                  student.phone ?? 'نامشخص',
                  Icons.phone_rounded,
                  canCopy: student.phone != null,
                ),
                _buildDetailRow(
                  'شماره ولی',
                  student.parentPhone ?? 'نامشخص',
                  Icons.phone_android_rounded,
                  canCopy: student.parentPhone != null,
                ),
                _buildDetailRow(
                  'آدرس',
                  student.address ?? 'نامشخص',
                  Icons.location_on_rounded,
                ),
                _buildDetailRow(
                  'بدهی',
                  student.debt == 0 ? 'بدون بدهی' : '${student.debt} تومان',
                  student.debt > 0
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                ),

                const SizedBox(height: 24),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.purple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'بستن',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
