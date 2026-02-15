import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';

class ScoreClassSelection extends StatefulWidget {
  final int userId;
  final Function(int, String) onClassSelected;

  const ScoreClassSelection({
    super.key,
    required this.userId,
    required this.onClassSelected,
  });

  @override
  State<ScoreClassSelection> createState() => _ScoreClassSelectionState();
}

class _ScoreClassSelectionState extends State<ScoreClassSelection> {
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  String? _selectedCourseId;
  String? _selectedCourseName;


  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await ApiService.getCourses(Role.teacher, widget.userId);
      setState(() {
        _courses = courses;
        _isLoading = false;

        // Select first course by default
        if (courses.isNotEmpty) {
          _selectedCourseId = courses[0]['id'].toString();
          _selectedCourseName = courses[0]['name'] ?? 'نامشخص';
          widget.onClassSelected(
            int.tryParse(_selectedCourseId!) ?? 0,
            _selectedCourseName ?? '',
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'انتخاب درس',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        _isLoading
            ? Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.purple,
                ),
              ),
              Text(
                'درحال بارگذاری...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.lightGray,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        )
            : _courses.isEmpty
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
              ),
              Text(
                'درسی یافت نشد',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade400,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        )
            : Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCourseId,
              isExpanded: true,
              icon: const Icon(
                Icons.expand_more,
                color: AppColor.lightGray,
              ),
              items: _courses.map<DropdownMenuItem<String>>((course) {
                final courseName = course['name'] ?? 'نامشخص';
                final courseCode = course['code'] ?? '';

                return DropdownMenuItem<String>(
                  value: course['id'].toString(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkText,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (courseCode.isNotEmpty) ...[
                            Text(
                              courseCode,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.lightGray,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final selectedCourse = _courses.firstWhere(
                        (course) => course['id'].toString() == value,
                    orElse: () => {},
                  );

                  setState(() {
                    _selectedCourseId = value;
                    _selectedCourseName =
                        selectedCourse['name'] ?? 'نامشخص';
                  });

                  widget.onClassSelected(
                    int.tryParse(value) ?? 0,
                    selectedCourse['name'] ?? 'نامشخص',
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}