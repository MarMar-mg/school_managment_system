import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/features/teacher/exam_management/data/models/exam_model.dart';
import 'score_header.dart';
import 'type_selector.dart';
import 'score_class_selection.dart';
import 'item_selector.dart';
import 'submissions_view.dart';
import 'empty_states.dart';

class ScoreManagementBody extends StatefulWidget {
  final String selectedType;
  final List<ExamModelT> exams;
  final List<dynamic> assignments;
  final bool isLoading;
  final String error;
  final int userId;
  final Function(String) onTypeChanged;
  final VoidCallback onRetry;

  const ScoreManagementBody({
    super.key,
    required this.selectedType,
    required this.exams,
    required this.assignments,
    required this.isLoading,
    required this.error,
    required this.userId,
    required this.onTypeChanged,
    required this.onRetry,
  });

  @override
  State<ScoreManagementBody> createState() => _ScoreManagementBodyState();
}

class _ScoreManagementBodyState extends State<ScoreManagementBody> {
  dynamic _selectedItem;
  List<dynamic> _selectedItemSubmissions = [];
  bool _isLoadingSubmissions = false;
  String _submissionsError = '';
  int? _selectedClassId;
  String? _selectedClassName;

  void _onClassSelected(int classId, String className) {
    setState(() {
      _selectedClassId = classId;
      _selectedClassName = className;
      _selectedItem = null;
      _selectedItemSubmissions = [];
      _submissionsError = '';
    });

    // If type is already 'course' when class changes → load immediately
    if (widget.selectedType == 'course' && classId > 0) {
      print('Class changed in course mode → loading students for class: $classId');
      _loadSubmissions({
        'id': classId,
        'name': className,
      });
    }
  }

  Future<void> _loadSubmissions(dynamic item) async {
    if (item == null) return;

    setState(() {
      _selectedItem = item;
      _isLoadingSubmissions = true;
      _submissionsError = '';
      _selectedItemSubmissions = [];
    });

    try {
      late List<dynamic> students;

      if (widget.selectedType == 'exam') {

        final exam = _selectedItem as ExamModelT;
        final examId = (item is Map)
            ? (item['id'] ?? item['examId'] ?? item['examid'] ?? 0)
            : 0;
        students = examId != 0? await ApiService.getExamStudents(examId):  await ApiService.getExamStudents(exam.id);

        // _selectedItem = {
        //   'id': exam.id,
        //   'title': exam.title,
        //   'possibleScore': exam.possibleScore,
        //   'courseId': exam.courseId,
        // };
      } else if (widget.selectedType == 'course') {
        final courseId =
        (item is Map)
            ? (item['id'] ?? item['courseId'] ?? item['courseid'] ?? 0)
            : 0;

        print('Course mode: Using courseId = $courseId from selected class');

        if (courseId == 0) {
          throw Exception('شناسه درس معتبر نیست');
        }

        final response = await ApiService().getCourseStudentsScores(courseId);
        print('API called! Response: $response');

        students = (response['students'] != null)
            ? List<dynamic>.from(response['students'])
            : [];
      } else {
        // assignment / exercise
        final exerciseId = (item is Map)
            ? (item['id'] ?? item['exerciseid'] ?? 0)
            : 0;

        if (exerciseId == 0) {
          throw Exception('شناسه تمرین معتبر نیست');
        }

        students = await ApiService.getExerciseStudents(exerciseId);
      }

      setState(() {
        _selectedItemSubmissions = students;
        print('Students set: ${students.length}');
      });
    } catch (e) {
      String message = e.toString();
      print(message);
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      setState(() {
        _submissionsError = message.isEmpty
            ? 'خطا در بارگذاری اطلاعات'
            : message;
      });
    } finally {
      setState(() {
        _isLoadingSubmissions = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ScoreManagementBody oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When type changes to 'course' AND class is already selected → auto load
    if (widget.selectedType == 'course' &&
        widget.selectedType != oldWidget.selectedType &&
        _selectedClassId != null &&
        _selectedClassId! > 0) {

      print('Type changed to course → auto-loading students for existing class: $_selectedClassId');

      _loadSubmissions({
        'id': _selectedClassId,
        'name': _selectedClassName ?? 'درس انتخاب‌شده',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScoreHeader(),
        const SizedBox(height: 20),
        ScoreClassSelection(
          userId: widget.userId,
          onClassSelected: _onClassSelected,
        ),
        const SizedBox(height: 24),
        TypeSelector(
          selectedType: widget.selectedType,
          onTypeChanged: widget.onTypeChanged,
        ),
        const SizedBox(height: 24),
        ItemSelector(
          selectedType: widget.selectedType,
          exams: widget.exams,
          assignments: widget.assignments,
          isLoading: widget.isLoading,
          error: widget.error,
          selectedItem: _selectedItem,
          selectedClassId: _selectedClassId,
          onItemSelected: _loadSubmissions,
          onRetry: widget.onRetry,
        ),
        const SizedBox(height: 24),
        if (_selectedItem != null || widget.selectedType == 'course')
          SubmissionsView(
            selectedType: widget.selectedType,
            selectedItem: _selectedItem,
            submissions: _selectedItemSubmissions,
            isLoading: _isLoadingSubmissions,
            error: _submissionsError,
            userId: widget.userId,
            onReload: () => _loadSubmissions(_selectedItem),
          )
        else if (widget.selectedType != 'course')
          EmptyStateSelector(
            selectedType: widget.selectedType,
            isLoading: widget.isLoading,
            error: widget.error,
            itemCount: widget.selectedType == 'exam'
                ? widget.exams.length
                : (widget.selectedType == 'course'
                      ? 0 // or you can change logic later if needed
                      : widget.assignments.length),
          ),
      ],
    );
  }
}
