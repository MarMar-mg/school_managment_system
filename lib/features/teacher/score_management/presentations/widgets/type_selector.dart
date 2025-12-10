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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'نوع ارزیابی',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TypeButton(
                  label: 'امتحانات',
                  type: 'exam',
                  icon: Icons.description_outlined,
                  isSelected: selectedType == 'exam',
                  onTap: () => onTypeChanged('exam'),
                ),
              ),
              Expanded(
                child: _TypeButton(
                  label: 'تمرین‌ها',
                  type: 'assignment',
                  icon: Icons.assignment_outlined,
                  isSelected: selectedType == 'assignment',
                  onTap: () => onTypeChanged('assignment'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final String type;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.type,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
          isSelected ? AppColor.purple.withOpacity(0.1) : Colors.transparent,
          border: isSelected
              ? Border(
            top: BorderSide(color: AppColor.purple, width: 3),
          )
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColor.purple : AppColor.lightGray,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColor.purple : AppColor.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}