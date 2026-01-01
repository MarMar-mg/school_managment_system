// lib/features/admin/student_management/presentations/widgets/student_list_section.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/features/admin/student_management/presentations/widgets/student_tile.dart';

import '../../data/models/student_model.dart';

class StudentListSection extends StatelessWidget {
  final List<StudentModel> students;
  final String Function(int?) getClassName;
  final void Function(StudentModel) onEdit;
  final void Function(int) onDelete;
  final void Function(StudentModel) onTap;
  final bool autoExpand;

  const StudentListSection({
    super.key,
    required this.students,
    required this.getClassName,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.autoExpand,
  });

  Map<int?, List<StudentModel>> _groupStudents() {
    final Map<int?, List<StudentModel>> groups = {};
    for (var student in students) {
      groups[student.stuClass] ??= [];
      groups[student.stuClass]!.add(student);
    }
    return groups;
  }

  List<int?> _getSortedClassIds(Map<int?, List<StudentModel>> groups) {
    final classIds = groups.keys.toList();
    classIds.sort((a, b) {
      final nameA = getClassName(a);
      final nameB = getClassName(b);
      return nameA.compareTo(nameB);
    });
    return classIds;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupStudents();
    final sortedClassIds = _getSortedClassIds(groups);

    return Column(
      children: sortedClassIds.asMap().entries.map((entry) {
        final index = entry.key;
        final classId = entry.value;
        final classStudents = groups[classId]!;
        final className = getClassName(classId);

        return _ClassGroupTile(
          className: className,
          studentCount: classStudents.length,
          students: classStudents,
          initiallyExpanded: autoExpand,
          onStudentTap: onTap,
          onStudentEdit: onEdit,
          onStudentDelete: onDelete,
          index: index,
        );
      }).toList(),
    );
  }
}

class _ClassGroupTile extends StatefulWidget {
  final String className;
  final int studentCount;
  final List<StudentModel> students;
  final bool initiallyExpanded;
  final Function(StudentModel) onStudentTap;
  final Function(StudentModel) onStudentEdit;
  final Function(int) onStudentDelete;
  final int index;

  const _ClassGroupTile({
    required this.className,
    required this.studentCount,
    required this.students,
    required this.initiallyExpanded,
    required this.onStudentTap,
    required this.onStudentEdit,
    required this.onStudentDelete,
    required this.index,
  });

  @override
  State<_ClassGroupTile> createState() => _ClassGroupTileState();
}

class _ClassGroupTileState extends State<_ClassGroupTile>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );

    if (_isExpanded) {
      _animController.forward();
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (!_initialized) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 300 + (widget.index * 50)),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                // Header
                InkWell(
                  onTap: _toggleExpand,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Class icon with gradient background
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColor.purple.withOpacity(0.2),
                                AppColor.purple.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.class_,
                            color: AppColor.purple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Class name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.className,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColor.darkText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.studentCount} دانش‌آموز',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.lightGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge with student count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.studentCount}',
                            style: const TextStyle(
                              color: AppColor.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Expand/Collapse icon
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.expand_more,
                            color: AppColor.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expanded content
                if (_isExpanded)
                  SizeTransition(
                    sizeFactor: _animation,
                    axisAlignment: 1.0,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Column(
                        children: [
                          Container(
                            height: 1,
                            color: Colors.grey.shade100,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          ...widget.students.asMap().entries.map((entry) {
                            final studentIndex = entry.key;
                            final student = entry.value;

                            return _StudentListItem(
                              student: student,
                              isLast: studentIndex == widget.students.length - 1,
                              onTap: () => widget.onStudentTap(student),
                              onEdit: () => widget.onStudentEdit(student),
                              onDelete: () => widget.onStudentDelete(student.studentId),
                              index: studentIndex,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentListItem extends StatelessWidget {
  final StudentModel student;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;

  const _StudentListItem({
    required this.student,
    required this.isLast,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 200 + (index * 30)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.purple.withOpacity(0.8),
                          AppColor.purple.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.name.isNotEmpty
                            ? student.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Student info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColor.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.badge_rounded,
                              size: 12,
                              color: AppColor.lightGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student.studentCode,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColor.lightGray,
                              ),
                            ),
                            if (student.debt > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_rounded,
                                      size: 10,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'بدهی',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  SizedBox(
                    width: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ActionButton(
                          icon: Icons.edit_rounded,
                          color: Colors.blue,
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.delete_rounded,
                          color: Colors.red,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                color: Colors.grey.shade100,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}