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
    if (selectedType == 'course') {
      return const SizedBox.shrink();
      // Alternative (uncomment if you want to show info):
      /*
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'نمرات دانش‌آموزان درس به صورت خودکار نمایش داده می‌شود',
          style: TextStyle(fontSize: 15, color: AppColor.darkText),
          textAlign: TextAlign.center,
        ),
      );
      */
    }

    if (selectedClassId == null) {
      return _buildNoClassSelected();
    }

    final filteredItems = _getFilteredItems();

    if (isLoading) {
      return Column(
        children: List.generate(3, (_) => _buildShimmerLoader()),
      );
    }

    if (error.isNotEmpty) {
      return _buildErrorState();
    }

    if (filteredItems.isEmpty) {
      return _buildEmptyItemsState();
    }

    // Determine currently selected ID
    int? selectedId;
    if (selectedItem != null) {
      if (selectedItem is ExamModelT) {
        selectedId = selectedItem.id;
      } else if (selectedItem is Map<String, dynamic>) {
        selectedId = selectedItem['id'] as int? ?? selectedItem['exerciseid'] as int?;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'انتخاب ${selectedType == 'exam' ? 'امتحان' : 'تمرین'}',
          style: const TextStyle(
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
            child: DropdownButton<int?>(
              value: selectedId,
              hint: Text(
                'یک ${selectedType == 'exam' ? 'امتحان' : 'تمرین'} انتخاب کنید',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: AppColor.lightGray),
              ),
              isExpanded: true,
              items: filteredItems.map<DropdownMenuItem<int?>>((item) {
                final itemId = _getItemId(item);
                if (itemId == null || itemId == 0) {
                  return const DropdownMenuItem<int?>(enabled: false, child: SizedBox.shrink());
                }

                final (title, description, status) = _extractItemInfo(item);

                return DropdownMenuItem<int?>(
                  value: itemId,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(status),
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
              onChanged: (int? newId) {
                if (newId == null) return;

                final selected = filteredItems.firstWhere(
                      (item) => _getItemId(item) == newId,
                  orElse: () => null,
                );

                if (selected != null) {
                  onItemSelected(selected);
                } else {
                  debugPrint('Item not found for id: $newId');
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
      return exams.where((exam) => exam.courseId == selectedClassId).toList();
    } else {
      return assignments.where((ass) {
        final assCourseId = ass['courseId'] as int?;
        return assCourseId == selectedClassId;
      }).toList();
    }
  }

  int? _getItemId(dynamic item) {
    if (item is ExamModelT) return item.id;
    if (item is Map<String, dynamic>) {
      return item['id'] as int? ?? item['exerciseid'] as int?;
    }
    return null;
  }

  (String title, String description, String status) _extractItemInfo(dynamic item) {
    if (item is ExamModelT) {
      return (
      item.title ?? 'بدون عنوان',
      item.description ?? '',
      item.status ?? 'upcoming',
      );
    } else if (item is Map<String, dynamic>) {
      return (
      item['title'] as String? ?? 'بدون عنوان',
      item['description'] as String? ?? '',
      'assignment',
      );
    }
    return ('نامشخص', '', 'unknown');
  }

  Color _getStatusColor(String status) {
    if (selectedType == 'exam') {
      return status == 'completed' ? Colors.green : Colors.orange;
    }
    return Colors.blue;
  }

  String _getStatusText(String status) {
    if (selectedType == 'exam') {
      return status == 'completed' ? 'برگزار شده' : 'پیش رو';
    }
    return 'تمرین';
  }

  Widget _buildNoClassSelected() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'ابتدا درس / کلاس را انتخاب کنید',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              'برای نمایش ${selectedType == 'exam' ? 'امتحانات' : 'تمرینات'}، ابتدا درس مورد نظر را انتخاب کنید.',
              style: TextStyle(
                fontSize: 13,
                color: AppColor.lightGray,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'خطا در بارگذاری اطلاعات',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('تلاش مجدد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              'هیچ ${selectedType == 'exam' ? 'امتحانی' : 'تمرینی'} برای این درس یافت نشد',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              'می‌توانید یک ${selectedType == 'exam' ? 'امتحان' : 'تمرین'} جدید ایجاد کنید',
              style: TextStyle(
                fontSize: 13,
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
        height: 68,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}