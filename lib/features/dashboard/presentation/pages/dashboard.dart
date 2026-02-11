import 'package:flutter/material.dart';
import 'package:school_management_system/commons/untils.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../commons/responsive_container.dart';
import '../widgets/events_list_widget.dart';
import '../widgets/news_list_widget.dart';
import '../widgets/section_header_widget.dart';
import '../widgets/stats_grid.dart';
import '../widgets/combined_items_list.dart';
import '../widgets/progress_list.dart';

/// Main Dashboard with role-based content and smooth staggered animations
class Dashboard extends StatefulWidget {
  final Role role;
  final String userName;
  final String userId;

  const Dashboard({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _sectionAnims;

  @override
  void initState() {
    super.initState();

    // 1800ms total animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Create staggered animations for each section
    _sectionAnims = List.generate(6, (index) {
      final start = 0.15 + (index * 0.12); // 0.15, 0.27, 0.39...
      final end = (start + 0.4).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Start animation on load
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // ====================== STATS GRID ======================
              _buildAnimatedSection(
                index: 0,
                child: StatsGrid(
                  role: widget.role,
                  userId: widget.userId.toInt(),
                ),
              ),

              const SizedBox(height: 24),
              ResponsiveContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====================== ASSIGNMENTS & EXAMS (STUDENT ONLY) ======================
                    if (widget.role == Role.student) ...[
                      const SizedBox(height: 24),
                      _buildAnimatedSection(
                        index: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'تکالیف و امتحانات پیش رو',
                              onSeeAll: () {},
                              actionText: 'مشاهده همه',
                            ),
                            const SizedBox(height: 12),
                            CombinedItemsList(
                              studentId: widget.userId.toInt(),
                              onRefresh: () {
                                // Optional: Trigger any refresh logic
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ====================== PROGRESS SECTION ======================
                    _buildAnimatedSection(
                      index: widget.role == Role.student ? 4 : 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(title: 'پیشرفت دروس', onSeeAll: () {}),
                          const SizedBox(height: 12),
                          ProgressList(
                            role: widget.role,
                            userId: int.parse(widget.userId),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ====================== NEWS SECTION ======================
                    _buildAnimatedSection(
                      index: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(title: 'اخبار', onSeeAll: () {}),
                          const SizedBox(height: 12),
                          const NewsList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ====================== EVENTS SECTION ======================
                    _buildAnimatedSection(
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(title: 'رویدادها', onSeeAll: () {}),
                          const SizedBox(height: 12),
                          const EventsList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps any section with fade + slide-up animation
  Widget _buildAnimatedSection({required int index, required Widget child}) {
    final animation = _sectionAnims[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;
        return Transform.translate(
          offset: Offset(0, 80 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}
