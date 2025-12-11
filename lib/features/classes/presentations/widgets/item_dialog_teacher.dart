import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../../teacher/assignment_management/presentations/widgets/add_edit_dialog.dart';
import '../../../teacher/exam_management/presentations/widgets/add_edit_dialog.dart';

void showCourseItemsDialog(
  BuildContext context, {
  required Map<String, dynamic> course,
  required int userId,
  required int courseId,
  required VoidCallback onAddExam,
  required VoidCallback onAddAssignment,
  required Function(dynamic) onEditExam,
  required Function(dynamic) onEditAssignment,
  required Function(dynamic) onDeleteExam,
  required Function(dynamic) onDeleteAssignment,
  required bool isTeacher,
}) {
  showDialog(
    context: context,
    builder: (context) => CourseItemsDialog(
      course: course,
      userId: userId,
      onAddExam: onAddExam,
      onAddAssignment: onAddAssignment,
      onEditExam: onEditExam,
      onEditAssignment: onEditAssignment,
      onDeleteExam: onDeleteExam,
      onDeleteAssignment: onDeleteAssignment,
      isTeacher: isTeacher,
      courseId: courseId,
    ),
  );
}

class CourseItemsDialog extends StatefulWidget {
  final Map<String, dynamic> course;
  final int userId;
  final int courseId;
  final VoidCallback onAddExam;
  final VoidCallback onAddAssignment;
  final Function(dynamic) onEditExam;
  final Function(dynamic) onEditAssignment;
  final Function(dynamic) onDeleteExam;
  final Function(dynamic) onDeleteAssignment;
  final bool isTeacher;

  const CourseItemsDialog({
    super.key,
    required this.course,
    required this.userId,
    required this.onAddExam,
    required this.onAddAssignment,
    required this.onEditExam,
    required this.onEditAssignment,
    required this.onDeleteExam,
    required this.onDeleteAssignment,
    required this.isTeacher,
    required this.courseId,
  });

  @override
  State<CourseItemsDialog> createState() => _CourseItemsDialogState();
}

class _CourseItemsDialogState extends State<CourseItemsDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _assignmentsFuture;
  late Future<List<dynamic>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _assignmentsFuture = ApiService.getTeacherAssignments(widget.userId);
    _examsFuture = ApiService.getTeacherExams(widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Create Button
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course['name'] ?? 'نامشخص',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.course['code'] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Create Button
                if (widget.isTeacher)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // child: Row(
                    //   children: [
                    //     Expanded(
                    //       child: ElevatedButton.icon(
                    //         onPressed: () {
                    //           Navigator.pop(context);
                    //           showAddEditDialog(
                    //             context,
                    //             courses: [],
                    //             userId: widget.userId,
                    //             addData: () =>{},
                    //             isAdd: true,
                    //           );
                    //         },
                    //         icon: const Icon(Icons.add_rounded, size: 18),
                    //         label: const Text('تمرین جدید'),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: Colors.white,
                    //           foregroundColor: AppColor.purple,
                    //           padding: const EdgeInsets.symmetric(vertical: 10),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(10),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     Expanded(
                    //       child: ElevatedButton.icon(
                    //         onPressed: () {
                    //           Navigator.pop(context);
                    //           showAddEditExamDialog(
                    //             context,
                    //             exam: null,
                    //             userId: widget.userId,
                    //             onSuccess: () => {},
                    //             isAdd: true,
                    //             courses: [],
                    //             courseId: widget.courseId,
                    //             isNeeded: false,
                    //           );
                    //         },
                    //         icon: const Icon(Icons.add_rounded, size: 18),
                    //         label: const Text('امتحان جدید'),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: Colors.white24,
                    //           foregroundColor: Colors.white,
                    //           padding: const EdgeInsets.symmetric(vertical: 10),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(10),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColor.purple,
              unselectedLabelColor: AppColor.lightGray,
              indicatorColor: AppColor.purple,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text('تمرین‌ها'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text('امتحانات'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Assignments Tab
                _buildAssignmentsTab(),
                // Exams Tab
                _buildExamsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _assignmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState('خطا در بارگذاری تمرین‌ها');
        }

        final assignments = snapshot.data ?? [];
        final courseAssignments = assignments
            .where(
              (a) => a['courseId'].toString() == widget.course['id'].toString(),
            )
            .toList();

        if (courseAssignments.isEmpty) {
          return _buildEmptyState('تمرینی یافت نشد', Icons.assignment_outlined);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: courseAssignments.map((assignment) {
              return _buildAssignmentCard(assignment);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAssignmentCard(dynamic assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'] ?? 'بدون عنوان',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((assignment['description'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        assignment['description'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.lightGray,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailBadge(
                icon: Icons.calendar_today_outlined,
                label: assignment['dueDate'] ?? 'نامشخص',
              ),
              _buildDetailBadge(
                icon: Icons.access_time_outlined,
                label: assignment['dueTime'] ?? '',
              ),
              _buildDetailBadge(
                icon: Icons.grade_outlined,
                label: 'از ${assignment['score'] ?? '0'}',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Submissions
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ارسال‌شده: ${assignment['submissions'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const Icon(
                  Icons.people_outline,
                  size: 16,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onDeleteAssignment(assignment),
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
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onEditAssignment(assignment),
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
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('View submissions for ${assignment['title']}');
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('مشاهده'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    foregroundColor: Colors.orange,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _examsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState('خطا در بارگذاری امتحانات');
        }

        final exams = snapshot.data ?? [];
        final courseExams = exams.where((e) {
          final courseId = (e is Map ? e['courseId'] : e.courseId);
          return courseId.toString() == widget.course['id'].toString();
        }).toList();

        if (courseExams.isEmpty) {
          return _buildEmptyState(
            'امتحانی یافت نشد',
            Icons.description_outlined,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: courseExams.map((exam) {
              return _buildExamCard(exam);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildExamCard(dynamic exam) {
    final isPassed = exam is Map
        ? exam['status'] == 'completed'
        : exam.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam is Map ? exam['title'] ?? 'بدون عنوان' : exam.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((exam is Map
                            ? exam['description'] ?? ''
                            : exam.description)
                        .isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        exam is Map ? exam['description'] : exam.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.lightGray,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isPassed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'برگزار شده',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailBadge(
                icon: Icons.calendar_today_outlined,
                label: exam is Map ? exam['date'] ?? 'نامشخص' : exam.date,
              ),
              _buildDetailBadge(
                icon: Icons.access_time_outlined,
                label: exam is Map ? exam['classTime'] ?? '' : exam.classTime,
              ),
              _buildDetailBadge(
                icon: Icons.grade_outlined,
                label:
                    'از ${exam is Map ? exam['possibleScore'] ?? '100' : exam.possibleScore}',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Submissions
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ارسال‌شده: ${exam is Map ? exam['filledCapacity'] ?? '-' : '${exam.students}/${exam.capacity}'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const Icon(Icons.people_outline, size: 16, color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              if (!isPassed)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onDeleteExam(exam),
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
                        size: 18,
                      ),
                    ),
                  ),
                ),
              if (!isPassed) const SizedBox(width: 8),
              if (!isPassed)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onEditExam(exam),
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
              if (!isPassed) const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    debugPrint(
                      'View scores for ${exam is Map ? exam['title'] : exam.title}',
                    );
                  },
                  icon: Icon(
                    isPassed ? Icons.visibility_outlined : Icons.score,
                    size: 16,
                  ),
                  label: Text(isPassed ? 'مشاهده' : 'مدیریت نمرات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBadge({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColor.purple),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColor.lightGray),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColor.purple),
    );
  }
}
