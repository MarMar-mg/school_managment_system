import 'package:flutter/material.dart';

import '../../../../../applications/bottom_nav_bar.dart';
import '../../../../../applications/colors.dart';
import '../../../../../applications/our_app_bar.dart';
import '../../../../../applications/role.dart';

class CoursesPage extends StatefulWidget {
  final Role role;
  final String userName;

  const CoursesPage({
    Key? key,
    required this.role,
    required this.userName,
  }) : super(key: key);

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  int _selectedIndex = 2;

  // Sample data - Replace with API call
  final List<Map<String, dynamic>> _courses = [
    {
      'name': 'ریاضی ۲',
      'code': 'MATH 202',
      'teacher': 'استاد احمدی',
      'location': 'دوشنبه، چهارشنبه ۸-۱۰',
      'time': 'سه‌شنبه، پنج‌شنبه ۸-۱۰',
      'progress': 88,
      'grade': '-A',
      'color': AppColor.purple,
      'icon': Icons.calculate_rounded,
    },
    {
      'name': 'شیمی ۱',
      'code': 'CHEM 101',
      'teacher': 'دکتر محمدی',
      'location': 'آزمایشگاه ۱۰۴',
      'time': 'سه‌شنبه، پنج‌شنبه ۸-۱۰',
      'progress': 92,
      'grade': 'A',
      'color': Colors.blue,
      'icon': Icons.science_rounded,
    },
    {
      'name': 'فیزیک ۱',
      'code': 'PHYS 101',
      'teacher': 'استاد رضایی',
      'location': 'کلاس ۲۰۳',
      'time': 'یکشنبه، سه‌شنبه ۱۰-۱۲',
      'progress': 85,
      'grade': 'B',
      'color': Colors.orange,
      'icon': Icons.flash_on_rounded,
    },
  ];

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'ثبت‌نام شده',
                      '۶ کلاس',
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'میانگین نمرات',
                      'A-',
                      Icons.star_outline,
                      AppColor.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section Title
              const Text(
                'دروس من',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),

              const SizedBox(height: 16),

              // Course Cards
              ..._courses.map((course) => _buildCourseCard(course)).toList(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _selectedIndex,
      //   onTap: (index) {
      //     setState(() => _selectedIndex = index);
      //   },
      // ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.lightGray,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: course['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    course['icon'],
                    color: course['color'],
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              course['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.darkText,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: course['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course['grade'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: course['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['code'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColor.lightGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: Colors.grey[200],
            indent: 16,
            endIndent: 16,
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Teacher & Location Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.person_outline,
                        course['teacher'],
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.location_on_outlined,
                        course['location'],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Time
                _buildDetailItem(
                  Icons.schedule_outlined,
                  course['time'],
                ),

                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'پیشرفت درس',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.darkText,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          '${course['progress']}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: course['color'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: course['progress'] / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          course['color'],
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Button
                InkWell(
                  onTap: () {
                    // Navigate to course details
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: course['color'].withOpacity(0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مشاهده تمرین‌ها و امتحانات',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: course['color'],
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 14,
                          color: course['color'],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColor.lightGray,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}