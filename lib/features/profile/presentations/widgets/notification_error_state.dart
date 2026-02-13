import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class NotificationErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const NotificationErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 80, color: Colors.red[400]),
          const SizedBox(height: 24),
          Text(
            'خطا در بارگذاری اعلان‌ها',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[700]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          ),
        ],
      ),
    );
  }
}