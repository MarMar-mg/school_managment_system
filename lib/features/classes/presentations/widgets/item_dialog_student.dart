import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

void showStudentClassesDialog(
    BuildContext context, {
      required List<Map<String, dynamic>> classes,
      required VoidCallback onRefresh,
    }) {
  showDialog(
    context: context,
    builder: (context) => StudentClassesDialog(
      classes: classes,
      onRefresh: onRefresh,
    ),
  );
}

class StudentClassesDialog extends StatefulWidget {
  final List<Map<String, dynamic>> classes;
  final VoidCallback onRefresh;

  const StudentClassesDialog({
    super.key,
    required this.classes,
    required this.onRefresh,
  });

  @override
  State<StudentClassesDialog> createState() => _StudentClassesDialogState();
}

class _StudentClassesDialogState extends State<StudentClassesDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.purple, AppColor.lightPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'کلاس‌های من',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.classes.length} کلاس ثبت‌نام شده',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          if (widget.classes.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: widget.classes.asMap().entries.map((entry) {
                    return _buildClassCard(entry.value);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> course) {
    final color = course['color'] as Color? ?? Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.2), width: 1),
                ),
                child: Icon(
                  course['icon'] ?? Icons.menu_book_rounded,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['name'] ?? 'نامشخص',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course['code'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.lightGray,
                        fontWeight: FontWeight.w500,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  course['grade'] ?? '-',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),

          // Details Row
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.person_outline,
                  'معلم',
                  course['teacher'] ?? 'نامشخص',
                  color,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.location_on_outlined,
                  'مکان',
                  course['location'] ?? 'نامشخص',
                  color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildDetailItem(
            Icons.schedule_outlined,
            'ساعت',
            course['Classtime'] ?? 'نامشخص',
            color,
          ),

          const SizedBox(height: 16),

          // Action Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.4), width: 2),
              borderRadius: BorderRadius.circular(14),
              color: color.withOpacity(0.05),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint('View course details: ${course['name']}');
                },
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'مشاهده جزئیات درس',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColor.lightGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 80, color: AppColor.lightGray),
            const SizedBox(height: 16),
            const Text(
              'کلاسی یافت نشد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'برای شروع با معلم خود تماس بگیرید',
              style: TextStyle(
                fontSize: 13,
                color: AppColor.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}