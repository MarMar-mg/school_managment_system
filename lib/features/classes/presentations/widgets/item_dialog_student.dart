import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/features/student/assignments/data/models/assignment_model.dart.dart';
import 'package:school_management_system/features/student/exam/entities/models/exam_model.dart';
import 'package:school_management_system/commons/utils/manager/date_manager.dart';

void showStudentCourseDialog(
    BuildContext context, {
      required Map<String, dynamic> course,
      required int userId,
      required VoidCallback onRefresh,
    }) {
  showDialog(
    context: context,
    builder: (context) => StudentCourseDialog(
      course: course,
      userId: userId,
      onRefresh: onRefresh,
    ),
  );
}

class StudentCourseDialog extends StatefulWidget {
  final Map<String, dynamic> course;
  final int userId;
  final VoidCallback onRefresh;

  const StudentCourseDialog({
    super.key,
    required this.course,
    required this.userId,
    required this.onRefresh,
  });

  @override
  State<StudentCourseDialog> createState() => _StudentCourseDialogState();
}

class _StudentCourseDialogState extends State<StudentCourseDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, List<dynamic>>> _assignmentsFuture;
  late Future<Map<String, List<ExamItem>>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _assignmentsFuture = ApiService.getAllAssignments(widget.userId);
    _examsFuture = ApiService.getAllExams(widget.userId);
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'معلم: ${widget.course['teacher'] ?? 'نامشخص'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'کد درس: ${widget.course['code'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 11,
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
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('تمرین‌ها'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('امتحانات'),
                    ],
                  ),
                ),
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

  // ==================== ASSIGNMENTS TAB ====================
  Widget _buildAssignmentsTab() {
    return FutureBuilder<Map<String, List<dynamic>>>(
      future: _assignmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.purple),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                const Text('خطا در بارگذاری تمرین‌ها'),
              ],
            ),
          );
        }

        final allAssignments = snapshot.data ?? {};
        final pending = (allAssignments['pending'] ?? []).cast<AssignmentItemm>();
        final submitted = (allAssignments['submitted'] ?? []).cast<AssignmentItemm>();
        final graded = (allAssignments['graded'] ?? []).cast<AssignmentItemm>();

        if (pending.isEmpty && submitted.isEmpty && graded.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: AppColor.lightGray,
                ),
                const SizedBox(height: 16),
                const Text(
                  'تمرینی وجود ندارد',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.lightGray,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (pending.isNotEmpty) ...[
                _buildSectionHeader('در انتظار', Colors.orange, pending.length),
                ...pending.map((a) => _buildAssignmentCard(a, Colors.orange)),
                const SizedBox(height: 20),
              ],
              if (submitted.isNotEmpty) ...[
                _buildSectionHeader('ارسال شده', Colors.blue, submitted.length),
                ...submitted.map((a) => _buildAssignmentCard(a, Colors.blue)),
                const SizedBox(height: 20),
              ],
              if (graded.isNotEmpty) ...[
                _buildSectionHeader('نمره‌دار', Colors.green, graded.length),
                ...graded.map((a) => _buildAssignmentCard(a, Colors.green)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignmentCard(AssignmentItemm assignment, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      assignment.subject,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.lightGray,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  assignment.badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          // Details Row
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.calendar_today_outlined,
                  'تاریخ',
                  DateFormatManager.formatDate(assignment.dueDate) ?? 'نامشخص',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.access_time_outlined,
                  'ساعت',
                  assignment.endTime ?? 'نامشخص',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.grade_outlined,
                  'امتیاز',
                  'از ${assignment.totalScore ?? '0'}',
                ),
              ),
            ],
          ),

          // Description
          if (assignment.description != null && assignment.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'توضیحات',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColor.lightGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assignment.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.darkText,
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                debugPrint('View assignment: ${assignment.title}');
              },
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('مشاهده جزئیات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.1),
                foregroundColor: color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: color.withOpacity(0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EXAMS TAB ====================
  Widget _buildExamsTab() {
    return FutureBuilder<Map<String, List<ExamItem>>>(
      future: _examsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.purple),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                const Text('خطا در بارگذاری امتحانات'),
              ],
            ),
          );
        }

        final allExams = snapshot.data ?? {};
        final pending = allExams['pending'] ?? [];
        final answered = allExams['answered'] ?? [];
        final scored = allExams['scored'] ?? [];

        if (pending.isEmpty && answered.isEmpty && scored.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 80,
                  color: AppColor.lightGray,
                ),
                const SizedBox(height: 16),
                const Text(
                  'امتحانی وجود ندارد',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.lightGray,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (pending.isNotEmpty) ...[
                _buildSectionHeader('در انتظار', Colors.orange, pending.length),
                ...pending.map((e) => _buildExamCard(e, Colors.orange)),
                const SizedBox(height: 20),
              ],
              if (answered.isNotEmpty) ...[
                _buildSectionHeader('ارسال شده', Colors.blue, answered.length),
                ...answered.map((e) => _buildExamCard(e, Colors.blue)),
                const SizedBox(height: 20),
              ],
              if (scored.isNotEmpty) ...[
                _buildSectionHeader('نمره‌دار', Colors.green, scored.length),
                ...scored.map((e) => _buildExamCard(e, Colors.green)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamCard(ExamItem exam, Color color) {
    final percentage = exam.score != null && exam.totalScore != null
        ? (int.parse(exam.score.toString()) / int.parse(exam.totalScore!)) * 100
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exam.courseName,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.lightGray,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              if (exam.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${exam.score}/${exam.totalScore}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          // Details Row
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.calendar_today_outlined,
                  'تاریخ',
                  exam.dueDate ?? 'نامشخص',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.access_time_outlined,
                  'ساعت',
                  '${exam.startTime ?? 'نامشخص'} - ${exam.endTime ?? ''}',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.timer_outlined,
                  'مدت',
                  '${exam.duration ?? 'نامشخص'} دقیقه',
                ),
              ),
            ],
          ),

          // Description
          if (exam.description != null && exam.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'توضیحات',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColor.lightGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exam.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.darkText,
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Score Info for Scored Exams
          if (exam.status == ExamStatus.scored && percentage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'درصد',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColor.lightGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                debugPrint('View exam: ${exam.title}');
              },
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('مشاهده جزئیات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.1),
                foregroundColor: color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: color.withOpacity(0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildSectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.folder_outlined, size: 20, color: color),
            const SizedBox(width: 10),
            Text(
              '$title',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '($count)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColor.purple.withOpacity(0.6)),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColor.lightGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
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
}