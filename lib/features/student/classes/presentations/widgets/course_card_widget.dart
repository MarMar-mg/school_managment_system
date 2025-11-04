import 'package:flutter/material.dart';
import '../../../../../applications/colors.dart';

class CourseCardWidget extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseCardWidget({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing
        final isSmall = constraints.maxWidth < 400;
        final iconSize = isSmall ? 48.0 : 56.0;
        final titleSize = isSmall ? 16.0 : 18.0;
        final padding = isSmall ? 12.0 : 16.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Section
              _buildHeader(),

              // Divider
              _buildDivider(),

              // Details Section
              _buildDetails(),
            ],
          ),
        );
      },
    );
  }

  // ==================== Header Section ====================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Course Icon
          _buildCourseIcon(),

          const SizedBox(width: 16),

          // Course Info
          Expanded(
            child: _buildCourseInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: course['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        course['icon'],
        color: course['color'],
        size: 28,
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Course Name and Grade
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                course['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            _buildGradeBadge(),
          ],
        ),

        const SizedBox(height: 4),

        // Course Code
        Text(
          course['code'],
          style: const TextStyle(
            fontSize: 13,
            color: AppColor.lightGray,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: course['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        course['grade'],
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: course['color'],
        ),
      ),
    );
  }

  // ==================== Divider ====================

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }

  // ==================== Details Section ====================

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Teacher & Location Row
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.person_outline,
                  course['teacher']?? '',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.location_on_outlined,
                  course['location'],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Time
          _buildDetailItem(
            Icons.schedule_outlined,
            course['time'],
          ),

          const SizedBox(height: 16),

          // Action Button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColor.lightGray,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return InkWell(
      onTap: () {
        // Navigate to course details
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: course['color'].withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'مشاهده تمرین‌ها و امتحانات',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: course['color'],
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: course['color'],
            ),
          ],
        ),
      ),
    );
  }
}