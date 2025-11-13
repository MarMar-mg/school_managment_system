import 'package:flutter/material.dart';
import '../../../../../applications/colors.dart';

/// Premium animated course card with hover/press effects, ripple feedback,
/// and smooth entrance animation when used in a list.
class CourseCardWidget extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseCardWidget({
    super.key,
    required this.course,
  });

  @override
  State<CourseCardWidget> createState() => _CourseCardWidgetState();
}

class _CourseCardWidgetState extends State<CourseCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 16.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.course['color'] as Color;

    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _isPressed ? -4 : 0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
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
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: () {
            // Navigate to course details
            debugPrint('Course tapped: ${widget.course['name']}');
          },
          child: _buildCardContent(color),
        ),
      ),
    );
  }

  Widget _buildCardContent(Color color) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildCourseIcon(color),
              const SizedBox(width: 16),
              Expanded(child: _buildCourseInfo(color)),
            ],
          ),
        ),

        _buildDivider(),

        // Details
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.person_outline,
                      widget.course['teacher'] ?? 'نامشخص',
                      color,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.location_on_outlined,
                      widget.course['location'],
                      color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailItem(Icons.schedule_outlined, widget.course['Classtime'], color),
              const SizedBox(height: 16),
              _buildActionButton(color),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseIcon(Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Icon(
        widget.course['icon'],
        color: color,
        size: 28,
      ),
    );
  }

  Widget _buildCourseInfo(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.course['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildGradeBadge(color),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          widget.course['code'],
          style: TextStyle(
            fontSize: 13,
            color: AppColor.lightGray,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildGradeBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        widget.course['grade'],
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.darkText.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'مشاهده تمرین‌ها و امتحانات',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_back_ios_rounded,
            size: 15,
            color: color,
          ),
        ],
      ),
    );
  }
}

// For use in animated lists (e.g., CoursesPage)
class AnimatedCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Animation<double> animation;

  const AnimatedCourseCard({
    super.key,
    required this.course,
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
      child: CourseCardWidget(course: course),
    );
  }
}