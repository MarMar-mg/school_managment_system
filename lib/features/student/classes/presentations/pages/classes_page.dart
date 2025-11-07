import 'package:flutter/material.dart';
import '../../../../../applications/colors.dart';
import '../../../../../applications/our_app_bar.dart';
import '../../../../../applications/role.dart';
import '../../../../../core/services/api_service.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/course_card_widget.dart';

class CoursesPage extends StatefulWidget {
  final Role role;
  final String userName;
  final String userId;
  final int userIdi;

  const CoursesPage({
    Key? key,
    required this.role,
    required this.userName,
    required this.userId,
    required this.userIdi,
  }) : super(key: key);

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late Future<List<Map<String, dynamic>>> _coursesFuture;
  late Future<double> _averageFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _coursesFuture = ApiService.getCourses(widget.role, widget.userIdi);
    _averageFuture = ApiService.getAverageGrade(widget.role, widget.userIdi);
  }

  String _convertToGrade(double avg) {
    if (avg >= 18) return 'A';
    if (avg >= 16) return 'A-';
    if (avg >= 14) return 'B';
    if (avg >= 12) return 'B-';
    if (avg >= 10) return 'C';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      // appBar: DashboardAppBar(
      //   role: widget.role, userId: widget.userIdi,
      // ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _coursesFuture,
          builder: (context, snapshot) {
            // Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            // Error State
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            // Empty State
            final courses = snapshot.data ?? [];
            if (courses.isEmpty) {
              return _buildEmptyState();
            }

            // Success State
            return _buildSuccessState(courses);
          },
        ),
      ),
    );
  }

  // ==================== UI States ====================

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text(
        'خطا: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'دروسی یافت نشد',
        style: TextStyle(color: AppColor.lightGray),
      ),
    );
  }

  Widget _buildSuccessState(List<Map<String, dynamic>> courses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards Section
              _buildStatsSection(courses.length),

              const SizedBox(height: 24),

              // Section Title
              _buildSectionTitle(),

              const SizedBox(height: 16),

              // Courses List Section
              _buildCoursesList(courses),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Section Builders ====================

  Widget _buildStatsSection(int coursesCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive spacing
        final cardSpacing = constraints.maxWidth > 600 ? 16.0 : 12.0;

        return Row(
          children: [
            // Registered Courses Card
            Expanded(
              child: StatCardWidget(
                label: 'ثبت‌نام شده',
                value: '$coursesCount کلاس',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),

            SizedBox(width: cardSpacing),

            // Average Grade Card
            Expanded(
              child: FutureBuilder<double>(
                future: _averageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return StatCardWidget(
                      label: 'میانگین نمرات',
                      value: '...',
                      icon: Icons.star_outline,
                      color: AppColor.purple,
                    );
                  }

                  final avg = snapshot.data ?? 0.0;
                  final grade = _convertToGrade(avg);

                  return StatCardWidget(
                    label: 'میانگین نمرات',
                    value: '$avg($grade)',
                    icon: Icons.star_outline,
                    color: AppColor.purple,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle() {
    return const Text(
      'دروس من',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColor.darkText,
      ),
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildCoursesList(List<Map<String, dynamic>> courses) {
    return Column(
      children: courses
          .map((course) => CourseCardWidget(course: course))
          .toList(),
    );
  }
}