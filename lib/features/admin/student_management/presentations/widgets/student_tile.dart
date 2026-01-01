import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../data/models/student_model.dart';

class StudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentTile({
    super.key,
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColor.primary,
        child: Text(
          student.name.substring(0, 1),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(student.name),
      subtitle: Text('کد: ${student.studentCode}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}