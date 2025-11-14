import 'package:flutter/material.dart';

void showAddEditDialog(BuildContext context, {dynamic assignment}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(assignment == null ? 'تمرین جدید' : 'ویرایش تمرین'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Use your exact original content layout (empty for now)
              // The user can fill in the same form as before
              // For example, TextFields, Dropdowns, DatePicker, TimePicker, Score input
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
              // collect form data
              // call add/update API
              // Navigator.pop(context)
              // refresh _fetchData() in parent
            },
            child: const Text('ذخیره'),
          ),
        ],
      );
    },
  );
}
