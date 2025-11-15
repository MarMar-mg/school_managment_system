import 'package:flutter/material.dart';

class ColorMapper {
  static Color getColor(String name) {
    switch (name) {
      case 'purple':
        return Colors.purple;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  static Color getProgressColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.yellow;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}