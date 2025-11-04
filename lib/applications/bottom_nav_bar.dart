// import 'package:flutter/material.dart';
// import '../../../../applications/colors.dart';
//
// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//
//   const BottomNavBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 icon: Icons.person_outline_rounded,
//                 label: 'پروفایل',
//                 index: 0,
//               ),
//               _buildNavItem(
//                 icon: Icons.bar_chart_rounded,
//                 label: 'آمار',
//                 index: 1,
//               ),
//               _buildNavItem(
//                 icon: Icons.assignment_outlined,
//                 label: 'امتحانات',
//                 index: 2,
//               ),
//               _buildNavItem(
//                 icon: Icons.message_outlined,
//                 label: 'پیام‌ها',
//                 index: 3,
//               ),
//               _buildNavItem(
//                 icon: Icons.home_rounded,
//                 label: 'خانه',
//                 index: 4,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = currentIndex == index;
//
//     return GestureDetector(
//       onTap: () => onTap(index),
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColor.purple.withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? AppColor.purple : AppColor.lightGray,
//               size: 24,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: isSelected ? AppColor.purple : AppColor.lightGray,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//               textDirection: TextDirection.rtl,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    _selectedIndex = widget.currentIndex;
    return Container(
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
            color: Colors.grey[800], // unselected icon color
            activeColor: Colors.purple,
            // activeColor: Colors.black,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            duration: Duration(milliseconds: 200),
            tabBackgroundColor: Colors.purple.withOpacity(0.1),
            // color: Colors.black,
            tabs: [
              GButton(
                icon: Icons.home_rounded,
                text: 'خانه',
              ),
              GButton(
                icon: Icons.bar_chart_rounded,
                text: 'آمار',
              ),
              GButton(
                icon: Icons.assignment_outlined,
                text: 'امتحانات',
              ),
              GButton(
                icon: Icons.message_outlined,
                text: 'پیام‌ها',
              ),
              GButton(
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
    );
  }
}