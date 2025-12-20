import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/features/teacher/assignment_management/presentations/widgets/add_edit_dialog.dart';
import 'package:school_management_system/features/teacher/exam_management/presentations/widgets/add_edit_dialog.dart';

import '../../../../applications/role.dart';
import '../../../../commons/utils/manager/date_manager.dart';
import '../../../teacher/assignment_management/presentations/widgets/assignment_card.dart';
import '../../../teacher/exam_management/data/models/exam_model.dart';
import '../../../teacher/exam_management/presentations/widgets/exam_card.dart';

void showTeacherCourseDialog(
  BuildContext context, {
  required Map<String, dynamic> course,
  required int userId,
  required int courseId,
  required VoidCallback onRefresh,
}) {
  showDialog(
    context: context,
    builder: (context) => TeacherCourseDialog(
      course: course,
      userId: userId,
      courseId: courseId,
      onRefresh: onRefresh,
    ),
  );
}

class TeacherCourseDialog extends StatefulWidget {
  final Map<String, dynamic> course;
  final int userId;
  final int courseId;
  final VoidCallback onRefresh;

  const TeacherCourseDialog({
    super.key,
    required this.course,
    required this.userId,
    required this.courseId,
    required this.onRefresh,
  });

  @override
  State<TeacherCourseDialog> createState() => _TeacherCourseDialogState();
}

class _TeacherCourseDialogState extends State<TeacherCourseDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _assignmentsFuture;
  late Future<List<ExamModelT>> _examsFuture;
  late Future<List<Map<String, dynamic>>> _coursesFuture;

  final Map<String, bool> _expandedSections = {
    'active_assignments': false,
    'inactive_assignments': false,
    'upcoming_exams': false,
    'completed_exams': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _assignmentsFuture = ApiService.getTeacherAssignments(widget.userId);
    _examsFuture = ApiService.getTeacherExams(widget.userId);
    _coursesFuture = ApiService.getCourses(Role.teacher, widget.userId).then((
      _,
    ) async {
      return await ApiService.getCourses(Role.teacher, widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !_expandedSections[key]!;
    });
  }

  void _showDeleteDialog(String type, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف ${type == 'assignment' ? 'تمرین' : 'امتحان'}'),
        content: Text('آیا مطمئن هستید؟', textDirection: TextDirection.rtl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (type == 'assignment') {
                _deleteAssignment(id);
              } else {
                _deleteExam(id);
              }
            },
            child: Text('حذف', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAssignment(int assignmentId) async {
    try {
      await ApiService.deleteTeacherAssignment(assignmentId, widget.userId);
      _loadData();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمرین با موفقیت حذف شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteExam(int examId) async {
    try {
      await ApiService.deleteTeacherExam(examId, widget.userId);
      _loadData();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('امتحان با موفقیت حذف شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 20,
        height: MediaQuery.of(context).size.height * 0.8,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course['name'] ?? 'نام درس',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.course['code'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
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
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColor.purple,
              unselectedLabelColor: AppColor.lightGray,
              indicatorColor: AppColor.purple,
              tabs: const [
                Tab(text: 'تمرین‌ها'),
                Tab(text: 'امتحانات'),
              ],
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAssignmentsTab(), _buildExamsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _assignmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final assignments = snapshot.data ?? [];
        final courseAssignments = assignments
            .where(
              (a) => a['courseId'].toString() == widget.course['id'].toString(),
            )
            .toList();

        if (courseAssignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: AppColor.lightGray,
                ),
                const SizedBox(height: 16),
                const Text('تمرینی وجود ندارد'),
              ],
            ),
          );
        }

        // Separate into active and inactive
        final now = DateTime.now();
        final activeAssignments = <dynamic>[];
        final inactiveAssignments = <dynamic>[];

        for (var assignment in courseAssignments) {
          try {
            final dueDate = DateFormatManager.convertToDateTime(
              assignment['dueDate'],
            );
            if (dueDate.isAfter(now)) {
              activeAssignments.add(assignment);
            } else {
              inactiveAssignments.add(assignment);
            }
          } catch (e) {
            inactiveAssignments.add(assignment);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAssignmentSection(
                'فعال',
                activeAssignments,
                Colors.orange,
                'active_assignments',
                true,
              ),
              const SizedBox(height: 16),
              _buildAssignmentSection(
                'غیر فعال',
                inactiveAssignments,
                Colors.grey,
                'inactive_assignments',
                false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignmentSection(
    String title,
    List<dynamic> items,
    Color color,
    String key,
    bool isActive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleSection(key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  _expandedSections[key]!
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: color,
                ),
                const SizedBox(width: 12),
                Text(
                  '$title (${items.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expandedSections[key]!) ...[
          const SizedBox(height: 12),
          ...items.map((assignment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TeacherAssignmentCard(
                data: assignment,
                onEdit: () {
                  Navigator.pop(context);
                  showAddEditDialog(
                    context,
                    assignment: assignment,
                    isAdd: false,
                    courses: [],
                    userId: widget.userId,
                    addData: () {
                      _loadData();
                      widget.onRefresh();
                    },
                  );
                },
                onDelete: () =>
                    _showDeleteDialog('assignment', assignment['id']),
                isActive: isActive,
                userId: widget.userId,
              ),
            );
          }),
        ],
        if (_expandedSections[key]! && items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تمرینی یافت نشد',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExamsTab() {
    return FutureBuilder<List<ExamModelT>>(
      future: _examsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final exams = snapshot.data ?? [];
        final courseExams = exams
            .where(
              (e) => e.courseId.toString() == widget.course['id'].toString(),
            )
            .toList();

        if (courseExams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: AppColor.lightGray,
                ),
                const SizedBox(height: 16),
                const Text('امتحانی وجود ندارد'),
              ],
            ),
          );
        }

        // Separate into upcoming and completed
        final upcomingExams = courseExams
            .where((e) => e.status == 'upcoming')
            .toList();
        final completedExams = courseExams
            .where((e) => e.status == 'completed')
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildExamSection(
                'پیش رو',
                upcomingExams,
                Colors.orange,
                'upcoming_exams',
                true,
              ),
              const SizedBox(height: 16),
              _buildExamSection(
                'برگزار شده',
                completedExams,
                Colors.green,
                'completed_exams',
                false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamSection(
    String title,
    List<ExamModelT> items,
    Color color,
    String key,
    bool isActive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleSection(key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  _expandedSections[key]!
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: color,
                ),
                const SizedBox(width: 12),
                Text(
                  '$title (${items.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expandedSections[key]!) ...[
          const SizedBox(height: 12),
          ...items.map((exam) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: TeacherExamCard(
                exam: exam,
                onEdit: () {
                  Navigator.pop(context);
                  final examMap = {
                    'id': exam.id,
                    'title': exam.title,
                    'description': exam.description,
                    'date': exam.date,
                    'classTime': exam.classTime,
                    'duration': exam.duration,
                    'possibleScore': exam.possibleScore,
                    'courseId': exam.courseId,
                    'filename': exam.filename,
                  };
                  showAddEditExamDialog(
                    context,
                    exam: examMap,
                    userId: widget.userId,
                    onSuccess: () {
                      _loadData();
                      widget.onRefresh();
                    },
                    isAdd: false,
                    courses: [],
                    isNeeded: false,
                    courseId: widget.courseId,
                  );
                },
                onDelete: () => _showDeleteDialog('exam', exam.id),
                isActive: isActive,
              ),
            );
          }),
        ],
        if (_expandedSections[key]! && items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'امتحانی یافت نشد',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
