import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/features/teacher/exam_management/data/models/exam_model.dart';

class ItemSelector extends StatelessWidget {
  final String selectedType;
  final List<ExamModelT> exams;
  final List<dynamic> assignments;
  final bool isLoading;
  final String error;
  final dynamic selectedItem;
  final int? selectedClassId;
  final Function(dynamic) onItemSelected;
  final VoidCallback onRetry;

  const ItemSelector({
    super.key,
    required this.selectedType,
    required this.exams,
    required this.assignments,
    required this.isLoading,
    required this.error,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onRetry,
    this.selectedClassId,
  });

  @override
  Widget build(BuildContext context) {
    // Filter items by selected class
    List<dynamic> filteredItems = selectedClassId == null
        ? []
        : _getFilteredItems();

    if (selectedClassId == null) {
      return _buildNoClassSelected();
    }

    if (isLoading) {
      return _buildShimmerLoader();
    }

    if (error.isNotEmpty && filteredItems.isEmpty) {
      return _buildErrorState();
    }

    if (filteredItems.isEmpty) {
      return _buildEmptyItemsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'انتخاب ${selectedType == 'exam' ? 'امتحان' : 'تمرین'}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: selectedItem,
              hint: Text(
                '${selectedType == 'exam' ? 'امتحان' : 'تمرین'} را انتخاب کنید',
                textDirection: TextDirection.rtl,
              ),
              isExpanded: true,
              items: filteredItems.map<DropdownMenuItem<dynamic>>((item) {
                late final String title;
                late final String description;
                late final String status;

                if (item is ExamModelT) {
                  title = item.title ?? 'بدون عنوان';
                  description = item.description ?? '';
                  status = item.status ?? 'upcoming';
                } else {
                  title = item['title'] ?? 'بدون عنوان';
                  description = item['description'] ?? '';
                  status = 'assignment';
                }

                return DropdownMenuItem<dynamic>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: selectedType == 'exam'
                                    ? (status == 'completed'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1))
                                    : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                selectedType == 'exam'
                                    ? (status == 'completed'
                                    ? 'برگزار شده'
                                    : 'پیش رو')
                                    : 'تمرین',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: selectedType == 'exam'
                                      ? (status == 'completed'
                                      ? Colors.green
                                      : Colors.orange)
                                      : Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Title
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textDirection: TextDirection.rtl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onItemSelected(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  List<dynamic> _getFilteredItems() {
    if (selectedClassId == null) return [];

    if (selectedType == 'exam') {
      return exams
          .where((exam) => exam.courseId == selectedClassId)
          .toList();
    } else {
      return assignments
          .where((assignment) {
        final assignmentClassId = assignment['courseId'];
        return assignmentClassId == selectedClassId;
      })
          .toList();
    }
  }

  Widget _buildNoClassSelected() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.warning_outlined,
              size: 48,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'ابتدا کلاس را انتخاب کنید',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'برای مشاهده ${selectedType == 'exam' ? 'امتحانات' : 'تمرینات'} کلاس را انتخاب کنید',
              style: TextStyle(
                fontSize: 12,
                color: AppColor.lightGray,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'خطا در بارگذاری',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purple,
              ),
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 12),
            Text(
              'هیچ ${selectedType == 'exam' ? 'امتحان' : 'تمرین'} ایی برای این کلاس یافت نشد',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 4),
            Text(
              'برای شروع یک ${selectedType == 'exam' ? 'امتحان' : 'تمرین'} ایجاد کنید',
              style: TextStyle(
                fontSize: 12,
                color: AppColor.lightGray,
              ),
              textDirection: TextDirection.rtl,
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
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}