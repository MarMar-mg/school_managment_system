import 'package:flutter/material.dart';
import 'package:school_management_system/commons/untils.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/features/student/exam/entities/models/exam_model.dart';

import '../../../assignments/data/models/assignment_model.dart.dart';

void showSubjectScoreDetailsDialog(
    BuildContext context, {
      required String subject,
      required int studentId,
    }) {
  showDialog(
    context: context,
    builder: (context) => SubjectScoreDetailsDialog(
      subject: subject,
      studentId: studentId,
    ),
  );
}

class SubjectScoreDetailsDialog extends StatefulWidget {
  final String subject;
  final int studentId;

  const SubjectScoreDetailsDialog({
    super.key,
    required this.subject,
    required this.studentId,
  });

  @override
  State<SubjectScoreDetailsDialog> createState() =>
      _SubjectScoreDetailsDialogState();
}

class _SubjectScoreDetailsDialogState
    extends State<SubjectScoreDetailsDialog> {
  late Future<List<AssignmentItemm>> _assignmentsFuture;
  late Future<List<ExamItem>> _examsFuture;

  final Map<String, bool> _expandedSections = {
    'assignments': true,
    'exams': true,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _assignmentsFuture =
        ApiService.getAllAssignments(widget.studentId).then((data) {
          return (data['graded'] ?? [])
              .where((e) => e.subject == widget.subject)
              .toList();
        });

    _examsFuture = ApiService.getAllExams(widget.studentId).then((data) {
      return (data['scored'] ?? [])
          .where((e) => e.courseName == widget.subject)
          .toList();
    });
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
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'جزئیات نمرات ${widget.subject}',
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FutureBuilder<List<AssignmentItemm>>(
                    future: _assignmentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('خطا: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      return _buildAssignmentSection(snapshot.data!);
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<ExamItem>>(
                    future: _examsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('خطا: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      return _buildExamSection(snapshot.data!);
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

  Widget _buildAssignmentSection(List<AssignmentItemm> items) {
    return ExpansionPanelList(
      expansionCallback: (_, __) => _toggleSection('assignments'),
      children: [
        ExpansionPanel(
          isExpanded: _expandedSections['assignments']!,
          headerBuilder: (_, __) => ListTile(
            title: Text('تمرینات نمره‌دار (${items.length})'),
          ),
          body: items.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text('تمرینی یافت نشد'),
          )
              : Column(
            children: items
                .map(
                  (item) => TitleScoreTile(
                title: item.title,
                score: item.totalScore!.toInt(),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExamSection(List<ExamItem> items) {
    return ExpansionPanelList(
      expansionCallback: (_, __) => _toggleSection('exams'),
      children: [
        ExpansionPanel(
          isExpanded: _expandedSections['exams']!,
          headerBuilder: (_, __) => ListTile(
            title: Text('امتحانات نمره‌دار (${items.length})'),
          ),
          body: items.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text('امتحانی یافت نشد'),
          )
              : Column(
            children: items
                .map(
                  (item) => TitleScoreTile(
                title: item.title,
                score: item.score!.toInt(),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class TitleScoreTile extends StatelessWidget {
  final String title;
  final num score;

  const TitleScoreTile({
    super.key,
    required this.title,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            score.toString(),
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
