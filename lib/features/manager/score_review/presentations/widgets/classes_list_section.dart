import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';

class ClassesListSection extends StatelessWidget {
  final List<dynamic> classes;
  final int? selectedClassId;
  final Function(int) onClassSelected;

  const ClassesListSection({super.key,
    required this.classes,
    required this.selectedClassId,
    required this.onClassSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'آمار پایه‌های تحصیلی',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        ...classes
            .map((cls) => ClassCard(
          classData: cls,
          isSelected: selectedClassId == cls['id'],
          onTap: () => onClassSelected(cls['id']),
        ))
            .toList(),
      ],
    );
  }
}

class ClassCard extends StatelessWidget {
  final dynamic classData;
  final bool isSelected;
  final VoidCallback onTap;

  const ClassCard({
    required this.classData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final studentCount = (classData['studentCount'] as num?)?.toInt() ?? 0;
    final avgScore = (classData['avgScore'] as num?)?.toDouble() ?? 0;
    final passPercentage = (classData['passPercentage'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.purple.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColor.purple : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColor.purple.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  classData['name'] ?? 'نام کلاس',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColor.purple : AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColor.purple.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    classData['grade'] ?? 'نامشخص',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColor.purple
                          : AppColor.lightGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClassDetailItem(
                  label: 'میانگین',
                  value: avgScore.toStringAsFixed(1),
                  color: AppColor.purple,
                ),
                ClassDetailItem(
                  label: 'درصد قبولی',
                  value: '$passPercentage%',
                  color: Colors.green,
                ),
                ClassDetailItem(
                  label: 'تعداد دانش‌آموز',
                  value: '$studentCount',
                  color: AppColor.darkText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ClassDetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const ClassDetailItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColor.lightGray,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}