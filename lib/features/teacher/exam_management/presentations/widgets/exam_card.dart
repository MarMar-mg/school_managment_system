import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/features/teacher/exam_management/presentations/widgets/score_management_widget.dart';
import '../../data/models/exam_model.dart';

class TeacherExamCard extends StatefulWidget {
  final ExamModelT exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isActive;

  const TeacherExamCard({
    super.key,
    required this.exam,
    required this.onEdit,
    required this.onDelete,
    required this.isActive,
  });

  @override
  State<TeacherExamCard> createState() => _TeacherExamCardState();
}

class _TeacherExamCardState extends State<TeacherExamCard>
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
    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 16.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
    final isUpcoming = widget.exam.status == 'upcoming';
    final headerColor = isUpcoming ? Colors.orange : Colors.green;

    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _isPressed ? -4 : 0),
          child: Container(
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
          splashColor: headerColor.withOpacity(0.2),
          highlightColor: headerColor.withOpacity(0.1),
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: () => debugPrint('Exam tapped: ${widget.exam.title}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Icon Badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            headerColor,
                            headerColor.withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isUpcoming
                            ? Icons.calendar_today
                            : Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title & Subject
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.exam.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.exam.subject,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColor.lightGray,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 14),

                // Info Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'تاریخ',
                        widget.exam.date ?? 'نامشخص',
                        Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        'ساعت',
                        widget.exam.classTime,
                        Icons.access_time_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        'امتیاز',
                        '${widget.exam.possibleScore}',
                        Icons.grade_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'ظرفیت',
                        '${widget.exam.capacity}',
                        Colors.blue.withOpacity(0.1),
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        'ثبت‌نام شده',
                        '${widget.exam.students}',
                        Colors.purple.withOpacity(0.1),
                        AppColor.purple,
                      ),
                    ),
                    if (!isUpcoming) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'درصد قبولی',
                          '${widget.exam.passPercentage?.toStringAsFixed(0) ?? "-"}%',
                          Colors.green.withOpacity(0.1),
                          Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Delete Button (only for active/upcoming)
                    if (widget.isActive) ...[
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: widget.onDelete,
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      // Edit Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('ویرایش'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade50,
                            foregroundColor: AppColor.darkText,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    // View/Score Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isUpcoming
                            ? () => debugPrint('View details: ${widget.exam.title}')
                            : () {
                          showExamScoreManagementDialog(
                            context,
                            examId: widget.exam.id,
                            examTitle: widget.exam.title,
                            possibleScore: widget.exam.possibleScore,
                          );
                        },
                        icon: Icon(
                          isUpcoming
                              ? Icons.visibility_outlined
                              : Icons.score,
                          size: 16,
                        ),
                        label: Text(
                          isUpcoming ? 'مشاهده' : 'مدیریت نمرات',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUpcoming
                              ? Colors.grey.shade50
                              : Colors.blue.shade50,
                          foregroundColor: isUpcoming
                              ? AppColor.darkText
                              : Colors.blue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isUpcoming
                                  ? Colors.grey.shade300
                                  : Colors.blue.shade300,
                            ),
                          ),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColor.purple.withOpacity(0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColor.lightGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      Color bgColor,
      Color textColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColor.lightGray,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}