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
      return _buildLoadingShimmer();
    }

    if (error.isNotEmpty) {
      return _buildErrorView();
    }

    if (submissions.isEmpty && selectedItem != null) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedItem != null) ...[
          SubmissionStats(
            submissions: submissions,
            maxScore: selectedType == 'exam'
                ? (selectedItem is ExamModelT ? selectedItem.possibleScore : null)
                : null,
          ),
          const SizedBox(height: 20),
        ],

        SubmissionsTable(
          submissions: submissions,
          maxScore: selectedType == 'exam'
              ? (selectedItem is ExamModelT ? selectedItem.possibleScore : null)
              : null,
          selectedType: selectedType,
          userId: userId,
          onScoreSaved: onReload,
          selectedItem: selectedItem,
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            4,
                (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'خطا در بارگذاری اطلاعات',
              style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش مجدد'),
              onPressed: onReload,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (selectedType) {
      case 'course':
        message = 'هیچ دانش‌آموزی برای این درس یافت نشد';
        icon = Icons.school_outlined;
        break;
      case 'exam':
        message = 'هنوز پاسخی برای این امتحان ثبت نشده است';
        icon = Icons.description_outlined;
        break;
      default:
        message = 'هنوز پاسخی برای این تمرین ثبت نشده است';
        icon = Icons.assignment_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}