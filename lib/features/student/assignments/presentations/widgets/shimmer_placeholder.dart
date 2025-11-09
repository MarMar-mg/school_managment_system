// features/student/assignments/presentation/widgets/shimmer_placeholder.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: List.generate(3, (_) => Expanded(child: Container(margin: const EdgeInsets.only(left: 12), height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))))),
            const SizedBox(height: 24),
            ...List.generate(6, (_) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(height: 170, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))))),
          ],
        ),
      ),
    );
  }
}