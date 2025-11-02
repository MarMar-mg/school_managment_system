import 'dart:ui';
import 'colors.dart';

enum Role { student, teacher, manager }

extension RoleExtension on Role {
  String get title {
    switch (this) {
      case Role.student: return 'student';
      case Role.teacher: return 'teacher';
      case Role.manager: return 'manager';
    }
  }

  List<Color> get gradient {
    switch (this) {
      case Role.student: return [AppColor.studentBaseColor, AppColor.studentSecondColor];
      case Role.teacher: return [AppColor.teacherBaseColor, AppColor.teacherSecondColor];
      case Role.manager: return [AppColor.adminBaseColor, AppColor.adminSecondColor];
    }
  }
}
