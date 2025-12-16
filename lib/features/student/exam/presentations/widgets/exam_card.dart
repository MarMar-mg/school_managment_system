import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/untils.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../commons/utils/manager/date_manager.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/services/exam_time_validator.dart';
import '../../../shared/presentations/widgets/submit_answer_dialog.dart';
import '../../entities/models/exam_model.dart';

class ExamCard extends StatelessWidget {
  final ExamItem item;
  final int userId;
  final VoidCallback? onRefresh;

  const ExamCard({
    super.key,
    required this.item,
    required this.userId,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final due = item.dueDate != null ? _formatJalali(item.dueDate!) : null;
    final dueT = item.endTime;
    final time = '${item.startTime} تا ${item.endTime}';
    final submittedD = item.submittedDate != null
        ? _formatJalali(item.submittedDate!)
        : 'بدون پاسخ';
    final submittedT = item.submittedTime != null ? item.submittedTime : '';

    // Check exam status for time validation
    final examStatus = ExamTimeValidator.getExamStatus(
      examDate: item.dueDate ?? '',
      startTime: item.startTime ?? '00:00',
      endTime: item.endTime ?? '23:59',
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Title + Course + Grade (if scored)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _headerColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: _headerColor(),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.courseName,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (item.status == ExamStatus.scored && item.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _gradeColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _gradeLetter(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // TIME STATUS BANNER - Show only for pending exams outside time window
            if (examStatus != 'during' && item.status == ExamStatus.pending)
              _buildTimeStatusBanner(examStatus),

            // Description
            if (item.description?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Text(
                'توضبحات: ${item.description!}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // State-specific content
            if (item.status == ExamStatus.pending)
              ..._pendingContent(due, time, examStatus),
            if (item.status == ExamStatus.answered)
              ..._answeredContent(submittedD, due, dueT),
            if (item.status == ExamStatus.scored)
              ..._scoredContent(submittedT, submittedD),

            const SizedBox(height: 16),
            ((item.status == ExamStatus.pending ||
                        item.status != ExamStatus.answered) &&
                    item.answerImage != null)
                ? _buildShowButton(context)
                : const SizedBox(),
            const SizedBox(height: 16),

            // Action Button
            _buildActionButton(context, examStatus),
          ],
        ),
      ),
    );
  }

  /// Build time status banner for pending exams
  Widget _buildTimeStatusBanner(String status) {
    late String message;
    late Color bannerColor;
    late IconData icon;

    if (status == 'before_start') {
      final minutesUntil = ExamTimeValidator.getMinutesUntilStart(
        examDate: item.dueDate ?? '',
        startTime: item.startTime ?? '00:00',
      );

      message = minutesUntil > 0
          ? 'امتحان ${_formatTimeUntilStart(minutesUntil)} دیگر شروع می‌شود'
          : 'امتحان در حال شروع است...';
      bannerColor = Colors.orange;
      icon = Icons.schedule;
    } else {
      message = 'زمان تحویل امتحان به پایان رسیده است';
      bannerColor = Colors.red;
      icon = Icons.error_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bannerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: bannerColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: bannerColor,
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  /// Format time until exam start in readable format (Days > Hours > Minutes)
  String _formatTimeUntilStart(int totalMinutes) {
    if (totalMinutes <= 0) return '';

    final days = totalMinutes ~/ (24 * 60);
    final remainingAfterDays = totalMinutes % (24 * 60);
    final hours = remainingAfterDays ~/ 60;
    final minutes = remainingAfterDays % 60;

    final parts = <String>[];

    if (days > 0) {
      parts.add('$days روز');
    }
    if (hours > 0) {
      parts.add('$hours ساعت');
    }
    if (minutes > 0) {
      parts.add('$minutes دقیقه');
    }

    // If nothing to show, return minutes
    if (parts.isEmpty) {
      return 'کمتر از یک دقیقه';
    }

    return parts.join(' و ');
  }

  List<Widget> _pendingContent(String? due, String? time, String examStatus) =>
      [
        Row(
          children: [
            _infoChip("", time ?? "نامشخص", Icons.access_time),
            const SizedBox(width: 12),
            _infoChip(
              "",
              DateFormatManager.formatDate(due) ?? "نامشخص",
              Icons.calendar_today,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    " زمان آزمون: ${item.duration}",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "نمره کل: ${item.totalScore}",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Show remaining time during active exam
        if (examStatus == 'during') ...[
          const SizedBox(height: 12),
          _buildRemainingTimeWidget(),
        ],
      ];

  /// Build remaining time widget during active exam
  Widget _buildRemainingTimeWidget() {
    final remainingMinutes = ExamTimeValidator.getRemainingMinutes(
      examDate: item.dueDate ?? '',
      startTime: item.startTime ?? '00:00',
      endTime: item.endTime ?? '23:59',
    );

    if (remainingMinutes <= 0) {
      return const SizedBox();
    }

    final timeFormatted = _formatTimeRemaining(remainingMinutes);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            'زمان باقی‌مانده: $timeFormatted',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Format remaining time in readable format (Days > Hours > Minutes)
  String _formatTimeRemaining(int totalMinutes) {
    if (totalMinutes <= 0) return 'زمان تمام شد';

    final days = totalMinutes ~/ (24 * 60);
    final remainingAfterDays = totalMinutes % (24 * 60);
    final hours = remainingAfterDays ~/ 60;
    final minutes = remainingAfterDays % 60;

    final parts = <String>[];

    if (days > 0) {
      parts.add('$days روز');
    }
    if (hours > 0) {
      parts.add('$hours ساعت');
    }
    if (minutes > 0) {
      parts.add('$minutes دقیقه');
    }

    // If nothing to show, return less than a minute
    if (parts.isEmpty) {
      return 'کمتر از یک دقیقه';
    }

    return parts.join(' و ');
  }

  List<Widget> _answeredContent(
    String? submitted,
    String? due,
    String? dueT,
  ) => [
    Text(
      "اتمام محلت - در انتظار نمره",
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
    ),
    const SizedBox(height: 8),
    Text(
      "زمان پایان: ${due!}($dueT)",
      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
    ),
    const SizedBox(height: 8),
    Text(
      'تاریخ بارگزاری: ${submitted ?? "نامشخص"}',
      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
    ),
  ];

  List<Widget> _scoredContent(String? submittedTime, String? submittedDate) {
    final percent = (item.score! / item.totalScore!.toInt()) * 100;
    return [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  submittedDate!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  submittedTime!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _gradeColor().withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gradeColor().withOpacity(0.3)),
            ),
            child: Text(
              "${item.score}/${item.totalScore}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _gradeColor(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${percent.toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _gradeColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  Widget _infoChip(String label, String value, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            "$label: $value",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    ),
  );

  Widget _buildShowButton(BuildContext context) {
    // Check exam time status
    final examStatus = ExamTimeValidator.getExamStatus(
      examDate: item.dueDate ?? '',
      startTime: item.startTime ?? '00:00',
      endTime: item.endTime ?? '23:59',
    );

    final isTimeValid = examStatus != 'before_start';
    final isTimeExpired = examStatus == 'after_end';

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isTimeValid
            ? () async {
                await _downloadQuestionFile(context, 'exam');
              }
            : null,
        icon: Icon(
          Icons.download_rounded,
          size: 18,
          color: isTimeValid ? AppColor.purple : Colors.grey,
        ),
        label: Text(
          "دانلود سوال",
          style: TextStyle(color: isTimeValid ? AppColor.purple : Colors.grey),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: isTimeValid ? AppColor.purple : Colors.grey,
          side: BorderSide(
            color: isTimeValid
                ? AppColor.purple.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadQuestionFile(BuildContext context, String type) async {
    try {
      // Verify file exists before downloading
      if (item.file == null || item.file!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فایل سوال برای این امتحان موجود نیست'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading dialog
      if (context.mounted) {
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
      }

      // Download file
      print(
        'Attempting to download exam question file for exam: ${item.examId}',
      );
      final fileBytes = await ApiService.downloadExamQuestionFile(item.examId);

      print('Downloaded ${fileBytes.length} bytes');

      // Save file
      final fileName = item.filenameQ ?? 'exam_${item.examId}.pdf';
      final filePath = await ApiService.saveFileToDevice(fileBytes, fileName);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فایل سوال با موفقیت دانلود شد'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Download error: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در دانلود: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildActionButton(BuildContext context, String examStatus) {
    // Check if download is allowed (after start time)
    final isDownloadAllowed = examStatus != 'before_start';

    // Pending: Show "ارسال پاسخ"
    if (item.status == ExamStatus.pending && item.answerImage == null) {
      final isTimeValid = examStatus == 'during';

      return Row(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isTimeValid
                    ? () {
                        print(
                          'DEBUG: Opening dialog with examId=${item.examId}',
                        );
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx) => SubmitAnswerDialog(
                            type: 'exam',
                            id: item.examId,
                            userId: userId,
                            onSubmitted: onRefresh,
                            isEditing: false,
                            examDate: item.dueDate,
                            examStartTime: item.startTime,
                            examEndTime: item.endTime,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.attach_file, size: 18),
                label: const Text("ارسال پاسخ"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTimeValid
                      ? AppColor.purple.withOpacity(0.1)
                      : Colors.grey.shade200,
                  foregroundColor: isTimeValid ? AppColor.purple : Colors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _buildShowButton(context)),
        ],
      );
    }

    // Answered/Pending with answer: Show "تغییر پاسخ" and "دانلود"
    if ((item.status == ExamStatus.pending ||
            item.status == ExamStatus.answered) &&
        item.answerImage != null) {
      final isTimeValid = examStatus == 'during';

      return Row(
        children: [
          // Download Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await _downloadFile(context, 'exam');
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text("دانلود پاسخ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Edit Button
          (item.status != ExamStatus.answered && isTimeValid)
              ? Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print(
                        'DEBUG: Opening edit dialog with examId=${item.examId}',
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext ctx) => SubmitAnswerDialog(
                          type: 'exam',
                          id: item.examId,
                          userId: userId,
                          onSubmitted: onRefresh,
                          isEditing: true,
                          previousDescription: item.submittedDescription,
                          previousFileName: item.filename,
                          examDate: item.dueDate,
                          examStartTime: item.startTime,
                          examEndTime: item.endTime,
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text("تغییر"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              : Expanded(child: _buildShowButton(context)),
        ],
      );
    }

    // Scored: Show download question and view answer buttons
    if (item.status == ExamStatus.scored) {
      return Row(
        children: [
          // Download Question Button (only if allowed and file exists)
          if (isDownloadAllowed && (item.filename ?? '').isNotEmpty)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _downloadQuestionFile(context, 'exam');
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text("دانلود سوال"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade50,
                  foregroundColor: Colors.purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (isDownloadAllowed && (item.filename ?? '').isNotEmpty)
            const SizedBox(width: 8),
          // Download Answer Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await _downloadFile(context, 'exam');
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text("دانلود پاسخ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Default
    return _buildShowButton(context);
  }

  // Download file helper method
  Future<void> _downloadFile(BuildContext context, String type) async {
    try {
      if (item.filename == null || item.filename!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فایل پاسخی برای این امتحان موجود نیست'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      // Show loading dialog
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
        submissionId: item.estId,
        fileName: item.filename ?? 'answer_${item.examId}',
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فایل با موفقیت دانلود شد: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در دانلود: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _headerColor() => switch (item.status) {
    ExamStatus.pending => Colors.orange,
    ExamStatus.answered => Colors.blue,
    ExamStatus.scored => Colors.green,
  };

  Color _gradeColor() {
    final p = (item.score! / item.totalScore!.toInt()) * 100;
    if (p >= 90) return Colors.green;
    if (p >= 80) return Colors.lightGreen;
    if (p >= 70) return Colors.orange;
    if (p >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _gradeLetter() {
    final p = (item.score! / item.totalScore!.toInt()) * 100;
    if (p >= 90) return "A";
    if (p >= 80) return "B";
    if (p >= 70) return "C";
    if (p >= 60) return "D";
    return "F";
  }

  String _formatJalali(String jalali) {
    try {
      final y = int.parse(jalali.substring(0, 4));
      final m = int.parse(jalali.substring(4, 6));
      final d = int.parse(jalali.substring(6, 8));
      final date = Jalali(y, m, d);
      return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
    } catch (e) {
      return jalali;
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
