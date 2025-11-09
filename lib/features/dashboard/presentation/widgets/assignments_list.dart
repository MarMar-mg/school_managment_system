// features/dashboard/presentation/widgets/assignments_list.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../applications/colors.dart';
import '../../../../core/services/api_service.dart';
import '../models/dashboard_models.dart';

/// Premium animated upcoming assignments list with shimmer,
/// pull-to-refresh, and stunning card entrance animations.
class AssignmentsList extends StatefulWidget {
  final int studentId;

  const AssignmentsList({
    super.key,
    required this.studentId,
  });

  @override
  State<AssignmentsList> createState() => _AssignmentsListState();
}

class _AssignmentsListState extends State<AssignmentsList>
    with TickerProviderStateMixin {
  late Future<List<AssignmentItem>> _assignmentsFuture;
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
    _loadAssignments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _assignmentsFuture = ApiService.getUpcomingAssignments(widget.studentId);
    });
  }

  void _startAnimations(int count) {
    _cardAnims = List.generate(
      count,
          (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 + i * 0.09, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
    );
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadAssignments,
      color: AppColor.purple,
      child: FutureBuilder<List<AssignmentItem>>(
        future: _assignmentsFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmer();
          }

          // Error
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final assignments = snapshot.data ?? [];
          if (assignments.isEmpty) {
            return _buildEmpty();
          }

          // Start animation once
          if (_cardAnims.length != assignments.length) {
            _startAnimations(assignments.length);
          }

          return Column(
            children: assignments.asMap().entries.map((entry) {
              return AnimatedAssignmentCard(
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
      children: List.generate(
        3,
            (_) => const _ShimmerAssignmentCard(),
      ).map((card) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: card,
      )).toList(),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_late_outlined, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'خطا در بارگذاری تکالیف',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: AppColor.lightGray)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadAssignments,
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
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
          const SizedBox(height: 16),
          const Text(
            'تمرین یا امتحانی در دو روز آینده نیست',
            style: TextStyle(fontSize: 15, color: AppColor.lightGray),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

// ==================== ANIMATED CARD ====================

class AnimatedAssignmentCard extends StatelessWidget {
  final AssignmentItem item;
  final Animation<double> animation;

  const AnimatedAssignmentCard({
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
      child: AssignmentCard(item: item),
    );
  }
}

// ==================== PREMIUM ASSIGNMENT CARD ====================

class AssignmentCard extends StatefulWidget {
  final AssignmentItem item;

  const AssignmentCard({Key? key, required this.item}) : super(key: key);

  @override
  State<AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _elevation = Tween<double>(begin: 2.0, end: 16.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.item.badgeColor.withOpacity(0.15),
                  blurRadius: _elevation.value,
                  offset: Offset(0, _elevation.value / 2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
          splashColor: widget.item.badgeColor.withOpacity(0.2),
          highlightColor: widget.item.badgeColor.withOpacity(0.1),
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTap: () => debugPrint('Assignment: ${widget.item.title}'),
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
                      colors: [
                        widget.item.badgeColor,
                        widget.item.badgeColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.item.badgeColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.item.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkText,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.subject,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColor.lightGray,
                          // fontWeight:241,
                          // FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.item.badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.item.badgeColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    widget.item.badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.item.badgeColor,
                      letterSpacing: 0.5,
                    ),
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

// ==================== SHIMMER CARD ====================

class _ShimmerAssignmentCard extends StatelessWidget {
  const _ShimmerAssignmentCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
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
            Container(width: 56, height: 56, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 14, width: 120, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 80, height: 36, color: Colors.white),
          ],
        ),
      ),
    );
  }
}