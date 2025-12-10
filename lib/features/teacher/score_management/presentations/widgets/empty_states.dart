import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class EmptyStateSelector extends StatelessWidget {
  final String selectedType;
  final bool isLoading;
  final String error;
  final int itemCount;

  const EmptyStateSelector({
    super.key,
    required this.selectedType,
    required this.isLoading,
    required this.error,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty) {
      return _buildErrorState();
    }

    if (isLoading) {
      return _buildLoadingState();
    }

    if (itemCount == 0) {
      return _buildEmptyItemsState();
    }

    return _buildSelectState();
  }

  Widget _buildSelectState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              '${selectedType == 'exam' ? 'امتحان' : 'تمرین'} را انتخاب کنید',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'نمرات و وضعیت ارسال دانش‌آموزان نمایش داده خواهد شد',
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

  Widget _buildEmptyItemsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              'هیچ ${selectedType == 'exam' ? 'امتحان' : 'تمرین'} ایی یافت نشد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'برای شروع یک ${selectedType == 'exam' ? 'امتحان' : 'تمرین'} ایجاد کنید',
              style: TextStyle(
                fontSize: 13,
                color: AppColor.lightGray,
              ),
            ),
          ],
        ),
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

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColor.purple,
        ),
      ),
    );
  }
}