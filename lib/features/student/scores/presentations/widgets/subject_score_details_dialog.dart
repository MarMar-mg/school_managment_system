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

  double _average(List<num> scores) {
    if (scores.isEmpty) return 0;

    final total = scores.fold<double>(
      0,
          (sum, item) => sum + item.toDouble(),
    );

    return total / scores.length;
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final items = snapshot.data!;
                      return _buildSection(
                        title: 'تمرینات نمره‌دار',
                        itemsCount: items.length,
                        average: _average(items.map((e) => e.totalScore!.toInt()).toList()),
                        expandedKey: 'assignments',
                        children: items
                            .map((e) => TitleScoreTile(
                          title: e.title,
                          score: e.totalScore!.toInt(),
                        ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<ExamItem>>(
                    future: _examsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final items = snapshot.data!;
                      return _buildSection(
                        title: 'امتحانات نمره‌دار',
                        itemsCount: items.length,
                        average: _average(items.map((e) => e.score!.toInt()).toList()),
                        expandedKey: 'exams',
                        children: items
                            .map((e) => TitleScoreTile(
                          title: e.title,
                          score: e.score!.toInt(),
                        ))
                            .toList(),
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

  Widget _buildSection({
    required String title,
    required int itemsCount,
    required double average,
    required String expandedKey,
    required List<Widget> children,
  }) {
    return ExpansionPanelList(
      expansionCallback: (_, __) => _toggleSection(expandedKey),
      children: [
        ExpansionPanel(
          isExpanded: _expandedSections[expandedKey]!,
          headerBuilder: (_, __) => ListTile(
            title: Text('$title ($itemsCount)'),
            subtitle: Text(
              'میانگین: ${average.toStringAsFixed(1)}',
              style: TextStyle(
                color: scoreColor(average),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: children.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Text('موردی یافت نشد'),
          )
              : Column(children: children),
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
    final color = scoreColor(score);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

Color scoreColor(num score) {
  if (score < 10) return Colors.red;
  if (score < 15) return Colors.orange;
  return Colors.green;
}
