// lib/features/admin/student_management/presentations/pages/student_management_page.dart
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStudents() {
    setState(() {
      _isLoading = true;
    });
    _studentsFuture = ApiService.getAllStudents()
        .then((data) {
          _allStudents = data
              .map((json) => StudentModel.fromJson(json))
              .toList();
          _loadClassNames();
          setState(() {
            _isLoading = false;
          });
          return _allStudents;
        })
        .catchError((error) {
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
        final classId = classData['id'] as int?;
        final className = classData['name'] ?? 'نامشخص';
        if (classId != null) {
          _classNameCache[classId] = className;
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading class names: $e');
      for (var student in _allStudents) {
        if (student.stuClass != null &&
            !_classNameCache.containsKey(student.stuClass)) {
          _classNameCache[student.stuClass!] = 'کلاس ${student.stuClass}';
        }
      }
      if (mounted) setState(() {});
    }
  }

  String _getClassName(int? classId) {
    if (classId == null) return 'نامشخص';
    return _classNameCache[classId] ?? 'کلاس $classId';
  }

  Future<void> _addOrEditStudent({
    required bool isEdit,
    StudentModel? student,
  }) async {
    final result = await showDialog<StudentModel?>(
      context: context,
      builder: (context) =>
          AddEditStudentDialog(isEdit: isEdit, student: student),
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('دانش‌آموز به‌روزرسانی شد'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          //Show credentials in success message
          final response = await ApiService.createStudent(
            name: result.name,
            studentCode: result.studentCode,
            stuClass: result.stuClass?.toString() ?? '',
            phone: result.phone ?? '',
            parentPhone: result.parentPhone ?? '',
            birthDate: result.birthDate ?? '',
            address: result.address ?? '',
            debt: result.debt,
          );

          if (mounted) {
            // Show dialog with credentials
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('دانش‌آموز ایجاد شد', style: TextStyle(fontSize: 16)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اطلاعات ورود:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نام کاربری: ${response['username']}',
                            style: const TextStyle(fontSize: 13),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'رمز عبور: ${response['password']}',
                            style: const TextStyle(fontSize: 13),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'این اطلاعات را به دانش‌آموز اطلاع دهید',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('متوجه شدم'),
                  ),
                ],
              ),
            );
          }
        }
        _loadStudents();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
          );
        }
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
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این دانش‌آموز را حذف کنید؟',
        ),
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
        await ApiService.deleteStudent(studentId, widget.userId);
        _loadStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('دانش‌آموز حذف شد'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطا در حذف: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
        username: student.username,
        password: student.password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ResponsiveContainer(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 20),

                  // Stats Card
                  FutureBuilder<Map<String, dynamic>>(
                    future: ApiService.getStudentStats(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return _buildStatsCard(snapshot.data!);
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 28),

                  // Student List Section
                  FutureBuilder<List<StudentModel>>(
                    future: _studentsFuture,
                    builder: (context, snapshot) {
                      if (_isLoading ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final filteredStudents = _allStudents.where((student) {
                        final name = student.name.toLowerCase();
                        final code = student.studentCode.toLowerCase();
                        final className = _getClassName(
                          student.stuClass,
                        ).toLowerCase();
                        return name.contains(_searchTerm) ||
                            code.contains(_searchTerm) ||
                            className.contains(_searchTerm);
                      }).toList();

                      if (filteredStudents.isEmpty) {
                        return _buildNoResultsState();
                      }

                      return StudentListSection(
                        students: filteredStudents,
                        getClassName: _getClassName,
                        onEdit: (student) =>
                            _addOrEditStudent(isEdit: true, student: student),
                        onDelete: _deleteStudent,
                        onTap: _showStudentDetails,
                        autoExpand: _searchTerm.isNotEmpty,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مدیریت دانش‌آموزان',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Text(
                'مشاهده و مدیریت تمام دانش‌آموزان سیستم',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.lightGray,
                  height: 1.4,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.purple, AppColor.lightPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColor.purple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _addOrEditStudent(isEdit: false),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'افزودن',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'جستجو بر اساس نام، کد یا کلاس...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColor.lightGray,
            size: 20,
          ),
          suffixIcon: _searchTerm.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchTerm = '');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColor.lightGray,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    final totalStudents = stats['totalStudents'] ?? 0;
    final studentsWithDebt = stats['studentsWithDebt'] ?? 0;
    final studentsWithoutDebt = stats['studentsWithoutDebt'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'کل دانش‌آموزان',
              value: '$totalStudents',
              icon: Icons.group_rounded,
              color: AppColor.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatItem(
              label: 'بدهی ندارند',
              value: '$studentsWithoutDebt',
              icon: Icons.check_circle_rounded,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatItem(
              label: 'دارای بدهی',
              value: '$studentsWithDebt',
              icon: Icons.warning_rounded,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: AppColor.purple,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'در حال بارگذاری...',
              style: TextStyle(fontSize: 14, color: AppColor.lightGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'خطا در بارگذاری اطلاعات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.lightGray, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadStudents,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تلاش مجدد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColor.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 50,
                color: AppColor.purple,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'هیچ دانش‌آموزی یافت نشد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'برای شروع یک دانش‌آموز جدید افزوده کنید',
              style: TextStyle(fontSize: 13, color: AppColor.lightGray),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _addOrEditStudent(isEdit: false),
              icon: const Icon(Icons.add_rounded),
              label: const Text('افزودن دانش‌آموز اول'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppColor.lightGray),
            const SizedBox(height: 16),
            const Text(
              'نتیجه‌ای یافت نشد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'با شرایط جستجویی "$_searchTerm" دانش‌آموزی وجود ندارد',
              style: TextStyle(fontSize: 13, color: AppColor.lightGray),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColor.lightGray,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
