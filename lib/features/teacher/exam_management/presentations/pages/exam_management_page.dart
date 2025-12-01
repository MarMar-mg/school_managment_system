import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import '../../../../../commons/widgets/section_divider.dart';
import '../../../../../core/services/api_service.dart';
import '../../data/models/exam_model.dart';
import '../../../../../commons/responsive_container.dart';
import '../widgets/add_edit_dialog.dart';
import '../widgets/exam_section.dart';
import '../widgets/header_section.dart';
import '../widgets/stat_card.dart';

class ExamManagementPage extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const ExamManagementPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<ExamManagementPage> createState() => _ExamManagementPageState();
}

// In your ExamManagementPage, update the state variables and methods:

class _ExamManagementPageState extends State<ExamManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardAnimations;

  List<ExamModelT> _upcomingExams = [];
  List<ExamModelT> _completedExams = [];
  List<Map<String, dynamic>> _courses = []; // Add this

  bool _isLoading = true;
  String _error = '';

  final Map<String, bool> _expanded = {'upcoming': false, 'completed': false};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _cardAnimations = [];
    _fetchExams();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchExams() async {
    try {
      setState(() => _isLoading = true);

      // Fetch both exams and courses
      final exams = await ApiService.getTeacherExams(widget.userId);
      final courses = await ApiService.getCourses(Role.teacher, widget.userId);

      setState(() {
        _upcomingExams = exams.where((e) => e.status == 'upcoming').toList();
        _completedExams = exams.where((e) => e.status == 'completed').toList();
        _courses = courses;
        _isLoading = false;
        _error = '';
        _expanded.updateAll((_, __) => false);
      });

      _initializeAnimations();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExam(int examID) async {
    try {
      await ApiService.deleteTeacherExam(examID, widget.userId);
      _fetchExams();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('امتحان با موفقیت حذف شد'),
            backgroundColor: Colors.green,
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
    }
  }

  void _showDeleteDialog(int exID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تمرین'),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید تمرین را حذف کنید؟',
          textDirection: TextDirection.rtl,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExam(exID);
            },
            child: Text(
              'حذف',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initializeAnimations() {
    final totalCount = _upcomingExams.length + _completedExams.length;
    _cardAnimations = List.generate(
      totalCount + 2,
      (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.06 + i * 0.04, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
    );
    _controller.forward(from: 0.0);
  }

  void _toggle(String key) {
    setState(() => _expanded[key] = !_expanded[key]!);
  }

  void _showAddExamDialog() {
    showAddEditExamDialog(
      context,
      exam: null,
      userId: widget.userId,
      onSuccess: _fetchExams,
      isAdd: true,
      courses: _courses,
    );
  }

  void _showEditExamDialog(ExamModelT exam) {
    // Convert ExamModelT to Map for the dialog
    final examMap = {
      'id': exam.id,
      'title': exam.title,
      'description': '',
      'date': exam.date,
      'classTime': exam.classTime,
      'duration': exam.duration,
      'possibleScore': exam.possibleScore,
      'courseId': exam.id,
    };

    showAddEditExamDialog(
      context,
      exam: examMap,
      userId: widget.userId,
      onSuccess: _fetchExams,
      isAdd: false,
      courses: _courses,
    );
  }

  // Update your build method to use these methods properly
  // In the ExamTeacherSection, update the onEdit callback:

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchExams,
        color: AppColor.purple,
        child: _isLoading
            ? _buildShimmer()
            : _error.isNotEmpty
            ? _buildError()
            : _buildSuccess(),
      ),
    );
  }

  // ... rest of your build methods remain the same, but update the ExamTeacherSection calls:

  Widget _buildSuccess() {
    if (_upcomingExams.isEmpty && _completedExams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 16),
            const Text(
              'امتحانی وجود ندارد',
              style: TextStyle(fontSize: 16, color: AppColor.lightGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddExamDialog,
              icon: const Icon(Icons.add),
              label: const Text('افزودن امتحان'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
            ),
          ],
        ),
      );
    }

    int cardIndex = 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: ResponsiveContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAnimatedWidget(
              index: 0,
              child: HeaderSection(onAdd: _showAddExamDialog),
            ),
            const SizedBox(height: 24),
            _buildAnimatedWidget(index: 1, child: const SectionDivider()),
            const SizedBox(height: 24),
            _buildAnimatedWidget(
              index: cardIndex++,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '${_upcomingExams.length}',
                      label: 'امتحانات پیش رو',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '${_completedExams.length}',
                      label: 'امتحانات برگزار شده',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ExamTeacherSection(
              title: 'پیش رو',
              color: Colors.orange,
              items: _upcomingExams,
              startIndex: cardIndex,
              sectionKey: 'upcoming',
              isExpanded: _expanded['upcoming']!,
              onToggle: () => _toggle('upcoming'),
              animations: _cardAnimations,
              onDelete: (exam) => _showDeleteDialog(exam.id),
              onEdit: (exam) => _showEditExamDialog(exam),
              isActive: true,
            ),
            const SizedBox(height: 24),
            ExamTeacherSection(
              title: 'برگزار شده',
              color: Colors.green,
              items: _completedExams,
              startIndex: cardIndex + _upcomingExams.length,
              sectionKey: 'completed',
              isExpanded: _expanded['completed']!,
              onToggle: () => _toggle('completed'),
              animations: _cardAnimations,
              onDelete: (exam) => _showDeleteDialog(exam.id),
              onEdit: (exam) => _showEditExamDialog(exam),
              isActive: false,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedWidget({required int index, required Widget child}) {
    if (_cardAnimations.isEmpty || index >= _cardAnimations.length) {
      return child;
    }

    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, _) {
        final value = _cardAnimations[index].value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: ResponsiveContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey[100]!,
              highlightColor: Colors.grey[300]!,
              child: Container(height: 100, color: Colors.white),
            ),
            const SizedBox(height: 24),
            ...List.generate(3, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[100]!,
                  highlightColor: Colors.grey[300]!,
                  child: Container(height: 180, color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text('خطا در بارگذاری امتحانات'),
          const SizedBox(height: 8),
          Text(_error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchExams,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          ),
        ],
      ),
    );
  }
}
