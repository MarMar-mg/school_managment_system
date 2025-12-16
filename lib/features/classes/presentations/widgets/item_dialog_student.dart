import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/features/student/assignments/data/models/assignment_model.dart.dart';
import 'package:school_management_system/features/student/exam/entities/models/exam_model.dart';
import 'package:school_management_system/commons/utils/manager/date_manager.dart';
import '../../../student/assignments/presentations/widgets/assignment_card.dart';
import '../../../student/exam/presentations/widgets/exam_card.dart';
import '../../../student/shared/presentations/widgets/submit_answer_dialog.dart';
import 'package:school_management_system/core/services/exam_time_validator.dart';

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
  late Future<Map<String, List<AssignmentItemm>>> _assignmentsFuture;
  late Future<Map<String, List<ExamItem>>> _examsFuture;

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
    _assignmentsFuture = ApiService.getAllAssignments(widget.userId).then((data) {
      final String courseName = widget.course['name'] ?? '';
      final List<AssignmentItemm> pending = (data['pending'] as List<AssignmentItemm>? ?? []).where((item) => item.subject == courseName).toList();
      final List<AssignmentItemm> answeredSubmitted = (data['answered_submitted'] as List<AssignmentItemm>? ?? []);
      final List<AssignmentItemm> answeredNotSubmitted = (data['answered_not_submitted'] as List<AssignmentItemm>? ?? []);
      final List<AssignmentItemm> submitted = [...answeredSubmitted, ...answeredNotSubmitted].where((item) => item.subject == courseName).toList();
      final List<AssignmentItemm> graded = (data['scored'] as List<AssignmentItemm>? ?? []).where((item) => item.subject == courseName).toList();

      return {
        'pending': pending,
        'submitted': submitted,
        'graded': graded,
      };
    });
    _examsFuture = ApiService.getAllExams(widget.userId).then((data) {
      final String courseName = widget.course['name'] ?? '';
      final List<ExamItem> pending = (data['pending'] as List<ExamItem>? ?? []).where((item) => item.courseName == courseName).toList();
      final List<ExamItem> answeredSubmitted = (data['answered_submitted'] as List<ExamItem>? ?? []);
      final List<ExamItem> answeredNotSubmitted = (data['answered_not_submitted'] as List<ExamItem>? ?? []);
      final List<ExamItem> submitted = [...answeredSubmitted, ...answeredNotSubmitted].where((item) => item.courseName == courseName).toList();
      final List<ExamItem> graded = (data['scored'] as List<ExamItem>? ?? []).where((item) => item.courseName == courseName).toList();

      return {
        'pending': pending,
        'submitted': submitted,
        'graded': graded,
      };
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.course['name'] ?? 'نام درس',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColor.purple,
              unselectedLabelColor: AppColor.lightGray,
              indicatorColor: AppColor.purple,
              tabs: const [
                Tab(text: 'تکالیف'),
                Tab(text: 'امتحانات'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FutureBuilder<Map<String, List<AssignmentItemm>>>(
                    future: _assignmentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('خطا: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data!;
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildAssignmentSection('در انتظار', data['pending'] ?? [], Colors.orange, 'pending'),
                          _buildAssignmentSection('ارسال شده', data['submitted'] ?? [], Colors.blue, 'submitted'),
                          _buildAssignmentSection('نمره‌دار', data['graded'] ?? [], Colors.green, 'graded'),
                        ],
                      );
                    },
                  ),
                  FutureBuilder<Map<String, List<ExamItem>>>(
                    future: _examsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('خطا: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data!;
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildExamSection('در انتظار', data['pending'] ?? [], Colors.orange, 'pending'),
                          _buildExamSection('ارسال شده', data['submitted'] ?? [], Colors.blue, 'submitted'),
                          _buildExamSection('نمره‌دار', data['graded'] ?? [], Colors.green, 'graded'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentSection(
      String title, List<AssignmentItemm> items, Color color, String key) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) => _toggleSection(key),
      children: [
        ExpansionPanel(
          isExpanded: _expandedSections[key]!,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text('$title (${items.length})'),
            );
          },
          body: items.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text('موردی یافت نشد'),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return AssignmentCard(
                item: items[index],
                userId: widget.userId,
                onRefresh: widget.onRefresh,
                isDone: key == 'graded',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExamSection(
      String title, List<ExamItem> items, Color color, String key) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) => _toggleSection(key),
      children: [
        ExpansionPanel(
          isExpanded: _expandedSections[key]!,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text('$title (${items.length})'),
            );
          },
          body: items.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text('موردی یافت نشد'),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ExamCard(
                item: items[index],
                userId: widget.userId,
                onRefresh: widget.onRefresh,
              );
            },
          ),
        ),
      ],
    );
  }
}