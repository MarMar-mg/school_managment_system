import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';

class DemoInfoCard extends StatelessWidget {
  final String userName;
  final String password;

  const DemoInfoCard({
    super.key,
    required this.userName,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.lightYellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFE5B4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اطلاعات ورود آزمایشی:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          _buildInfoRow('نام کاربری:', userName),
          const SizedBox(height: 4),
          _buildInfoRow('رمز عبور:', password),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColor.darkText,
          ),
        ),
      ],
    );
  }
}