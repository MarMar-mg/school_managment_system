import 'package:flutter/material.dart';

class IconMapper {
  static IconData getIcon(String name) {
    switch (name) {
      case 'person':
        return Icons.person;
      case 'group':
        return Icons.group;
      case 'school':
        return Icons.school;
      case 'course':
        return Icons.menu_book;
      case 'score':
        return Icons.star;
      case 'grade':
        return Icons.score;
      case 'assignment':
        return Icons.assignment;
      case 'event':
        return Icons.event;
      default:
        return Icons.info;
    }
  }
}