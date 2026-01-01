import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/features/admin/student_management/presentations/widgets/student_tile.dart';

import '../../data/models/student_model.dart';

class StudentListSection extends StatelessWidget {
  final List<StudentModel> students;
  final String Function(int?) getClassName;
  final void Function(StudentModel) onEdit;
  final void Function(int) onDelete;
  final void Function(StudentModel) onTap;
  final bool autoExpand;

  const StudentListSection({
    super.key,
    required this.students,
    required this.getClassName,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.autoExpand,
  });

  Map<int?, List<StudentModel>> _groupStudents() {
    final Map<int?, List<StudentModel>> groups = {};
    for (var student in students) {
      groups[student.stuClass] ??= [];
      groups[student.stuClass]!.add(student);
    }
    return groups;
  }

  List<int?> _getSortedClassIds(Map<int?, List<StudentModel>> groups) {
    final classIds = groups.keys.toList();
    classIds.sort((a, b) {
      final nameA = getClassName(a);
      final nameB = getClassName(b);
      return nameA.compareTo(nameB);
    });
    return classIds;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupStudents();
    final sortedClassIds = _getSortedClassIds(groups);

    return ListView.builder(
      itemCount: sortedClassIds.length,
      itemBuilder: (context, index) {
        final classId = sortedClassIds[index];
        final classStudents = groups[classId]!;
        final className = getClassName(classId);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            initiallyExpanded: autoExpand,
            title: Row(
              children: [
                const Icon(Icons.class_, color: AppColor.primary),
                const SizedBox(width: 8),
                Text(
                  className,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${classStudents.length} دانش‌آموز',
                  style: const TextStyle(color: AppColor.lightGray),
                ),
              ],
            ),
            children: classStudents.map((student) => StudentTile(
              student: student,
              onTap: () => onTap(student),
              onEdit: () => onEdit(student),
              onDelete: () => onDelete(student.studentId),
            )).toList(),
          ),
        );
      },
    );
  }
}