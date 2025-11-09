import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
import '../models/dashboard_models.dart';

/// Responsive animated stats grid with:
/// - Shimmer loading placeholder
/// - Staggered card entrance
/// - Elements sliding in from sides (icon ← left, value → right, text ↑ up)
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

  // Controls the master animation timeline for all cards
  late AnimationController _controller;

  // One animation per card (for staggered delay)
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

  /// Create staggered animations for each card (90ms delay between cards)
  void _startAnimations(int count) {
    _cardAnims = List.generate(
      count,
          (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.1 + i * 0.09, // Stagger: card 0 → 100ms, card 1 → 190ms, etc.
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    _controller.forward(from: 0.0); // Start animation
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2; // 4 columns on tablet+
    final childAspectRatio = screenWidth > 600 ? 1.6 : 1.3;

    return FutureBuilder<List<StatCard>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطا: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
          );
        }

        // Loading → Show shimmer grid
        if (!snapshot.hasData) {
          return _buildShimmerGrid(crossAxisCount, childAspectRatio);
        }

        final stats = snapshot.data!;

        // Empty state
        if (stats.isEmpty) {
          return const Center(
            child: Text(
              'آماری موجود نیست',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
          );
        }

        // Start animation only once when data arrives
        if (_cardAnims.length != stats.length) {
          _startAnimations(stats.length);
        }

        // Real data → Animated Grid
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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

  /// Shimmer placeholder grid (matches real grid layout)
  Widget _buildShimmerGrid(int crossAxisCount, double childAspectRatio) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: crossAxisCount == 2 ? 4 : 8, // Show 4 or 8 placeholders
      itemBuilder: (_, __) => const _ShimmerStatCard(),
    );
  }
}

/// Animated card with elements entering from different directions
class AnimatedStatCard extends StatelessWidget {
  final StatCard stat;
  final Animation<double> animation; // 0.0 → 1.0 progress

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

        // Icon slides in from left
        final iconSlide = Tween<double>(begin: -80, end: 0).animate(
          CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
        );

        // Value slides in from right
        final valueSlide = Tween<double>(begin: 80, end: 0).animate(
          CurvedAnimation(parent: animation, curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic)),
        );

        // Text rises from bottom
        final textRise = Tween<double>(begin: 40, end: 0).animate(
          CurvedAnimation(parent: animation, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
        );

        // Whole card fades in + slides up slightly
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 80 * (1 - value)),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: StatCardWidget(
                stat: stat,
                iconOffsetX: iconSlide.value,
                valueOffsetX: valueSlide.value,
                textOffsetY: textRise.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Single stat card with animated internal elements
class StatCardWidget extends StatelessWidget {
  final StatCard stat;
  final double iconOffsetX;
  final double valueOffsetX;
  final double textOffsetY;

  const StatCardWidget({
    super.key,
    required this.stat,
    this.iconOffsetX = 0,
    this.valueOffsetX = 0,
    this.textOffsetY = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140, maxHeight: 160),
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
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row: icon (left) ← value (right)
          Row(
            children: [
              // Icon slides in from left
              Transform.translate(
                offset: Offset(iconOffsetX, 0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(stat.icon, color: Colors.white, size: 22),
                ),
              ),
              const Spacer(),
              // Value slides in from right
              Transform.translate(
                offset: Offset(valueOffsetX, 0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ],
          ),

          // Bottom text block rises up
          Transform.translate(
            offset: Offset(0, textOffsetY),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  stat.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for a single card
class _ShimmerStatCard extends StatelessWidget {
  const _ShimmerStatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      period: const Duration(milliseconds: 1500),
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
                Container(width: 40, height: 40, color: Colors.white),
                const Spacer(),
                Container(width: 60, height: 36, color: Colors.white),
              ],
            ),
            const Spacer(),
            Container(height: 18, width: 120, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 14, width: 90, color: Colors.white),
          ],
        ),
      ),
    );
  }
}