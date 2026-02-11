import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import '../../data/models/teacher_model.dart';
import '../widgets/add_edit_teacher_dialog.dart';
import '../widgets/teacher_details_dialog.dart';
import '../widgets/teacher_list_section.dart';

class TeacherManagementPage extends StatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  State<TeacherManagementPage> createState() => _TeacherManagementPageState();
}

class _TeacherManagementPageState extends State<TeacherManagementPage> {
  List<TeacherModel> _teachers = [];
  List<TeacherModel> _filteredTeachers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeachers();
    _searchController.addListener(_filterTeachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    try {
      _teachers = await ApiService().getTeachers();
      _filteredTeachers = List.from(_teachers);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در بارگذاری معلمان: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterTeachers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTeachers = _teachers.where((teacher) {
        return teacher.name.toLowerCase().contains(query) ||
            teacher.phone!.contains(query);
      }).toList();
    });
  }

  void _addTeacher() {
    showDialog<bool>(
      context: context,
      builder: (_) => const AddEditTeacherDialog(isEdit: false),
    ).then((updated) {
      if (updated == true) _loadTeachers();
    });
  }

  void _editTeacher(TeacherModel teacher) {
    showDialog<bool>(
      context: context,
      builder: (_) => AddEditTeacherDialog(isEdit: true, teacher: teacher),
    ).then((updated) {
      if (updated == true) _loadTeachers();
    });
  }

  void _deleteTeacher(int id) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تایید حذف'),
        content: const Text('آیا از حذف این معلم مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ).then((confirm) async {
      if (confirm == true) {
        try {
          await ApiService().deleteTeacher(id);
          _loadTeachers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('معلم با موفقیت حذف شد')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطا در حذف: $e')),
          );
        }
      }
    });
  }

  void _showTeacherDetails(TeacherModel teacher) {
    showDialog(
      context: context,
      builder: (_) => TeacherDetailsDialog(teacher: teacher),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _addTeacher,
      //   backgroundColor: AppColor.purple,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: _addTeacher,
            backgroundColor: AppColor.purple,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجو بر اساس نام یا تلفن...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: TeacherListSection(
                teachers: _filteredTeachers,
                onEdit: _editTeacher,
                onDelete: _deleteTeacher,
                onTap: _showTeacherDetails,
              ),
            ),
        ],
      ),
    );
  }
}