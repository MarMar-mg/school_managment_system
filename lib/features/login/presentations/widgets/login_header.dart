import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';

class LoginHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const LoginHeader({
    Key? key,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onBackPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: const [
              Text(
                'تغییر نقش',
                style: TextStyle(
                  color: AppColor.gray,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColor.gray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}