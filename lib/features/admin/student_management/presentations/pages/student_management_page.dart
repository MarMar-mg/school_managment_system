// lib/features/admin/student_management/pages/student_management_page.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';

import '../../data/models/student_model.dart';
import '../widgets/add_edit_student_dialog.dart';
import '../widgets/student_details_dialog.dart';
import '../widgets/student_list_section.dart';

class StudentManagementPage extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const StudentManagementPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  late Future<List<StudentModel>> _studentsFuture;
  List<StudentModel> _allStudents = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  bool _isLoading = false;
  final Map<int, String> _classNameCache = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.toLowerCase();
      });
    });
  }

  void _loadStudents() {
    setState(() {
      _isLoading = true;
    });
    _studentsFuture = ApiService.getAllStudents().then((data) {
      _allStudents = data.map((json) => StudentModel.fromJson(json)).toList();
      _loadClassNames();
      setState(() {
        _isLoading = false;
      });
      return _allStudents;
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    });
  }

  Future<void> _loadClassNames() async {
    try {
      final classIds = _allStudents
          .map((s) => s.stuClass)
          .where((id) => id != null)
          .cast<int>()
          .toSet();

      if (classIds.isEmpty) return;

      final allClasses = await ApiService.getAllClasses();

      for (var classData in allClasses) {
        final classId = classData['id'] as int? ?? classData['classid'] as int? ?? classData['Classid'] as int;
        final className = classData['name'] ?? classData['Name'] ?? 'نامشخص';
        _classNameCache[classId] = className;
      }

      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading class names: $e');
      for (var student in _allStudents) {
        if (student.stuClass != null && !_classNameCache.containsKey(student.stuClass)) {
          _classNameCache[student.stuClass!] = 'کلاس ${student.stuClass}';
        }
      }
      if (mounted) setState(() {});
    }
  }

  String _getClassName(int? classId) {
    if (classId == null) return 'نامشخص';
    return _classNameCache[classId] ?? 'در حال بارگذاری...';
  }

  Future<void> _addOrEditStudent({
    required bool isEdit,
    StudentModel? student,
  }) async {
    final result = await showDialog<StudentModel?>(
      context: context,
      builder: (context) => AddEditStudentDialog(
        isEdit: isEdit,
        student: student,
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (isEdit) {
          await ApiService.updateStudent(
            studentId: result.studentId,
            name: result.name,
            studentCode: result.studentCode,
            stuClass: result.stuClass?.toString() ?? '',
            phone: result.phone ?? '',
            parentPhone: result.parentPhone ?? '',
            birthDate: result.birthDate ?? '',
            address: result.address ?? '',
            debt: result.debt,
          );
        } else {
          await ApiService.createStudent(
            name: result.name,
            studentCode: result.studentCode,
            stuClass: result.stuClass?.toString() ?? '',
            phone: result.phone ?? '',
            parentPhone: result.parentPhone ?? '',
            birthDate: result.birthDate ?? '',
            address: result.address ?? '',
            debt: result.debt,
          );
        }
        _loadStudents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteStudent(int studentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تایید حذف'),
        content: const Text('آیا مطمئن هستید که می‌خواهید این دانش‌آموز را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.deleteStudent(studentId);
        _loadStudents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در حذف: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showStudentDetails(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => StudentDetailsDialog(
        student: student,
        getClassName: _getClassName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer2(
      title: 'مدیریت دانش‌آموزان',
      subtitle: 'لیست و مدیریت دانش‌آموزان سیستم',
      actions: [
        ElevatedButton.icon(
          onPressed: () => _addOrEditStudent(isEdit: false),
          icon: const Icon(Icons.add),
          label: const Text('افزودن دانش‌آموز'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجو بر اساس نام، کد یا کلاس...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StudentModel>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (_isLoading || snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('خطا: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadStudents,
                          child: const Text('تلاش مجدد'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('هیچ دانش‌آموزی یافت نشد'));
                }

                final filteredStudents = _allStudents.where((student) {
                  final name = student.name.toLowerCase();
                  final code = student.studentCode.toLowerCase();
                  final className = _getClassName(student.stuClass).toLowerCase();
                  return name.contains(_searchTerm) || code.contains(_searchTerm) || className.contains(_searchTerm);
                }).toList();

                if (filteredStudents.isEmpty) {
                  return const Center(child: Text('هیچ نتیجه‌ای یافت نشد'));
                }

                return StudentListSection(
                  students: filteredStudents,
                  getClassName: _getClassName,
                  onEdit: (student) => _addOrEditStudent(isEdit: true, student: student),
                  onDelete: _deleteStudent,
                  onTap: _showStudentDetails,
                  autoExpand: _searchTerm.isNotEmpty,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}