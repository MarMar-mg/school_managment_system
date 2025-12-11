// Teacher Course Dialog - Full Functionality
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';

void showCourseItemsDialog(
    BuildContext context, {
      required Map<String, dynamic> course,
      required int userId,
      required int courseId,
      required VoidCallback onRefresh,
      required bool isTeacher,
    }) {
  showDialog(
    context: context,
    builder: (context) => CourseItemsDialog(
      course: course,
      userId: userId,
      courseId: courseId,
      onRefresh: onRefresh,
      isTeacher: isTeacher,
    ),
  );
}

class CourseItemsDialog extends StatefulWidget {
  final Map<String, dynamic> course;
  final int userId;
  final int courseId;
  final VoidCallback onRefresh;
  final bool isTeacher;

  const CourseItemsDialog({
    super.key,
    required this.course,
    required this.userId,
    required this.courseId,
    required this.onRefresh,
    required this.isTeacher,
  });

  @override
  State<CourseItemsDialog> createState() => _CourseItemsDialogState();
}

class _CourseItemsDialogState extends State<CourseItemsDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _assignmentsFuture;
  late Future<List<dynamic>> _examsFuture;

  final Map<String, bool> _expandedSections = {
    'pending': false,
    'submitted': false,
    'graded': false,
    'upcoming': false,
    'completed': false,
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
          SnackBar(
            content: Text('خطا: $e'),
            backgroundColor: Colors.red,
          ),
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
          SnackBar(
            content: Text('خطا: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(String type, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف ${type == 'assignment' ? 'تمرین' : 'امتحان'}'),
        content: Text(
          'آیا مطمئن هستید؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('لغو')),
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
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
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColor.purple,
              unselectedLabelColor: AppColor.lightGray,
              indicatorColor: AppColor.purple,
              tabs: const [
                Tab(text: 'تمرین‌ها'),
                Tab(text: 'امتحانات'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssignmentsTab(),
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
          return const Center(child: CircularProgressIndicator());
        }

        final assignments = snapshot.data ?? [];
        final courseAssignments = assignments
            .where((a) => a['courseId'].toString() == widget.course['id'].toString())
            .toList();

        if (courseAssignments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: AppColor.lightGray),
                const SizedBox(height: 16),
                const Text('تمرینی وجود ندارد'),
              ],
            ),
          );
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_rounded, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'] ?? 'بدون عنوان',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاریخ: ${assignment['dueDate'] ?? 'نامشخص'}',
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                'ارسال: ${assignment['submissions'] ?? '-'}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDeleteConfirmation('assignment', assignment['id']),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('Edit assignment: ${assignment['title']}');
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('ویرایش'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade50,
                    foregroundColor: AppColor.darkText,
                    elevation: 0,
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
                    debugPrint('View submissions: ${assignment['title']}');
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('مشاهده'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    foregroundColor: Colors.orange,
                    elevation: 0,
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
          return const Center(child: CircularProgressIndicator());
        }

        final exams = snapshot.data ?? [];
        final courseExams = exams.where((e) {
          final courseId = e is Map ? e['courseId'] : e.courseId;
          return courseId.toString() == widget.course['id'].toString();
        }).toList();

        if (courseExams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 64, color: AppColor.lightGray),
                const SizedBox(height: 16),
                const Text('امتحانی وجود ندارد'),
              ],
            ),
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
    final isPassed = exam is Map ? exam['status'] == 'completed' : exam.status == 'completed';
    final examId = exam is Map ? exam['id'] : exam.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_rounded, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam is Map ? exam['title'] ?? 'بدون عنوان' : exam.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              if (isPassed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'برگزار شده',
                    style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاریخ: ${exam is Map ? exam['date'] ?? 'نامشخص' : exam.date}',
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                'ثبت‌نام: ${exam is Map ? exam['filledCapacity'] ?? '-' : '${exam.students}/${exam.capacity}'}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isPassed)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showDeleteConfirmation('exam', examId),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 18),
                    ),
                  ),
                ),
              if (!isPassed) const SizedBox(width: 8),
              if (!isPassed)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('Edit exam: ${exam is Map ? exam['title'] : exam.title}');
                    },
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('ویرایش'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade50,
                      foregroundColor: AppColor.darkText,
                      elevation: 0,
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
                    debugPrint('View scores: ${exam is Map ? exam['title'] : exam.title}');
                  },
                  icon: Icon(isPassed ? Icons.visibility_outlined : Icons.score, size: 16),
                  label: Text(isPassed ? 'مشاهده' : 'مدیریت نمرات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    foregroundColor: Colors.blue,
                    elevation: 0,
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
}