import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import '../../data/models/class_group.dart';
import '../../data/models/teacher_model.dart';
import '../widgets/add_edit_teacher_dialog.dart';
import '../widgets/teacher_details_dialog.dart';
import '../widgets/teacher_tile.dart';

class TeacherManagementPage extends StatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  State<TeacherManagementPage> createState() => _TeacherManagementPageState();
}

class _TeacherManagementPageState extends State<TeacherManagementPage> {
  // Flat list (for search/filter fallback)
  List<TeacherModel> _teachers = [];
  List<TeacherModel> _filteredTeachers = [];

  // Grouped + unassigned
  List<ClassGroup> _groupedTeachers = [];
  List<TeacherModel> _unassignedTeachers = [];

  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeachers(); // optional flat list
    _loadGroupedTeachers(); // main grouped + unassigned
    _searchController.addListener(_filterTeachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    print('Loading flat teachers...');
    try {
      final teachers = await ApiService().getTeachers();
      print('Flat teachers loaded: ${teachers.length}');

      if (mounted) {
        setState(() {
          _teachers = teachers;
          _filteredTeachers = List.from(teachers);
        });
      }
    } catch (e) {
      print('Flat teachers error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری معلمان: $e')));
      }
    }
  }

  Future<void> _loadGroupedTeachers() async {
    print('Starting _loadGroupedTeachers');

    setState(() => _isLoading = true);

    try {
      final response = await ApiService().getTeachersGroupedByClass();

      print('Grouped loaded: ${response.groupedClasses.length} classes');
      print('Unassigned: ${response.unassignedTeachers.length} teachers');

      setState(() {
        _groupedTeachers = response.groupedClasses;
        _unassignedTeachers = response.unassignedTeachers;
      });
    } catch (e, stackTrace) {
      print('Error loading grouped teachers: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری گروه‌بندی معلمان: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Finished _loadGroupedTeachers');
    }
  }

  void _filterTeachers() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredTeachers = _teachers.where((teacher) {
        return teacher.name.toLowerCase().contains(query) ||
            (teacher.phone?.toLowerCase().contains(query) ?? false) ||
            (teacher.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _addTeacher() {
    showDialog<bool>(
      context: context,
      builder: (_) => const AddEditTeacherDialog(isEdit: false),
    ).then((updated) {
      if (updated == true) {
        _loadTeachers();
        _loadGroupedTeachers();
      }
    });
  }

  void _editTeacher(TeacherModel teacher) {
    showDialog<bool>(
      context: context,
      builder: (_) => AddEditTeacherDialog(isEdit: true, teacher: teacher),
    ).then((updated) {
      if (updated == true) {
        _loadTeachers();
        _loadGroupedTeachers();
      }
    });
  }

  void _deleteTeacher(int id) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تایید حذف'),
        content: const Text(
          'آیا از حذف این معلم و حساب کاربری آن مطمئن هستید؟',
        ),
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
          _loadGroupedTeachers();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('معلم و حساب کاربری با موفقیت حذف شدند'),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('خطا در حذف: $e')));
          }
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
    print(
      'Rendering UI: ${_groupedTeachers.length} groups + ${_unassignedTeachers.length} unassigned',
    );
    return ResponsiveContainer(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'جستجو بر اساس نام، تلفن یا ایمیل...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              textDirection: TextDirection.rtl,
            ),
          ),

          // Add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FloatingActionButton.extended(
                onPressed: _addTeacher,
                backgroundColor: AppColor.purple,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('افزودن معلم جدید'),
              ),
            ),
          ),

          // Main content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadTeachers();
                      await _loadGroupedTeachers();
                    },
                    child: CustomScrollView(
                      slivers: [
                        // Grouped Classes Section
                        if (_groupedTeachers.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'معلمان بر اساس کلاس',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final group = _groupedTeachers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  group.className,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${group.teachers.length} معلم',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                childrenPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                children: group.teachers.map((teacher) {
                                  return TeacherTile(
                                    teacher: teacher,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            TeacherDetailsDialog(
                                              teacher: teacher,
                                            ),
                                      );
                                    },
                                    onEdit: () => _editTeacher(teacher),
                                    onDelete: () =>
                                        _deleteTeacher(teacher.teacherId),
                                  );
                                }).toList(),
                              ),
                            );
                          }, childCount: _groupedTeachers.length),
                        ),

                        // Unassigned Teachers Section
                        if (_unassignedTeachers.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'معلمان بدون کلاس یا درس (${_unassignedTeachers.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),

                        if (_unassignedTeachers.isNotEmpty)
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final teacher = _unassignedTeachers[index];
                              return TeacherTile(
                                teacher: teacher,
                                onTap: () => _showTeacherDetails(teacher),
                                onEdit: () => _editTeacher(teacher),
                                onDelete: () =>
                                    _deleteTeacher(teacher.teacherId),
                              );
                            }, childCount: _unassignedTeachers.length),
                          ),

                        // Empty state
                        if (_groupedTeachers.isEmpty &&
                            _unassignedTeachers.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.school_outlined,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'هیچ معلمی ثبت نشده است',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'معلم جدید اضافه کنید',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _addTeacher,
                                    child: const Text('افزودن معلم جدید'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
