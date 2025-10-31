import 'dart:ui';
import 'colors.dart';

enum Role { student, teacher, admin }

extension RoleExtension on Role {
  String get title {
    switch (this) {
      case Role.student: return 'student';
      case Role.teacher: return 'teacher';
      case Role.admin: return 'admin';
    }
  }

  List<Color> get gradient {
    switch (this) {
      case Role.student: return [AppColor.studentBaseColor, AppColor.studentSecondColor];
      case Role.teacher: return [AppColor.teacherBaseColor, AppColor.teacherSecondColor];
      case Role.admin: return [AppColor.adminBaseColor, AppColor.adminSecondColor];
    }
  }
}