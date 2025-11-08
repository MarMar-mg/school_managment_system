import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final String actionText;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
    this.actionText = 'مشاهده همه',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        // GestureDetector(
        //   onTap: onSeeAll,
        //   child: Text(
        //     actionText,
        //     style: const TextStyle(
        //       fontSize: 14,
        //       fontWeight: FontWeight.w600,
        //       color: AppColor.purple,
        //     ),
        //     textDirection: TextDirection.rtl,
        //   ),
        // ),
      ],
    );
  }
}
