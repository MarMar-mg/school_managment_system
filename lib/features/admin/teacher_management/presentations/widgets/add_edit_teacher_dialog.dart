import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../data/models/course_model.dart'; // Assume you create CourseModel
import '../../data/models/teacher_model.dart';

class AddEditTeacherDialog extends StatefulWidget {
  final bool isEdit;
  final TeacherModel? teacher;

  const AddEditTeacherDialog({super.key, required this.isEdit, this.teacher});

  @override
  State<AddEditTeacherDialog> createState() => _AddEditTeacherDialogState();
}

class _AddEditTeacherDialogState extends State<AddEditTeacherDialog> {
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalCodeController;
  late TextEditingController _emailController;
  List<CourseModel> _allCourses = [];
  Set<int> _selectedCourseIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  Future<void> _loadData() async {
    try {
      _allCourses = await ApiService()
          .getAllCourses(); // Implement this in ApiService
      if (widget.isEdit) {
        final teacherCourses = await ApiService().getTeacherCourses(
          widget.teacher!.teacherId,
        );
        _selectedCourseIds = teacherCourses.map((c) => c.courseId).toSet();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری دروس: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher?.name ?? '');
    _phoneController = TextEditingController(text: widget.teacher?.phone ?? '');
    _nationalCodeController = TextEditingController(
      text: widget.teacher?.nationalCode ?? '',
    );
    _emailController = TextEditingController(text: widget.teacher?.email ?? '');

    _loadData();
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً همه فیلدهای الزامی را پر کنید'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'nationalCode': _nationalCodeController.text.trim(),
        'email': _emailController.text.trim(),
      };

      late TeacherModel savedTeacher;
      if (widget.isEdit) {
        await ApiService().updateTeacher(widget.teacher!.teacherId, data);
        savedTeacher = widget.teacher!.copyWith(
          name: data['name'],
          phone: data['phone'],
          nationalCode: data['nationalCode'],
          email: data['email'],
        );
      } else {
        savedTeacher = await ApiService().addTeacher(data);
      }
      if (widget.isEdit) {
        await ApiService().updateTeacher(widget.teacher!.teacherId, data);
        savedTeacher = widget.teacher!;
      } else {
        savedTeacher = await ApiService().addTeacher(data);
      }

      // Handle assignments
      final currentCourses = await ApiService().getTeacherCourses(
        savedTeacher.teacherId,
      );
      final currentIds = currentCourses.map((c) => c.courseId).toSet();

      final toAssign = _selectedCourseIds.difference(currentIds);
      final toUnassign = currentIds.difference(_selectedCourseIds);

      for (final cid in toAssign) {
        await ApiService().assignTeacherToCourse(savedTeacher.teacherId, cid);
      }
      for (final cid in toUnassign) {
        await ApiService().unassignTeacherFromCourse(cid);
      }

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عملیات با موفقیت انجام شد')),
      );
    } catch (e) {
      String errorMsg = 'خطا در افزودن معلم';
      if (e.toString().contains('این شماره تلفن قبلاً')) {
        errorMsg = 'این شماره تلفن قبلاً ثبت شده است';
      } else if (e.toString().contains('کد ملی')) {
        errorMsg = 'این کد ملی قبلاً ثبت شده است';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'ویرایش معلم' : 'افزودن معلم جدید'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name - required
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام و نام خانوادگی *',
                    border: OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.rtl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'نام معلم را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone - required
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'شماره موبایل *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.rtl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'شماره موبایل الزامی است';
                    }
                    if (value.length < 11 || !value.startsWith('09')) {
                      return 'شماره موبایل معتبر وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // National Code - required
                TextFormField(
                  controller: _nationalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'کد ملی *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'کد ملی الزامی است';
                    }
                    if (value.length != 10) {
                      return 'کد ملی باید ۱۰ رقم باشد';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email - required (or make optional if you prefer)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'ایمیل *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ایمیل الزامی است';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'ایمیل معتبر وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                const Text('انتخاب دروس تدریس', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Course selection (you can also make it required)
                ..._allCourses.map((course) => CheckboxListTile(
                  title: Text('${course.className} - ${course.name}', textDirection: TextDirection.rtl),
                  value: _selectedCourseIds.contains(course.courseId),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedCourseIds.add(course.courseId);
                      } else {
                        _selectedCourseIds.remove(course.courseId);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                )),

                // Optional: warn if no courses selected
                if (_selectedCourseIds.isEmpty && !_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'حداقل یک درس باید انتخاب شود',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveTeacher,
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          child: _isSaving
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : const Text('ذخیره', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}