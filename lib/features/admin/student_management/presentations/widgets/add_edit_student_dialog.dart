import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../data/models/student_model.dart';

class AddEditStudentDialog extends StatefulWidget {
  final bool isEdit;
  final StudentModel? student;

  const AddEditStudentDialog({
    super.key,
    required this.isEdit,
    this.student,
  });

  @override
  State<AddEditStudentDialog> createState() => _AddEditStudentDialogState();
}

class _AddEditStudentDialogState extends State<AddEditStudentDialog> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _classIdController;
  late TextEditingController _phoneController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _addressController;
  late TextEditingController _debtController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _codeController = TextEditingController(text: widget.student?.studentCode ?? '');
    _classIdController = TextEditingController(text: widget.student?.stuClass?.toString() ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _parentPhoneController = TextEditingController(text: widget.student?.parentPhone ?? '');
    _birthDateController = TextEditingController(text: widget.student?.birthDate ?? '');
    _addressController = TextEditingController(text: widget.student?.address ?? '');
    _debtController = TextEditingController(text: widget.student?.debt.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _classIdController.dispose();
    _phoneController.dispose();
    _parentPhoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _debtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'ویرایش دانش‌آموز' : 'افزودن دانش‌آموز'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'نام'),
            ),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'کد دانش‌آموزی'),
            ),
            TextField(
              controller: _classIdController,
              decoration: const InputDecoration(labelText: 'شناسه کلاس'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'شماره تلفن'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _parentPhoneController,
              decoration: const InputDecoration(labelText: 'شماره ولی'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _birthDateController,
              decoration: const InputDecoration(labelText: 'تاریخ تولد'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'آدرس'),
            ),
            TextField(
              controller: _debtController,
              decoration: const InputDecoration(labelText: 'بدهی'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('لغو'),
        ),
        ElevatedButton(
          onPressed: () {
            final classId = _classIdController.text.isEmpty ? null : int.tryParse(_classIdController.text);
            final debt = int.tryParse(_debtController.text) ?? 0;

            final newStudent = StudentModel(
              studentId: widget.student?.studentId ?? 0,
              name: _nameController.text,
              studentCode: _codeController.text,
              stuClass: classId,
              phone: _phoneController.text,
              parentPhone: _parentPhoneController.text,
              birthDate: _birthDateController.text,
              address: _addressController.text,
              debt: debt,
            );
            Navigator.pop(context, newStudent);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
          child: Text(widget.isEdit ? 'به‌روزرسانی' : 'افزودن'),
        ),
      ],
    );
  }
}