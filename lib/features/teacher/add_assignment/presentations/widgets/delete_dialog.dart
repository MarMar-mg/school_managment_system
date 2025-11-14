import 'package:flutter/material.dart';

void showDeleteDialog(BuildContext context, VoidCallback onDelete,{dynamic assignment}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('حذف تمرین'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text('حذف تمرین')
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () async {
              onDelete();
            },
            child: const Text('ذخیره'),
          ),
        ],
      );
    },
  );
}
