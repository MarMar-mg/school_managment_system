import 'package:flutter/material.dart';
import '../../../../../applications/colors.dart';

class TypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {'value': 'exam', 'label': 'امتحان', 'icon': Icons.description},
      {'value': 'assignment', 'label': 'تمرین', 'icon': Icons.assignment},
      {'value': 'course', 'label': 'نمره درس', 'icon': Icons.school},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'نوع نمره‌دهی',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: types.map((t) {
            final isSelected = selectedType == t['value'];
            return GestureDetector(
              onTap: () => onTypeChanged(t['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.purple.withOpacity(0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColor.purple : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t['icon'] as IconData,
                      color: isSelected ? AppColor.purple : AppColor.lightGray,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColor.purple : AppColor.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}