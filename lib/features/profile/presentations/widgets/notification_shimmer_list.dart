
// features/profile/presentations/widgets/notification_shimmer_list.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NotificationShimmerList extends StatelessWidget {
  const NotificationShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 26,
            ),
            title: Container(width: 180, height: 16, color: Colors.white),
            subtitle: Container(
              width: 240,
              height: 12,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
            ),
          ),
        ),
      ),
    );
  }
}