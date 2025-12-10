import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/features/teacher/exam_management/data/models/exam_model.dart';
import '../widgets/score_management_body.dart';

class ScoreManagementPage extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const ScoreManagementPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<ScoreManagementPage> createState() => _ScoreManagementPageState();
}

class _ScoreManagementPageState extends State<ScoreManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  String _selectedType = 'exam';
  List<ExamModelT> _exams = [];
  List<dynamic> _assignments = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final exams = await ApiService.getTeacherExams(widget.userId);
      final assignments =
      await ApiService.getTeacherAssignments(widget.userId);

      setState(() {
        _exams = exams;
        _assignments = assignments;
        _isLoading = false;
      });

      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _setSelectedType(String type) {
    setState(() {
      _selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ResponsiveContainer(
            padding: EdgeInsets.zero,
            child: ScoreManagementBody(
              selectedType: _selectedType,
              exams: _exams,
              assignments: _assignments,
              isLoading: _isLoading,
              error: _error,
              userId: widget.userId,
              onTypeChanged: _setSelectedType,
              onRetry: _loadData,
            ),
          ),
        ),
      ),
    );
  }
}