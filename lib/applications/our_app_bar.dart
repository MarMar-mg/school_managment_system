import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final Role role;

  const DashboardAppBar({
    Key? key,
    required this.userName,
    required this.role,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: role.gradient.first.withOpacity(0.15),
          child: Text(
            userName.isNotEmpty ? userName[0] : 'ع',
            style: TextStyle(
              color: role.gradient.first,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
      title: Text(
        'سلام، $userName',
        style: const TextStyle(
          color: AppColor.darkText,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textDirection: TextDirection.rtl,
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColor.purple,
                size: 24,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}