import 'package:flutter/material.dart';
import '../../../../../applications/colors.dart';
import '../../../../../commons/utils/manager/date_manager.dart';
import '../../../../../core/services/api_service.dart';
import 'assignment_score_management_widget.dart';

class TeacherAssignmentCard extends StatefulWidget {
  final dynamic data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isActive;
  final int userId;

  const TeacherAssignmentCard({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.isActive, required this.userId,
  });

  @override
  State<TeacherAssignmentCard> createState() => _TeacherAssignmentCardState();
}

class _TeacherAssignmentCardState extends State<TeacherAssignmentCard>
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

  Color _getColorFromSubject(String? subject) {
    if (subject == null) return Colors.blue;
    if (subject.contains('ریاضی')) return Colors.purple;
    if (subject.contains('شیمی')) return Colors.blue;
    if (subject.contains('فیزیک')) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorFromSubject(widget.data['subject']);
    final score = widget.data['score']?.toString() ?? 'نامشخص';
    final dueDate = widget.data['dueDate'] ?? 'نامشخص';
    final dueTime = widget.data['dueTime'] ?? 'نامشخص';

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
            splashColor: color.withOpacity(0.2),
            highlightColor: color.withOpacity(0.1),
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
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
                            colors: [color, color.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
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
                              widget.data['title'] ?? 'بدون عنوان',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.darkText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.data['subject'] ?? 'نامشخص',
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

                  // Details Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'تاریخ تحویل',
                          DateFormatManager.formatDate(dueDate),
                          Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          'ساعت تحویل',
                          dueTime,
                          Icons.access_time_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          'امتیاز',
                          score,
                          Icons.grade_outlined,
                        ),
                      ),
                    ],
                  ),

                  if ((widget.data['description']?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'توضیحات',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColor.lightGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.data['description'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColor.darkText,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      // Delete Button
                     if(widget.isActive) Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onDelete,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Edit Button
                      if(widget.isActive)Expanded(
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
                      const SizedBox(width: 8),
                      // View Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showAssignmentScoreManagementDialog(
                              context,
                              assignmentId: widget.data['id'],
                              assignmentTitle: widget.data['title'],
                              possibleScore:
                              int.tryParse(
                                widget.data['score']?.toString() ?? '100',
                              ) ??
                                  100,
                              userId: widget.userId,
                            );
                          },
                          icon: const Icon(Icons.score, size: 16),
                          label: const Text('مدیریت نمرات'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                            foregroundColor: Colors.blue,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.blue.shade300),
                            ),
                          ),
                        ),
                      ),
                      if(!widget.isActive)
                      const SizedBox(width: 8),
                      if(!widget.isActive)
                      downloadFile()
                    ],
                  ),
                  if (widget.isActive) const SizedBox(height: 4),
                  if (widget.isActive) Row(children: [downloadFile()]),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColor.purple.withOpacity(0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColor.lightGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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
    );
  }
  Expanded downloadFile() {
    return  Expanded(
      child: ElevatedButton.icon(
        onPressed: () async {
          await _downloadQuestionFile(context, 'exam');
        },
        icon: const Icon(Icons.download_rounded, size: 18),
        label: const Text("دانلود سوال"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen.shade50,
          foregroundColor: Colors.lightGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadQuestionFile(BuildContext context, String type) async {
    try {
      // Verify file exists before downloading
      if (widget.data['file'] == null || widget.data['file']!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فایل سوال برای این تمرین موجود نیست'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('در حال دانلود...'),
              ],
            ),
          ),
        );
      }

      // Download file
      print(
        'Attempting to download exercise question file for exercise: ${widget.data['id']}',
      );
      final fileBytes = await ApiService.downloadAssignmentQuestionFile(widget.data['id']);

      print('Downloaded ${fileBytes.length} bytes');

      // Save file
      final fileName =widget.data['filename'] ?? 'exercise_${widget.data['id']}.pdf';
      final filePath = await ApiService.saveFileToDevice(fileBytes, fileName);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فایل سوال با موفقیت دانلود شد'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Download error: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در دانلود: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}