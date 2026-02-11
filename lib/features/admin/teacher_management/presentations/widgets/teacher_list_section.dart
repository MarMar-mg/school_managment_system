import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../data/models/teacher_model.dart';
import 'teacher_tile.dart'; // Create this

class TeacherListSection extends StatelessWidget {
  final List<TeacherModel> teachers;
  final void Function(TeacherModel) onEdit;
  final void Function(int) onDelete;
  final void Function(TeacherModel) onTap;

  const TeacherListSection({
    super.key,
    required this.teachers,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return TeacherTile(
          teacher: teacher,
          onTap: () => onTap(teacher),
          onEdit: () => onEdit(teacher),
          onDelete: () => onDelete(teacher.teacherId),
        );
      },
    );
  }
}