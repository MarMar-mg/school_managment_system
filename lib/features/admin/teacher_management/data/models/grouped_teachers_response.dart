import 'package:school_management_system/features/admin/teacher_management/data/models/teacher_model.dart';
import 'class_group.dart';

class GroupedTeachersResponse {
  final List<ClassGroup> groupedClasses;
  final List<TeacherModel> unassignedTeachers;

  GroupedTeachersResponse({
    required this.groupedClasses,
    required this.unassignedTeachers,
  });

  factory GroupedTeachersResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing GroupedTeachersResponse: $json');

    return GroupedTeachersResponse(
      groupedClasses: (json['groupedClasses'] as List<dynamic>? ?? [])
          .map((g) => ClassGroup.fromJson(g as Map<String, dynamic>))
          .toList(),
      unassignedTeachers: (json['unassignedTeachers'] as List<dynamic>? ?? [])
          .map((t) => TeacherModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}