import 'package:flutter/material.dart';

class NotificationEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NotificationEmptyState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 90,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'هیچ اعلانی در حال حاضر وجود ندارد',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (onRetry != null)
            OutlinedButton(onPressed: onRetry, child: const Text('تلاش مجدد')),
        ],
      ),
    );
  }
}
