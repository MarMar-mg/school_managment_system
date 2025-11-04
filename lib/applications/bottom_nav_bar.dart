import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:school_managment_system/applications/role.dart';
import '../features/dashboard/presentation/pages/dashboard.dart';
import '../features/student/classes/presentations/pages/classes_page.dart';

class BottomNavBar extends StatefulWidget {
  final Role role;
  final String userName;
  final String userId;

  const BottomNavBar({
    Key? key,
    required this.role,
    required this.userName,
    required this.userId,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final target = <Widget>[
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
    CoursesPage(role: widget.role, userName: widget.userName),
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
    Dashboard(role: widget.role, userName: widget.userName, userId: widget.userId,),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              duration: Duration(milliseconds: 200),
              tabBackgroundColor: Colors.purple.withOpacity(0.1),
              // color: Colors.black,
              tabs: [
                GButton(icon: Icons.home_rounded, text: 'خانه'),
                GButton(icon: Icons.bar_chart_rounded, text: 'آمار'),
                GButton(icon: Icons.assignment_outlined, text: 'امتحانات'),
                GButton(icon: Icons.assignment_outlined, text: 'تمربنات'),
                GButton(icon: Icons.message_outlined, text: 'پیام‌ها'),
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
