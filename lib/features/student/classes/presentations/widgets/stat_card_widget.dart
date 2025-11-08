import 'package:flutter/material.dart';
import '../../../../../applications/colors.dart';

class StatCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing
        final isSmall = constraints.maxWidth < 150;
        final iconSize = isSmall ? 20.0 : 24.0;
        final valueSize = isSmall ? 20.0 : 24.0;
        final labelSize = isSmall ? 11.0 : 13.0;
        final padding = isSmall ? 12.0 : 16.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: iconSize),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: labelSize,
                  color: AppColor.lightGray,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        );
      },
    );
  }
}
