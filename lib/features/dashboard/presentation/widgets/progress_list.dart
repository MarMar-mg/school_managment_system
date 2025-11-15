// features/dashboard/presentation/widgets/progress_list.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/dashboard_models.dart';

/// Ultimate animated progress list with growing progress bars,
/// gradient badges, press feedback, and luxury shimmer.
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _cardAnims = [];
    _loadProgress();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _progressFuture = ApiService.getProgress(
        role: widget.role,
        userId: widget.userId,
      );
    });
  }

  void _startCardAnimations(int count) {
    _cardAnims = List.generate(
      count,
          (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.15 + i * 0.07, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
    );
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProgress,
      color: AppColor.purple,
      child: FutureBuilder<List<ProgressItem>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return _buildEmpty();
          }

          if (_cardAnims.length != items.length) {
            _startCardAnimations(items.length);
          }

          return Column(
            children: items.asMap().entries.map((entry) {
              return AnimatedProgressCard(
                item: entry.value,
                animation: _cardAnims[entry.key],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(4, (_) => const _ShimmerProgressCard())
          .map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: e))
          .toList(),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: Colors.orange.shade400),
          const SizedBox(height: 16),
          const Text('خطا در بارگذاری پیشرفت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: AppColor.lightGray)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadProgress,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.auto_graph_rounded, size: 64, color: AppColor.lightGray),
          const SizedBox(height: 16),
          const Text('هیچ داده‌ای موجود نیست', style: TextStyle(color: AppColor.lightGray)),
        ],
      ),
    );
  }
}

// ==================== ANIMATED CARD WITH GROWING BAR ====================

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
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 80 * (1 - value)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        );
      },
      child: PremiumProgressCard(item: item, entranceAnimation: animation),
    );
  }
}

// ==================== PREMIUM PROGRESS CARD ====================

class PremiumProgressCard extends StatefulWidget {
  final ProgressItem item;
  final Animation<double> entranceAnimation;

  const PremiumProgressCard({
    super.key,
    required this.item,
    required this.entranceAnimation,
  });

  @override
  State<PremiumProgressCard> createState() => _PremiumProgressCardState();
}

class _PremiumProgressCardState extends State<PremiumProgressCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pressController;
  late Animation<double> _scale;
  late Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
    _elevation = Tween<double>(begin: 4.0, end: 20.0).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pressController, widget.entranceAnimation]),
      builder: (context, child) {
        final progressValue = widget.entranceAnimation.value;
        final fillWidth = progressValue * (widget.item.percentage / 100);

        return Transform.scale(
          scale: _scale.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.item.color.withOpacity(0.25),
                  blurRadius: _elevation.value,
                  offset: Offset(0, _elevation.value / 2),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: widget.item.color.withOpacity(0.25),
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _pressController.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _pressController.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _pressController.reverse();
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Gradient Badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.item.color, widget.item.color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: widget.item.color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                      const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2), spreadRadius: -2),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.item.grade,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Subject + Progress Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.subject,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.darkText),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 10),
                      // Animated Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: widget.item.percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(widget.item.color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Percentage
                Text(
                  '${widget.item.percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.item.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== LUXURY SHIMMER ====================

class _ShimmerProgressCard extends StatelessWidget {
  const _ShimmerProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        height: 92,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18, width: 120, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(height: 8, width: double.infinity, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(width: 50, height: 24, color: Colors.white),
          ],
        ),
      ),
    );
  }
}