import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../data/models/course_model.dart';
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
    setState(() => _isLoading = true); // safe at start

    try {
      _allCourses = await ApiService().getAllCourses();

      if (widget.isEdit && widget.teacher != null) {
        final teacherId = widget.teacher!.teacherId;
        print('Loading courses for teacher $teacherId');

        try {
          final teacherCourses = await ApiService().getTeacherCourses(
            teacherId,
          );

          // ← Critical fix: only setState if widget still mounted
          if (mounted) {
            setState(() {
              _selectedCourseIds = teacherCourses
                  .map((c) => c.courseId)
                  .toSet();
              print(
                'Pre-selected ${teacherCourses.length} courses: $_selectedCourseIds',
              );
            });
          } else {
            print('Widget disposed - skipping setState for courses');
          }
        } catch (e) {
          print('Failed to load teacher courses: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ناتوانی در بارگذاری دروس فعلی معلم'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('General load error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری اطلاعات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    print('START _saveTeacher() - isEdit: ${widget.isEdit}');

    if (!_formKey.currentState!.validate()) {
      print('→ Form validation FAILED');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً همه فیلدهای الزامی را پر کنید')),
      );
      return;
    }
    print('→ Form validation PASSED');

    if (_selectedCourseIds.isEmpty) {
      print('→ No courses selected - exiting');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل یک درس باید انتخاب شود')),
      );
      return;
    }
    print(
      '→ Courses selected: ${_selectedCourseIds.length} items → ${_selectedCourseIds.toList()}',
    );

    setState(() => _isSaving = true);
    print('→ Saving started');

    try {
      late int teacherId;
      String? newUsername;
      String? newPassword;

      if (widget.isEdit) {
        print('→ Updating existing teacher ID: ${widget.teacher!.teacherId}');
        await ApiService().updateTeacher(widget.teacher!.teacherId, {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'nationalCode': _nationalCodeController.text.trim(),
          'email': _emailController.text.trim(),
        });
        teacherId = widget.teacher!.teacherId;
        print('→ Update success - teacherId: $teacherId');
      } else {
        print('→ Creating new teacher');
        final created = await ApiService().addTeacher({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'nationalCode': _nationalCodeController.text.trim(),
          'email': _emailController.text.trim(),
        });

        teacherId = created.teacherId;
        // If backend returns username/password for new user
        newUsername =
            created.username; // add these fields to TeacherModel if needed
        newPassword = created.password;

        print('→ Create success - new teacherId: $teacherId');
        if (newUsername != null) {
          print(
            '→ New user created - username: $newUsername, password: $newPassword',
          );
        }
      }

      // Assignment block
      print('ASSIGNMENT BLOCK REACHED - teacherId: $teacherId');

      // Load current courses (for edit mode or to avoid duplicates)
      Set<int> currentIds = {};
      try {
        final currentCourses = await ApiService().getTeacherCourses(teacherId);
        currentIds = currentCourses.map((c) => c.courseId).toSet();
        print('→ Current assigned courses: $currentIds');
      } catch (e) {
        print(
          '→ Warning: Could not load current courses: $e (continuing anyway)',
        );
      }

      // Assign selected courses (add only new ones)
      for (final courseId in _selectedCourseIds) {
        if (currentIds.contains(courseId)) {
          print('→ Course $courseId already assigned - skipping');
          continue;
        }

        print('→ Assigning course $courseId to teacher $teacherId');
        try {
          await ApiService().assignTeacherToCourse(teacherId, courseId);
          print('  ✓ Assigned $courseId');
        } catch (e) {
          print('  ✗ Assign failed for $courseId: $e');
          // You can decide: continue or show error
        }
      }

      // Unassign removed courses (only if we could load current ones)
      if (currentIds.isNotEmpty) {
        final toRemove = currentIds.difference(_selectedCourseIds.toSet());
        for (final oldId in toRemove) {
          print('→ Unassigning removed course $oldId');
          try {
            await ApiService().unassignTeacherFromCourse(oldId);
            print('  ✓ Unassigned $oldId');
          } catch (e) {
            print('  ✗ Unassign failed for $oldId: $e');
          }
        }
      }

      print('SAVE COMPLETE - should refresh list now');

      // Show success + credentials (only for new teacher)
      String successMsg = 'معلم با موفقیت ذخیره شد';
      if (!widget.isEdit && newUsername != null) {
        successMsg +=
            '\nنام کاربری: $newUsername\nرمز عبور اولیه: $newPassword\n(لطفاً فوراً تغییر دهید)';
      }

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          duration: const Duration(seconds: 10),
        ),
      );
    } catch (e, stack) {
      print('CATCH BLOCK - ERROR: $e');
      print('Stack trace: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در ذخیره: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
      print('END _saveTeacher()');
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
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'ایمیل معتبر وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                const Text(
                  'انتخاب دروس تدریس',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Course selection (you can also make it required)
                ..._allCourses.map(
                  (course) => CheckboxListTile(
                    title: Text(
                      '${course.className} - ${course.name}',
                      textDirection: TextDirection.rtl,
                    ),
                    value: _selectedCourseIds.contains(course.courseId),
                    // ← this must be true for assigned ones
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
                  ),
                ),

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
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('ذخیره', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
