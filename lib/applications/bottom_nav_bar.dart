import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/commons/untils.dart';
import '../features/dashboard/presentation/pages/dashboard.dart';
import '../features/profile/presentations/pages/profile_page.dart';
import '../features/student/assignments/presentations/pages/assignments_page.dart';
import '../features/student/classes/presentations/pages/classes_page.dart';
import '../features/student/exam/presentations/pages/exam_page.dart';
import '../features/student/scores/presentations/pages/scores_page.dart';
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
  late final target = <Widget>[
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
      userId: widget.userId.toInt(),
    ),
    ExamPage(
      role: Role.student,
      userName: widget.userName,
      userId: widget.userId.toInt(),
    ),
    MyScorePage(studentId: widget.userIdi),
    ProfilePage(
      role: widget.role,
      userName: widget.userName,
      userId: widget.userId,
    ),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DashboardAppBar(role: widget.role, userId: widget.userIdi),
      body: Center(child: target[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
              color: Colors.grey[800],
              // unselected icon color
              activeColor: Colors.purple,
              // activeColor: Colors.black,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              duration: Duration(milliseconds: 200),
              tabBackgroundColor: Colors.purple.withOpacity(0.1),
              // color: Colors.black,
              tabs: [
                GButton(icon: Icons.home_rounded, text: 'خانه'),
                if (widget.role != Role.manager)
                  GButton(icon: Icons.menu_book_sharp, text: 'کلاس ها'),
                if (widget.role != Role.manager)
                  GButton(
                    icon: Icons.assignment_turned_in_outlined,
                    text: 'تمربنات',
                  ),
                if (widget.role != Role.manager)
                  GButton(icon: Icons.edit_outlined, text: 'امتحانات'),
                GButton(icon: Icons.bar_chart_rounded, text: 'نمرات'),
                // GButton(icon: Icons.message_outlined, text: 'پیام‌ها'),
                if (widget.role == Role.manager)
                  GButton(
                    icon: Icons.person_add_alt_outlined,
                    text: 'دانش آموزان',
                  ),
                if (widget.role == Role.manager)
                  GButton(icon: Icons.newspaper, text: 'اخبار'),
                if (widget.role == Role.manager)
                  GButton(
                    icon: Icons.calendar_today_outlined,
                    text: 'رویدادها',
                  ),
                GButton(icon: Icons.person_outline_rounded, text: 'پروفایل'),
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
