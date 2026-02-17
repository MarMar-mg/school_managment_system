import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../../commons/date_manager.dart';
//TODO: to give the course general score

class SubmissionsTable extends StatefulWidget {
  final List<dynamic> submissions;
  final dynamic maxScore;
  final String selectedType;
  final int userId;
  final VoidCallback onScoreSaved;
  final dynamic selectedItem;

  const SubmissionsTable({
    super.key,
    required this.submissions,
    required this.maxScore,
    required this.selectedType,
    required this.userId,
    required this.onScoreSaved,
    this.selectedItem,
  });

  @override
  State<SubmissionsTable> createState() => _SubmissionsTableState();
}

class _SubmissionsTableState extends State<SubmissionsTable>
    with TickerProviderStateMixin {
  late Map<int, TextEditingController> _controllers;
  late Map<int, double?> _originalScores;
  bool _isSubmitting = false;
  final Map<int, TextEditingController> _scoreControllers = {};
  final Map<int, String> _selectedMonths = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = {};
    _originalScores = {};

    for (int i = 0; i < widget.submissions.length; i++) {
      final sub = widget.submissions[i];

      String initialText = '';

      if (widget.selectedType == 'course') {
        final currentScoreMap = sub['currentScore'] as Map?;
        initialText = currentScoreMap?['scoreValue']?.toString() ?? '';
      } else {
        initialText = sub['score']?.toString() ?? '';
      }

      _controllers[i] = TextEditingController(text: initialText);
      _originalScores[i] = double.tryParse(initialText);
    }
  }

  @override
  void didUpdateWidget(SubmissionsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.submissions != widget.submissions) {
      for (var controller in _controllers.values) {
        controller.dispose();
      }
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveCourseScores() async {
    final courseId = widget.selectedItem?['id'] ??
        widget.selectedItem?['courseId'] ??
        widget.selectedItem?['courseid'] ??
        0;

    if (courseId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('شناسه درس یافت نشد'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final updates = <Map<String, dynamic>>[];

    try {
      final currentMonth = Jalali.now().toString().substring(0, 7);

      int updatedCount = 0;

      // Use the same _controllers (now pre-filled with current score)
      for (int i = 0; i < widget.submissions.length; i++) {
        final controller = _controllers[i];
        if (controller == null) continue;

        final text = controller.text.trim();

        // Allow empty = clear to 0
        final score = text.isEmpty ? 0.0 : double.tryParse(text);
        if (score == null || score < 0 || score > 100) continue;

        final originalScore = _originalScores[i];

        // Only add if changed (including clearing to 0)
        if (score != originalScore) {
          final student = widget.submissions[i];
          final studentId = student['studentId'] as int? ?? 0;

          if (studentId > 0) {
            updates.add({
              'studentId': studentId,
              'scoreValue': score,
              'scoreMonth': currentMonth,
            });
            updatedCount++;
          }
        }
      }

      if (updates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هیچ نمره‌ای تغییر نکرده است'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      await ApiService().updateCourseScores(courseId, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'نمرات ($updatedCount مورد) با موفقیت ذخیره شد',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onScoreSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ذخیره: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validateAll() {
    final maxScoreInt = widget.maxScore is int
        ? widget.maxScore
        : int.tryParse(widget.maxScore.toString()) ?? 100;

    for (int i = 0; i < widget.submissions.length; i++) {
      final text = _controllers[i]?.text.trim() ?? '';

      if (text.isEmpty) continue;

      final score = double.tryParse(text);
      if (score == null || score < 0 || score > maxScoreInt) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submitAll() async {
    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لطفاً نمرات نامعتبر را اصلاح کنید (0 تا ${widget.maxScore})',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int updatedCount = 0;

      for (int i = 0; i < widget.submissions.length; i++) {
        final text = _controllers[i]?.text.trim() ?? '';

        if (text.isEmpty) continue;

        final score = double.parse(text);
        final originalScore = _originalScores[i];

        if (score != originalScore) {
          final submission = widget.submissions[i];
          final submissionId = submission['submissionId'] as int?;
          final studentId = submission['studentId'] as int;

          if (submissionId != null && submissionId > 0) {
            if (widget.selectedType == 'exam') {
              await ApiService.updateSubmissionScore(submissionId, score);
            }
            else{
              await ApiService.updateSubmissionScoreEx(submissionId, score);
            }
          } else {
            if (widget.selectedType == 'exam') {
              final examId = submission['examId'] as int;
              await ApiService.createExamScoreForStudent(examId, studentId, score);
            } else {
              final exerciseId = submission['exerciseId'] as int;
              await ApiService.createExerciseScoreForStudent(exerciseId, studentId, score);
            }
          }
          updatedCount++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedCount == 0
                  ? 'هیچ تغییری انجام نشد'
                  : 'نمرات ($updatedCount) با موفقیت ذخیره شد',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onScoreSaved();
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
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: AppColor.lightGray),
            const SizedBox(height: 16),
            const Text('دانش‌آموزی یافت نشد'),
          ],
        ),
      );
    }

    if (widget.selectedType == 'course') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 20),
                  label: const Text('ذخیره نمرات درس'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : _saveCourseScores,
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 32,
                    ),
                    child: DataTable(
                      columnSpacing: 20,
                      horizontalMargin: 16,
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade50),
                      headingRowHeight: 50,
                      dataRowHeight: 65,
                      columns: const [
                        DataColumn(label: Text('نام دانش‌آموز', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.lightGray), textDirection: TextDirection.rtl)),
                        DataColumn(label: Text('کد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.lightGray))),
                        DataColumn(label: Text('وضعیت', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.lightGray), textDirection: TextDirection.rtl)),
                        DataColumn(label: Text('نمره', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.lightGray), textDirection: TextDirection.rtl)),
                        DataColumn(label: Text('درصد', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColor.lightGray), textDirection: TextDirection.rtl)),
                      ],
                      rows: List<DataRow>.generate(
                        widget.submissions.length,
                            (index) => _buildDataRow(index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrollable Table
          Flexible(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.grey.shade50,
                    ),
                    headingRowHeight: 50,
                    dataRowHeight: 65,
                    columns: [
                      DataColumn(
                        label: Text(
                          'نام دانش‌آموز',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.lightGray,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'کد',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.lightGray,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'وضعیت',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.lightGray,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'نمره',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.lightGray,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'درصد',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.lightGray,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      widget.submissions.length,
                          (index) => _buildDataRow(index),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Submit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'ذخیره نمرات',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(int index) {
    final student = widget.submissions[index];
    final hasSubmitted = student['hasSubmitted'] == true;
    final studentName = student['studentName'] ?? 'نامشخص';
    final stuCode = student['stuCode']?.toString() ?? '-';

    int maxScoreInt = widget.maxScore is int
        ? widget.maxScore as int
        : int.tryParse(widget.maxScore.toString()) ?? 100;
    if (widget.selectedType == 'course') maxScoreInt = 100;

    final currentScoreStr = _controllers[index]?.text ?? '';
    final currentScore = double.tryParse(currentScoreStr);
    final percentage = currentScore != null && maxScoreInt > 0
        ? ((currentScore / maxScoreInt) * 100).toStringAsFixed(0)
        : '-';

    return DataRow(
      color: MaterialStateColor.resolveWith((states) {
        return index.isEven ? Colors.grey.shade50 : Colors.white;
      }),
      cells: [
        // Student Name
        DataCell(
          Text(
            studentName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Code
        DataCell(
          Text(
            stuCode,
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.lightGray,
            ),
          ),
        ),

        // Status
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hasSubmitted
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              hasSubmitted ? 'ارسال' : 'بدون ارسال',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: hasSubmitted ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ),

        // Score Input
        DataCell(
          _buildScoreInput(index),
        ),

        // Percentage
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPercentageColor(percentage).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getPercentageColor(percentage).withOpacity(0.3),
              ),
            ),
            child: Text(
              percentage == '-' ? '-' : '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getPercentageColor(percentage),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreInput(int index) {
    return SizedBox(
      width: 70,
      child: TextField(
        key: ValueKey('score_$index'),
        controller: _controllers[index],
        keyboardType:
        const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: Colors.grey.shade300),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: AppColor.purple.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: AppColor.purple,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          isDense: true,
        ),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColor.purple,
        ),
        onChanged: (val) => setState(() {}),
      ),
    );
  }

  Color _getPercentageColor(String percentage) {
    if (percentage == '-') return Colors.grey;
    final p = int.tryParse(percentage.replaceAll('%', '')) ?? 0;
    if (p >= 90) return const Color(0xFF9C27B0);
    if (p >= 80) return Colors.green;
    if (p >= 70) return Colors.orange;
    if (p >= 60) return Colors.deepOrange;
    return Colors.red;
  }
}