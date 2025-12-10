import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/applications/colors.dart';
import '../features/dashboard/presentation/pages/dashboard.dart';
import '../features/profile/presentations/pages/profile_page.dart';
import '../features/student/assignments/presentations/pages/assignments_page.dart';
import '../features/student/classes/presentations/pages/classes_page.dart';
import '../features/student/exam/presentations/pages/exam_page.dart';
import '../features/student/scores/presentations/pages/scores_page.dart';
import '../features/teacher/assignment_management/presentations/pages/assignment_management_page.dart';
import '../features/teacher/exam_management/presentations/pages/exam_management_page.dart';
import '../features/teacher/score_management/presentations/pages/score_management_page.dart';
import 'our_app_bar.dart';

class BottomNavBar extends StatefulWidget {
  final Role role;
  final String userName;
  final String userId;
  final int userIdi;

  const BottomNavBar({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
    required this.userIdi,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final List<Widget> targetStudent = <Widget>[
    Dashboard(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
    ),
    CoursesPage(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
      userIdi: widget.userIdi,
    ),
    AssignmentsPage(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userIdi,
    ),
    ExamPage(
      role: Role.student,
      userName: widget.userName,
      userId: widget.userIdi,
    ),
    MyScorePage(studentId: widget.userIdi),
    ProfilePage(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
    ),
  ];

  late final List<Widget> targetTeacher = <Widget>[
    Dashboard(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
    ),
    CoursesPage(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
      userIdi: widget.userIdi,
    ),
    AssignmentManagementPage(userId: widget.userIdi),
    ExamManagementPage(
      // Assuming parameters based on similar pages; adjust as needed
      role: widget.role,
      userName: widget.userName,
      userId: widget.userIdi,
    ),
    ScoreManagementPage(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userIdi,
    ),
    ProfilePage(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
    ),
  ];

  // Placeholder for manager pages; replace with actual implementations
  late final List<Widget> targetManager = <Widget>[
    Dashboard(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
    ),
    // Placeholder for Students page (e.g., from TeacherController getStudents or custom)
    const Center(
      child: Text('صفحه دانش‌آموزان', style: TextStyle(fontSize: 20)),
    ),
    // Placeholder for News page (e.g., from ApiService getNews)
    const Center(child: Text('صفحه اخبار', style: TextStyle(fontSize: 20))),
    // Placeholder for Events page (e.g., from ApiService getEvents)
    const Center(child: Text('صفحه رویدادها', style: TextStyle(fontSize: 20))),
    ProfilePage(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Determine the target pages based on role
    late List<Widget> targetPages;
    if (widget.role == Role.student) {
      targetPages = targetStudent;
    } else if (widget.role == Role.teacher) {
      targetPages = targetTeacher;
    } else {
      targetPages = targetManager;
    }

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: DashboardAppBar(role: widget.role, userId: widget.userIdi),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: targetPages[_selectedIndex]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              color: AppColor.lightGray,
              activeColor: AppColor.purple,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              duration: const Duration(milliseconds: 200),
              tabBackgroundColor: AppColor.purple.withOpacity(0.1),
              tabs: [
                const GButton(icon: Icons.home_rounded, text: 'خانه'),
                if (widget.role != Role.manager)
                  const GButton(icon: Icons.menu_book_sharp, text: 'کلاس ها'),
                if (widget.role != Role.manager)
                  const GButton(
                    icon: Icons.assignment_turned_in_outlined,
                    text: 'تمرینات',
                  ),
                if (widget.role != Role.manager)
                  const GButton(icon: Icons.edit_outlined, text: 'امتحانات'),
                const GButton(icon: Icons.bar_chart_rounded, text: 'نمرات'),
                if (widget.role == Role.manager)
                  const GButton(
                    icon: Icons.person_add_alt_outlined,
                    text: 'دانش آموزان',
                  ),
                if (widget.role == Role.manager)
                  const GButton(icon: Icons.newspaper, text: 'اخبار'),
                if (widget.role == Role.manager)
                  const GButton(
                    icon: Icons.calendar_today_outlined,
                    text: 'رویدادها',
                  ),
                const GButton(
                  icon: Icons.person_outline_rounded,
                  text: 'پروفایل',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
