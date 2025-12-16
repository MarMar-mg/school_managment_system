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

  Future<void> _loadSubmissions(dynamic item) async {
    setState(() {
      _selectedItem = item;
      _isLoadingSubmissions = true;
      _submissionsError = '';
    });

    try {
      late List<dynamic> students;

      if (widget.selectedType == 'exam') {
        final exam = item as ExamModelT;
        students = await ApiService.getExamStudents(exam.id);
      } else {
        students = await ApiService.getExerciseStudents(item['id']);
      }

      setState(() {
        _selectedItemSubmissions = students;
        _isLoadingSubmissions = false;
      });
    } catch (e) {
      setState(() {
        _submissionsError = e.toString();
        _isLoadingSubmissions = false;
      });
    }
  }

  void _onClassSelected(int classId, String className) {
    setState(() {
      _selectedClassId = classId;
      _selectedClassName = className;
      _selectedItem = null;
      _selectedItemSubmissions = [];
    });
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
        if (_selectedItem != null)
          SubmissionsView(
            selectedType: widget.selectedType,
            selectedItem: _selectedItem,
            submissions: _selectedItemSubmissions,
            isLoading: _isLoadingSubmissions,
            error: _submissionsError,
            userId: widget.userId,
            onReload: () => _loadSubmissions(_selectedItem),
          )
        else
          EmptyStateSelector(
            selectedType: widget.selectedType,
            isLoading: widget.isLoading,
            error: widget.error,
            itemCount: widget.selectedType == 'exam'
                ? widget.exams.length
                : widget.assignments.length,
          ),
      ],
    );
  }
}
