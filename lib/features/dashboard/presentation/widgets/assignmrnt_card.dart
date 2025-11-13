import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../models/dashboard_models.dart';
// ==================== PREMIUM ASSIGNMENT CARD ====================

class AssignmentCard extends StatefulWidget {
  final AssignmentItem item;

  const AssignmentCard({super.key, required this.item});

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
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _elevation = Tween<double>(
      begin: 2.0,
      end: 16.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
                  child: Icon(widget.item.icon, color: Colors.white, size: 28),
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
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.item.badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.item.badgeColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _formatDate(widget.item.badge),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.item.badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        // color: widget.item.badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.item.badgeColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        widget.item.endTime,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(dynamic date) {
  if (date == null) return '';
  final dateStr = date.toString().trim();
  if (dateStr.length >= 8) {
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(5, 7);
    final day = dateStr.substring(8, 10);
    return '$year/$month/$day';
  }
  return dateStr;
}
