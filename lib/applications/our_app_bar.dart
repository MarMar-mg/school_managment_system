// applications/our_app_bar.dart
import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Role role;
  final int userId;

  const DashboardAppBar({
    super.key,
    required this.role,
    required this.userId,
  });

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _DashboardAppBarState extends State<DashboardAppBar> {
  late Future<String> _nameFuture;

  @override
  void initState() {
    super.initState();
    _nameFuture = ApiService.getUserDisplayName(widget.role, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: widget.role.gradient.first.withOpacity(0.15),
          child: FutureBuilder<String>(
            future: _nameFuture,
            builder: (context, snapshot) {
              final initial = snapshot.data?.isNotEmpty == true
                  ? snapshot.data![0]
                  : 'ع';
              return Text(
                initial,
                style: TextStyle(
                  color: widget.role.gradient.first,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              );
            },
          ),
        ),
      ),
      title: FutureBuilder<String>(
        future: _nameFuture,
        builder: (context, snapshot) {
          final name = snapshot.data ?? 'در حال بارگذاری...';
          return Text(
            'سلام، $name',
            style: const TextStyle(
              color: AppColor.darkText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textDirection: TextDirection.rtl,
          );
        },
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColor.purple, size: 24),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}