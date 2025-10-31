import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../applications/our_app_bar.dart';
import '../../../../applications/bottom_nav_bar.dart';
import '../widgets/stats_grid.dart';
import '../widgets/section_header_widget.dart';
import '../widgets/news_list_widget.dart';
import '../widgets/events_list_widget.dart';
import '../widgets/assignments_list.dart';
import '../widgets/progress_list.dart';
import '../models/dashboard_models.dart';

class Dashboard extends StatefulWidget {
  final Role role;
  final String userName;
  final String userId;

  const Dashboard({
    super.key,
    required this.role,
    required this.userName, required this.userId,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: DashboardAppBar(
        userName: widget.userName,
        role: widget.role,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              StatsGrid(role: widget.role),

              const SizedBox(height: 24),

              // News Section
              SectionHeader(
                title: 'اخبار و رویدادها',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              NewsList(newsItems: DashboardData.getNews()),

              const SizedBox(height: 24),

              // Events Section
              SectionHeader(
                title: 'رویدادها',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              EventsList(eventItems: DashboardData.getEvents()),

              // Assignments Section (Student Only)
              if (widget.role == Role.student) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'تکالیف پیش رو',
                  onSeeAll: () {},
                  actionText: 'مشاهده همه',
                ),
                const SizedBox(height: 12),
                AssignmentsList(
                  assignments: DashboardData.getAssignments(),
                ),
              ],

              const SizedBox(height: 24),

              // Progress Section
              SectionHeader(
                title: 'پیشرفت دروس',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              ProgressList(
                progressItems: DashboardData.getProgress(),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}