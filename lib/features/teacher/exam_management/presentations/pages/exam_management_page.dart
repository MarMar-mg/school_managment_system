import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../dashboard/presentation/widgets/section_header_widget.dart';
import '../../data/models/exam_model.dart';
import '../widgets/completed_exam_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/upcoming_exam_card.dart';

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

  List<ExamModelT> exams = [];
  Future<void> _fetchExams() async {
    try {
      final fetchedExams = await ApiService.getTeacherExams(widget.userId);
      setState(() {
        exams = fetchedExams;
      });
    } catch (e) {
      // Handle error, e.g., show snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگیری امتحانات: $e')));
      // Fallback to hardcoded if needed, but remove for production
      setState(() {
        exams = [
          // Your existing hardcoded data as fallback
        ];
      });
    }
    _startAnimations();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fetchExams();
  }

  void _startAnimations() {
    _cardAnimations = List.generate(
      exams.length + 2,
      (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 + i * 0.08, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                              id: 0, // Will be set by backend
                              title: titleController.text,
                              status: 'upcoming',
                              subject: subjectController.text,
                              date: dateController.text,
                              students: 0,
                              classTime: timeController.text,
                              capacity: int.tryParse(capacityController.text) ?? 0,
                              duration: int.tryParse(durationController.text) ?? 0,
                              possibleScore: 20, // Hardcode or add field
                            ).toJson();

                            await ApiService.createExam(widget.userId, examData);
                            Navigator.pop(context);
                            _fetchExams(); // Refresh list
                            // Show success snackbar
                          } catch (e) {
                            // Show error
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
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
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

  @override
  Widget build(BuildContext context) {
    final upcomingExams = exams.where((e) => e.status == 'upcoming').toList();
    final completedExams = exams.where((e) => e.status == 'completed').toList();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchExams,
            color: AppColor.purple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (use a separate widget if needed, but simple here)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'مدیریت امتحانات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.darkText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ایجاد و مدیریت امتحان‌های کلاسی',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.lightGray,
                            ),
                          ),
                        ],
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
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'امتحان جدید',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Cards (updated to match image)
                  _buildAnimatedStatsCards(),
                  const SizedBox(height: 32),

                  // Upcoming Exams
                  if (upcomingExams.isNotEmpty) ...[
                    SectionHeader(title: 'امتحانات پیش رو', onSeeAll: () {}),
                    const SizedBox(height: 16),
                    ...upcomingExams.map(
                      (exam) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: UpcomingExamCard(exam: exam),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Completed Exams
                  if (completedExams.isNotEmpty) ...[
                    SectionHeader(
                      title: 'امتحانات برگزار شده',
                      onSeeAll: () {},
                    ),
                    const SizedBox(height: 16),
                    ...completedExams.map(
                      (exam) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CompletedExamCard(exam: exam),
                      ),
                    ),
                  ],

                  if (exams.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 80,
                              color: AppColor.lightGray,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'امتحانی وجود ندارد',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColor.lightGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatsCards() {
    return AnimatedBuilder(
      animation: _cardAnimations.isNotEmpty
          ? _cardAnimations[0]
          : AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        final value = _cardAnimations.isNotEmpty
            ? _cardAnimations[0].value
            : 1.0;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 80 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              value: '0',
              label: 'سوالات',
              color: AppColor.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              value: '2',
              label: 'امتحانات باقی مانده',
              color: AppColor.purple,
            ),
          ),
        ],
      ),
    );
  }
}
