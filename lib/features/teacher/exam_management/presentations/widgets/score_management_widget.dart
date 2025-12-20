import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';

void showExamScoreManagementDialog(
    BuildContext context, {
      required int examId,
      required String examTitle,
      required int possibleScore,
    }) {
  showDialog(
    context: context,
    builder: (context) => ExamScoreManagementDialog(
      examId: examId,
      examTitle: examTitle,
      possibleScore: possibleScore,
    ),
  );
}

class ExamScoreManagementDialog extends StatefulWidget {
  final int examId;
  final String examTitle;
  final int possibleScore;

  const ExamScoreManagementDialog({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.possibleScore,
  });

  @override
  State<ExamScoreManagementDialog> createState() =>
      _ExamScoreManagementDialogState();
}

class _ExamScoreManagementDialogState extends State<ExamScoreManagementDialog> {
  late Future<List<dynamic>> _submissionsFuture;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _submissionsFuture = ApiService.getExamSubmissions(widget.examId);
      _statsFuture = ApiService.getExamStats(widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColor.backgroundColor,
      child: Column(
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
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مدیریت نمرات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.examTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Card
                  FutureBuilder<Map<String, dynamic>>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final stats = snapshot.data!;
                        return _buildStatsCard(stats);
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submissions Title
                  const Text(
                    'ارسال‌های دانش‌آموزان',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkText,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),

                  // Submissions List
                  FutureBuilder<List<dynamic>>(
                    future: _submissionsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('خطا: ${snapshot.error}'),
                        );
                      }

                      final submissions = snapshot.data ?? [];

                      if (submissions.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 48,
                                  color: AppColor.lightGray,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'ارسالی یافت نشد',
                                  style: TextStyle(color: AppColor.lightGray),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: List.generate(
                          submissions.length,
                              (index) => _buildSubmissionCard(submissions[index]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Footer Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: AppColor.darkText,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('تازه کردن'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('بستن'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.purple, AppColor.lightPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'کل رسال ها',
                '${stats['totalSubmissions']}',
              ),
              _buildStatItem(
                'نمره‌دار',
                '${stats['gradedSubmissions']}',
              ),
              _buildStatItem(
                'درانتظار',
                '${stats['pendingSubmissions']}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'میانگین',
                '${stats['averageScore']}',
              ),
              _buildStatItem(
                'قبول شدگان',
                '${stats['passPercentage']}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionCard(dynamic submission) {
    final hasScore = submission['score'] != null;
    final score = submission['score'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission['studentName'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ارسال: ${submission['submittedAt']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.lightGray,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              if (hasScore)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getScoreColor(score).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$score/${widget.possibleScore}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score),
                    ),
                  ),
                )
              else
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'درانتظار',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showScoreDialog(submission),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.edit, size: 16),
              label: Text(hasScore ? 'ویرایش نمره' : 'اضافه کردن نمره',
                  style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showScoreDialog(dynamic submission) {
    final scoreController = TextEditingController(
      text: submission['score']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'نمره: ${submission['studentName']}',
          textDirection: TextDirection.rtl,
        ),
        content: TextField(
          controller: scoreController,
          keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'نمره (0-${widget.possibleScore})',
            hintTextDirection: TextDirection.rtl,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.purple, width: 2),
            ),
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () async {
              final score = double.tryParse(scoreController.text);
              if (score == null ||
                  score < 0 ||
                  score > widget.possibleScore) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'نمره باید بین 0 و ${widget.possibleScore} باشد',
                      textDirection: TextDirection.rtl,
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await ApiService.updateSubmissionScore(
                  submission['submissionId'],
                  score,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('نمره با موفقیت ذخیره شد'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطا: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.purple,
            ),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    final percentage = (score / widget.possibleScore) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}