import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import '../../../../../core/services/api_service.dart';
import '../../data/models/exam_model.dart';
import '../../../../../commons/responsive_container.dart';
import '../widgets/exam_section.dart';
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

class _ExamManagementPageState extends State<ExamManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardAnimations;

  List<ExamModelT> _upcomingExams = [];
  List<ExamModelT> _completedExams = [];

  bool _isLoading = true;
  String _error = '';

  final Map<String, bool> _expanded = {
    'upcoming': false,
    'completed': false,
  };

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
      final exams = await ApiService.getTeacherExams(widget.userId);

      setState(() {
        _upcomingExams = exams.where((e) => e.status == 'upcoming').toList();
        _completedExams = exams.where((e) => e.status == 'completed').toList();
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

  void _initializeAnimations() {
    final totalCount = _upcomingExams.length + _completedExams.length;
    _cardAnimations = List.generate(
      totalCount + 2, // +2 for header and stats
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
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final durationController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColor.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'افزودن امتحان جدید',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: titleController,
                  label: 'عنوان امتحان',
                  hint: 'مثال: آزمون میانترم ریاضی',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: subjectController,
                  label: 'درس',
                  hint: 'مثال: ریاضی - بخش الف',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: dateController,
                  label: 'تاریخ',
                  hint: 'مثال: 20 آبان 1403',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: timeController,
                        label: 'ساعت',
                        hint: '9:00 صبح',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: durationController,
                        label: 'مدت (دقیقه)',
                        hint: '90',
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: capacityController,
                  label: 'ظرفیت',
                  hint: '100',
                  isNumber: true,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.lightGray,
                          foregroundColor: AppColor.darkText,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('انصراف'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final examData = ExamModelT(
                              id: 0,
                              title: titleController.text,
                              status: 'upcoming',
                              subject: subjectController.text,
                              date: dateController.text,
                              students: 0,
                              classTime: timeController.text,
                              capacity: int.tryParse(capacityController.text) ?? 0,
                              duration: int.tryParse(durationController.text) ?? 0,
                              possibleScore: 20,
                            ).toJson();

                            await ApiService.createExam(widget.userId, examData);
                            Navigator.pop(context);
                            _fetchExams();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('خطا: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('ایجاد'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColor.lightGray,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: AppColor.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColor.purple, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
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

  Widget _buildSuccess() {
    if (_upcomingExams.isEmpty && _completedExams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: AppColor.lightGray),
            const SizedBox(height: 16),
            const Text('امتحانی وجود ندارد', style: TextStyle(fontSize: 16, color: AppColor.lightGray)),
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

            // Header with Add Button
            _buildAnimatedWidget(
              index: cardIndex++,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مدیریت امتحانات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkText,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddExamDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.purple, Colors.deepPurple],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'جدید',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
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

            // Upcoming Exams Section
            ExamTeacherSection(
              title: 'پیش رو',
              color: Colors.orange,
              items: _upcomingExams,
              startIndex: cardIndex,
              sectionKey: 'upcoming',
              isExpanded: _expanded['upcoming']!,
              onToggle: () => _toggle('upcoming'),
              animations: _cardAnimations,
            ),
            const SizedBox(height: 24),

            // Completed Exams Section
            ExamTeacherSection(
              title: 'برگزار شده',
              color: Colors.green,
              items: _completedExams,
              startIndex: cardIndex + _upcomingExams.length,
              sectionKey: 'completed',
              isExpanded: _expanded['completed']!,
              onToggle: () => _toggle('completed'),
              animations: _cardAnimations,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}