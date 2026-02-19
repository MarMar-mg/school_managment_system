import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';

void showAssignmentScoreManagementDialog(
  BuildContext context, {
  required int assignmentId,
  required String assignmentTitle,
  required int possibleScore,
  required int userId,
}) {
  showDialog(
    context: context,
    builder: (context) => AssignmentScoreManagementDialog(
      assignmentId: assignmentId,
      assignmentTitle: assignmentTitle,
      possibleScore: possibleScore,
      userId: userId,
    ),
  );
}

class AssignmentScoreManagementDialog extends StatefulWidget {
  final int assignmentId;
  final String assignmentTitle;
  final int possibleScore;
  final int userId;

  const AssignmentScoreManagementDialog({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.possibleScore,
    required this.userId,
  });

  @override
  State<AssignmentScoreManagementDialog> createState() =>
      _AssignmentScoreManagementDialogState();
}

class _AssignmentScoreManagementDialogState
    extends State<AssignmentScoreManagementDialog> {
  late Future<List<dynamic>> _submissionsFuture;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _submissionsFuture = ApiService.getAssignmentSubmissions(
        widget.assignmentId,
        widget.userId,
      );
      _statsFuture = ApiService.getAssignmentStats(widget.assignmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColor.backgroundColor,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                          widget.assignmentTitle,
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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

                    // Submissions List
                    const Text(
                      'پاسخ‌های دانش‌آموزان',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 12),

                    FutureBuilder<List<dynamic>>(
                      future: _submissionsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final submissions = snapshot.data!;
                          if (submissions.isEmpty) {
                            return const Center(
                              child: Text(
                                'هیچ پاسخی یافت نشد',
                                style: TextStyle(color: Colors.grey),
                                textDirection: TextDirection.rtl,
                              ),
                            );
                          }
                          return Column(
                            children: submissions.map((submission) {
                              return _buildSubmissionCard(submission);
                            }).toList(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'خطا: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                              textDirection: TextDirection.rtl,
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'میانگین نمره',
            '${stats['averageScore']?.toStringAsFixed(1) ?? '0.0'}',
            Icons.bar_chart,
            AppColor.purple,
          ),
          _buildStatItem(
            'تعداد پاسخ',
            '${stats['totalSubmissions'] ?? 0}',
            Icons.people_outline,
            Colors.blue,
          ),
          _buildStatItem(
            'بالاترین نمره',
            '${stats['maxScore'] ?? 0}',
            Icons.arrow_upward,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColor.lightGray),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildSubmissionCard(dynamic submission) {
    final hasScore = submission['score'] != null;
    final score = hasScore ? submission['score'].toStringAsFixed(1) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  submission['studentName'] ?? 'نامشخص',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasScore)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(
                      submission['score'],
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    score!,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getScoreColor(submission['score']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'در انتظار',
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
              label: Text(
                hasScore ? 'ویرایش نمره' : 'اضافه کردن نمره',
                style: const TextStyle(fontSize: 12),
              ),
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
    final submittedDescription =
        submission['submittedDescription'] ?? 'بدون توضیح';
    final filename = submission['filename'];
    final estId = submission['studentId'] ?? submission['submissionId'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'نمره: ${submission['studentName'] ?? 'نامشخص'}',
          textDirection: TextDirection.rtl,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Submitted Description
              const Text(
                'پاسخ ارسال شده:',
                style: TextStyle(fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                submittedDescription,
                style: const TextStyle(color: Colors.black87),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),

              // Submitted File (if exists)
              if (filename != null) ...[
                const Text(
                  'فایل ارسال شده:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        filename,
                        style: const TextStyle(color: Colors.blue),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () =>
                      _downloadFile(context, 'assignment', estId, filename),
                  icon: const Icon(Icons.download),
                  label: Text('دانلود: '),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Score Input
              const Text(
                'نمره:',
                style: TextStyle(fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: scoreController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'نمره (0-${widget.possibleScore})',
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColor.purple,
                      width: 2,
                    ),
                  ),
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () async {
              final score = double.tryParse(scoreController.text);
              if (score == null || score < 0 || score > widget.possibleScore) {
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
                print(estId);
                await ApiService.updateSubmissionScoreEx(estId, score);
                print('after');
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
                print('catch');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطا: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(
    BuildContext context,
    String type,
    int submissionId,
    String filename,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('در حال دانلود...'),
            ],
          ),
        ),
      );

      final filePath = await ApiService.downloadAndSaveFile(
        type: type,
        submissionId: submissionId,
        fileName: filename,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فایل دانلود شد: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در دانلود: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getScoreColor(double score) {
    final percentage = (score / widget.possibleScore) * 100;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
