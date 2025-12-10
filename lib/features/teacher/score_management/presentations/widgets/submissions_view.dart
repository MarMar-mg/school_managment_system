import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/features/teacher/exam_management/data/models/exam_model.dart';
import 'submissions_table.dart';
import 'submission_stats.dart';

class SubmissionsView extends StatelessWidget {
  final String selectedType;
  final dynamic selectedItem;
  final List<dynamic> submissions;
  final bool isLoading;
  final String error;
  final int userId;
  final VoidCallback onReload;

  const SubmissionsView({
    super.key,
    required this.selectedType,
    required this.selectedItem,
    required this.submissions,
    required this.isLoading,
    required this.error,
    required this.userId,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildShimmerLoader();
    }

    if (error.isNotEmpty) {
      return _buildErrorState();
    }

    if (submissions.isEmpty) {
      return _buildNoStudentsState();
    }

    late final String itemTitle;
    late final dynamic maxScore;

    if (selectedItem is ExamModelT) {
      final exam = selectedItem as ExamModelT;
      itemTitle = exam.title ?? 'بدون عنوان';
      maxScore = exam.possibleScore;
    } else {
      itemTitle = selectedItem['title'] ?? 'بدون عنوان';
      final score = selectedItem['possibleScore'] ?? selectedItem['score'] ?? 100;
      maxScore = score is String ? int.tryParse(score) ?? 100 : score;
    }

    int submitted = submissions.where((s) => s['hasSubmitted'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(itemTitle, maxScore, submitted),
        const SizedBox(height: 20),
        SubmissionsTable(
          submissions: submissions,
          maxScore: maxScore,
          selectedType: selectedType,
          userId: userId,
          onScoreSaved: onReload,
        ),
        const SizedBox(height: 20),
        SubmissionStats(
          submissions: submissions,
          maxScore: maxScore,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildInfoCard(String title, dynamic maxScore, int submitted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ارسال شده: $submitted/${submissions.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedType == 'exam' ? 'امتحان' : 'تمرین'} - حداکثر امتیاز: $maxScore',
            style: TextStyle(
              fontSize: 12,
              color: AppColor.lightGray,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'خطا در بارگذاری',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceFirst('Exception: ', ''),
              style: TextStyle(
                fontSize: 13,
                color: AppColor.lightGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoStudentsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              'دانش‌آموزی در این کلاس ثبت نام نشده',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
            ...List.generate(
              5,
                  (_) => Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}