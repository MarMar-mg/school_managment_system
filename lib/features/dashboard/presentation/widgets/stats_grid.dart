// features/dashboard/presentation/widgets/stats_grid.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
import '../models/dashboard_models.dart';

/// Responsive animated stats grid with shimmer loading and staggered entrance
class StatsGrid extends StatefulWidget {
  final Role role;
  final int userId;

  const StatsGrid({
    super.key,
    required this.role,
    required this.userId,
  });

  @override
  State<StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends State<StatsGrid> with TickerProviderStateMixin {
  late Future<List<StatCard>> _statsFuture;
  late AnimationController _controller;
  late List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getStats(widget.role, widget.userId);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _cardAnims = [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimations(int count) {
    _cardAnims = List.generate(
      count,
          (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.1 + i * 0.09, // 90ms stagger
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
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    final childAspectRatio = screenWidth > 600 ? 1.6 : 1.3;

    return FutureBuilder<List<StatCard>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطا: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textDirection: TextDirection.rtl,
            ),
          );
        }

        // Loading → Shimmer Grid
        if (!snapshot.hasData) {
          return _buildShimmerGrid(crossAxisCount, childAspectRatio);
        }

        final stats = snapshot.data!;
        if (stats.isEmpty) {
          return const Center(
            child: Text(
              'آماری موجود نیست',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textDirection: TextDirection.rtl,
            ),
          );
        }

        // Start animation only once
        if (_cardAnims.length != stats.length) {
          _startAnimations(stats.length);
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return AnimatedStatCard(
              stat: stats[index],
              animation: _cardAnims[index],
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerGrid(int crossAxisCount, double childAspectRatio) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: crossAxisCount == 2 ? 4 : 8,
      itemBuilder: (_, __) => const _ShimmerStatCard(),
    );
  }
}

/// Animated wrapper for StatCardWidget
class AnimatedStatCard extends StatelessWidget {
  final StatCard stat;
  final Animation<double> animation;

  const AnimatedStatCard({
    super.key,
    required this.stat,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Transform.translate(
          offset: Offset(0, 100 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: StatCardWidget(stat: stat),
    );
  }
}

/// Shimmer placeholder card
class _ShimmerStatCard extends StatelessWidget {
  const _ShimmerStatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 36, height: 36, color: Colors.white),
                const Spacer(),
                Container(width: 50, height: 32, color: Colors.white),
              ],
            ),
            const Spacer(),
            Container(height: 16, width: 100, color: Colors.white),
            const SizedBox(height: 6),
            Container(height: 12, width: 80, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// Original StatCardWidget — unchanged, just clean
class StatCardWidget extends StatelessWidget {
  final StatCard stat;

  const StatCardWidget({Key? key, required this.stat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [stat.color, stat.color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                stat.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                ),
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}