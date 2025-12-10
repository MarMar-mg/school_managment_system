import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

import '../../../../../core/services/api_service.dart';

class SubmissionsTable extends StatefulWidget {
  final List<dynamic> submissions;
  final dynamic maxScore;
  final String selectedType;
  final int userId;
  final VoidCallback onScoreSaved;

  const SubmissionsTable({
    super.key,
    required this.submissions,
    required this.maxScore,
    required this.selectedType,
    required this.userId,
    required this.onScoreSaved,
  });

  @override
  State<SubmissionsTable> createState() => _SubmissionsTableState();
}

class _SubmissionsTableState extends State<SubmissionsTable> {
  late List<TextEditingController> _controllers;
  late List<double?> _originalScores;

  @override
  void initState() {
    super.initState();
    _controllers = widget.submissions
        .map((s) => TextEditingController(text: s['score']?.toString() ?? ''))
        .toList();
    _originalScores = widget.submissions.map((s) => s['score'] as double?).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _validateAll() {
    final maxScoreInt = widget.maxScore is int
        ? widget.maxScore
        : int.tryParse(widget.maxScore.toString()) ?? 100;

    for (int i = 0; i < widget.submissions.length; i++) {
      if (widget.submissions[i]['hasSubmitted'] != true) continue;

      final text = _controllers[i].text;
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
        const SnackBar(
          content: Text(
            'لطفاً نمرات نامعتبر را اصلاح کنید',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      for (int i = 0; i < widget.submissions.length; i++) {
        if (widget.submissions[i]['hasSubmitted'] != true) continue;

        final text = _controllers[i].text;
        final score = double.parse(text); // Safe now
        await ApiService.updateSubmissionScore(
          widget.submissions[i]['submissionId'],
          score,
        );
      }

      widget.onScoreSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 16,
                headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.grey.shade50,
                ),
                headingRowHeight: 50,
                dataRowHeight: 60,
                columns: [
                  DataColumn(
                    label: Text(
                      'شماره دانشجویی',
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
                      (index) {
                    final student = widget.submissions[index];
                    final studentName = student['studentName'] ?? 'نامشخص';
                    final hasSubmitted = student['hasSubmitted'] == true;
                    final maxScoreInt = widget.maxScore is int
                        ? widget.maxScore
                        : int.tryParse(widget.maxScore.toString()) ?? 100;

                    final currentScoreStr = _controllers[index].text;
                    final currentScore = double.tryParse(currentScoreStr) ?? 0;
                    final percentage = hasSubmitted && maxScoreInt > 0
                        ? ((currentScore / maxScoreInt) * 100).toStringAsFixed(0)
                        : '-';

                    return DataRow(
                      color: MaterialStateColor.resolveWith((states) {
                        return index.isEven ? Colors.grey.shade50 : Colors.white;
                      }),
                      cells: [
                        DataCell(
                          Text(
                            student['stuCode']?.toString() ?? '-',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColor.darkText,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        DataCell(
                          Text(
                            studentName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColor.darkText,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: hasSubmitted
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hasSubmitted ? 'ارسال شده' : 'ارسال نشده',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: hasSubmitted ? Colors.green : Colors.red,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            width: 40,
                            decoration: BoxDecoration(
                              color: hasSubmitted
                                  ? AppColor.purple.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: hasSubmitted
                                  ? Border.all(
                                color: AppColor.purple.withOpacity(0.3),
                              )
                                  : Border.all(
                                color: AppColor.gray.withOpacity(0.2),
                              ),
                            ),
                            child: TextField(
                              controller: _controllers[index],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColor.purple,
                              ),
                              textDirection: TextDirection.rtl,
                              onChanged: (val) => setState(() {}),
                            )
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            width: 54,
                            decoration: BoxDecoration(
                              color: _getPercentageColor(percentage).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _getPercentageColor(percentage).withOpacity(0.3),
                              ),
                            ),
                            child: hasSubmitted? Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getPercentageColor(percentage),
                              ),
                              textDirection: TextDirection.rtl,
                            ):Text(
                              '-',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getPercentageColor(percentage),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ارسال نمرات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(String percentage) {
    final p = int.tryParse(percentage.replaceAll('%', '')) ?? 0;
    if (p >= 90) return const Color(0xFF9C27B0); // Purple
    if (p >= 80) return Colors.green;
    if (p >= 70) return Colors.orange;
    return Colors.red;
  }
}