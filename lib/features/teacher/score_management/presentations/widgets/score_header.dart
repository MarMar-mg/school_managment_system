import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class ScoreHeader extends StatelessWidget {
  const ScoreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'مدیریت نمرات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 4),
        Text(
          'تصحیح و پیگیری نمرات دانش‌آموزان',
          style: TextStyle(
            fontSize: 13,
            color: AppColor.lightGray,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
