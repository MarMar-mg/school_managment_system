import 'package:school_management_system/features/admin/teacher_management/data/models/teacher_model.dart';

class ClassGroup {
  final int classId;
  final String className;
  final List<TeacherModel> teachers;

  ClassGroup({
    required this.classId,
    required this.className,
    required this.teachers,
  });

  factory ClassGroup.fromJson(Map<String, dynamic> json) {
    print('Parsing ClassGroup JSON: $json');

    return ClassGroup(
      classId: json['classId'] as int? ?? 0,
      className: json['className'] as String? ?? 'نامشخص',
      teachers: (json['teachers'] as List<dynamic>? ?? [])
          .map((item) {
        final teacherJson = item as Map<String, dynamic>; // ← no nested 'teacher'
        print('Parsing teacher item: $teacherJson');
        return TeacherModel.fromJson(teacherJson);
      })
          .toList(),
    );
  }
}