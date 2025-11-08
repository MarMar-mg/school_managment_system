import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
import '../models/dashboard_models.dart';

/// Animated list of subject progress with shimmer loading & staggered card entrance
class ProgressList extends StatefulWidget {
  final Role role;
  final int userId;

  const ProgressList({
    super.key,
    required this.role,
    required this.userId,
  });

  @override
  State<ProgressList> createState() => _ProgressListState();
}

class _ProgressListState extends State<ProgressList>
    with TickerProviderStateMixin {
  late Future<List<ProgressItem>> _progressFuture;
  late AnimationController _controller;
  late List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _progressFuture = ApiService.getProgress(
      role: widget.role,
      userId: widget.userId,
    );

    // Animation controller for staggered card entrance
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Will be populated when data arrives
    _cardAnims = [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Start staggered animation when data is loaded
  void _startCardAnimations(int itemCount) {
    _cardAnims = List.generate(
      itemCount,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.1 + index * 0.08, // 80ms delay between cards
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProgressItem>>(
      future: _progressFuture,
      builder: (context, snapshot) {
        // Error State
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطا: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
              textDirection: TextDirection.rtl,
            ),
          );
        }

        // Loading State - Shimmer
        if (!snapshot.hasData) {
          return Column(
            children: List.generate(4, (_) => const _ShimmerProgressCard()),
          );
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'هیچ داده‌ای موجود نیست',
              style: TextStyle(fontSize: 14, color: AppColor.lightGray),
            ),
          );
        }

        // Start animation only once when data arrives
        if (_cardAnims.length != items.length) {
          _startCardAnimations(items.length);
        }

        return Column(
          children: items
              .asMap()
              .entries
              .map((entry) => AnimatedProgressCard(
            item: entry.value,
            animation: _cardAnims[entry.key],
          ))
              .toList(),
        );
      },
    );
  }
}

/// Animated version of ProgressCard with slide-up + fade-in
class AnimatedProgressCard extends StatelessWidget {
  final ProgressItem item;
  final Animation<double> animation;

  const AnimatedProgressCard({
    super.key,
    required this.item,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Transform.translate(
          offset: Offset(0, 60 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ProgressCard(item: item),
    );
  }
}

/// Beautiful shimmer placeholder during loading
class _ShimmerProgressCard extends StatelessWidget {
  const _ShimmerProgressCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 6, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 40, height: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// Final Progress Card (unchanged logic, just clean)
class ProgressCard extends StatelessWidget {
  final ProgressItem item;

  const ProgressCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Grade Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.grade,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Subject + Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: item.percentage / 100,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Percentage
          Text(
            '${item.percentage.toInt()}٪',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}