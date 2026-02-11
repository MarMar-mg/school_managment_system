import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../data/models/teacher_model.dart';

class TeacherDetailsDialog extends StatelessWidget {
  final TeacherModel teacher;

  const TeacherDetailsDialog({
    super.key,
    required this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(teacher.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(teacher.phone!),
            ),
            // Add more details if needed, e.g., assigned courses
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بستن'),
        ),
      ],
    );
  }
}