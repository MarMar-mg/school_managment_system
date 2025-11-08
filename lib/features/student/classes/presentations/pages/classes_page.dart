import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../applications/colors.dart';
import '../../../../../applications/role.dart';
import '../../../../../core/services/api_service.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/course_card_widget.dart';

/// Fully animated Courses page with shimmer loading, pull-to-refresh,
/// responsive stats, and beautiful staggered course card entrance.
class CoursesPage extends StatefulWidget {
  final Role role;
  final String userName;
  final String userId;
  final int userIdi;

  const CoursesPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
    required this.userIdi,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage>
    with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _coursesFuture;
  late Future<double> _averageFuture;

  late AnimationController _controller;
  late List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _loadData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _cardAnims = [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _coursesFuture = ApiService.getCourses(widget.role, widget.userIdi);
      _averageFuture = ApiService.getAverageGrade(widget.role, widget.userIdi);
    });
  }

  void _startAnimations(int itemCount) {
    _cardAnims = List.generate(
      itemCount + 2, // +2 for stats cards
          (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 + i * 0.1, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
    );
    _controller.forward(from: 0.0);
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColor.purple,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _coursesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerState();
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              final courses = snapshot.data ?? [];
              if (courses.isEmpty) {
                return _buildEmptyState();
              }

              // Start animation only once
              if (_cardAnims.isEmpty) {
                _startAnimations(courses.length);
              }

              return _buildSuccessState(courses);
            },
          ),
        ),
      ),
    );
  }

  // ==================== STATES ====================

  Widget _buildShimmerState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerStats(),
              const SizedBox(height: 24),
              _buildShimmerTitle(),
              const SizedBox(height: 16),
              ...List.generate(4, (_) => const _ShimmerCourseCard())
                  .map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: card,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگذاری',
            style: TextStyle(fontSize: 18, color: AppColor.darkText),
            textDirection: TextDirection.rtl,
          ),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: AppColor.lightGray),
          const SizedBox(height: 16),
          Text(
            'دروسی یافت نشد',
            style: TextStyle(fontSize: 18, color: AppColor.lightGray),
          ),
        ],
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
              // Animated Stats
              AnimatedStatRow(
                coursesCount: courses.length,
                averageFuture: _averageFuture,
                animation: _cardAnims[0],
                convertToGrade: _convertToGrade,
              ),

              const SizedBox(height: 24),

              // Title
              AnimatedSectionTitle(animation: _cardAnims[1]),

              const SizedBox(height: 16),

              // Courses
              ...courses.asMap().entries.map((entry) {
                final index = entry.key + 2;
                return AnimatedCourseCard(
                  course: entry.value,
                  animation: _cardAnims[index],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SHIMMER WIDGETS ====================

  Widget _buildShimmerStats() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Row(
        children: [
          Expanded(child: Container(height: 100, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 100, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildShimmerTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(width: 120, height: 28, color: Colors.white),
    );
  }
}

class _ShimmerCourseCard extends StatelessWidget {
  const _ShimmerCourseCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// ==================== ANIMATED COMPONENTS ====================

class AnimatedStatRow extends StatelessWidget {
  final int coursesCount;
  final Future<double> averageFuture;
  final Animation<double> animation;
  final String Function(double) convertToGrade;

  const AnimatedStatRow({
    super.key,
    required this.coursesCount,
    required this.averageFuture,
    required this.animation,
    required this.convertToGrade,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = constraints.maxWidth > 600 ? 16.0 : 12.0;
          return Row(
            children: [
              Expanded(
                child: StatCardWidget(
                  label: 'ثبت‌نام شده',
                  value: '$coursesCount کلاس',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: FutureBuilder<double>(
                  future: averageFuture,
                  builder: (context, snapshot) {
                    final avg = snapshot.data ?? 0.0;
                    final grade = convertToGrade(avg);
                    return StatCardWidget(
                      label: 'میانگین نمرات',
                      value: snapshot.connectionState == ConnectionState.waiting
                          ? '...'
                          : '${avg.toStringAsFixed(1)}($grade)',
                      icon: Icons.star_outline,
                      color: AppColor.purple,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AnimatedSectionTitle extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedSectionTitle({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: const Text(
        'دروس من',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColor.darkText,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

class AnimatedCourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final Animation<double> animation;

  const AnimatedCourseCard({
    super.key,
    required this.course,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 60 * (1 - value)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        );
      },
      child: CourseCardWidget(course: course),
    );
  }
}