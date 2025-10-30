import 'package:flutter/material.dart';

import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../commons/untils.dart' as NumberUtils;

class Dashboard extends StatelessWidget {
  final Role role;
  final String userName;

  const Dashboard({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: role.gradient.first.withOpacity(0.2),
          child: Text(
            userName.isNotEmpty ? userName[0] : 'أ',
            style: TextStyle(color: role.gradient.first, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'سلام، $userName',
          style: const TextStyle(color: AppColor.darkText, fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColor.purple),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildBody(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (role) {
      case Role.student:
        return _buildStudentView();
      case Role.teacher:
        return _buildTeacherView();
      case Role.admin:
        return _buildAdminView();
    }
  }

  // ────────────────────── STUDENT VIEW ──────────────────────
  Widget _buildStudentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(),
        const SizedBox(height: 24),
        _buildSectionTitle('اخبار و رویدادها'),
        _buildNewsCard(),
        const SizedBox(height: 16),
        _buildSectionTitle('پیشرفت دروس'),
        _buildProgressList(),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('۱۳', 'تکلیف امروز', const Color(0xFFFF6B35))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('۳', 'امتحانات', const Color(0xFF4A90E2))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('۵', 'پیام', const Color(0xFF50C878))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('۹۲', 'حضور', const Color(0xFF9B59B6))),
      ],
    );
  }

  // ────────────────────── TEACHER VIEW ──────────────────────
  Widget _buildTeacherView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(),
        const SizedBox(height: 24),
        _buildSectionTitle('امتحانات معلم'),
        _buildExamCard('امتحانات معلم', '۲۵ آبان ۱۴۰۴'),
        const SizedBox(height: 16),
        _buildSectionTitle('تعطیلات نیمسال'),
        _buildHolidayCard('تعطیلات نیمسال', '۱ تا ۱۴ آذر'),
        const SizedBox(height: 16),
        _buildSectionTitle('پیشرفت دروس'),
        _buildTeacherProgress(),
      ],
    );
  }

  // ────────────────────── ADMIN VIEW ──────────────────────
  Widget _buildAdminView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatsRow(),
        const SizedBox(height: 24),
        _buildSectionTitle('اخبار و رویدادها'),
        _buildNewsCard(),
        const SizedBox(height: 16),
        _buildSectionTitle('تعطیلات و امتحانات'),
        _buildExamCard('امتحانات معلم', '۲۵ آبان ۱۴۰۴'),
        const SizedBox(height: 16),
        _buildHolidayCard('تعطیلات نیمسال', '۱ تا ۱۴ آذر'),
      ],
    );
  }

  // ────────────────────── REUSABLE WIDGETS ──────────────────────
  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            NumberUtils.replaceFarsiNumber(value), // Ensure Persian digits
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.darkText)),
    );
  }

  Widget _buildNewsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [Icon(Icons.campaign, color: AppColor.purple), SizedBox(width: 8), Text('اخبار')]),
          const SizedBox(height: 8),
          const Text('آغاز ثبت‌نام ترم بهار', style: TextStyle(fontWeight: FontWeight.w500)),
          const Text('۲۰ آبان ۱۴۰۴'),
        ],
      ),
    );
  }

  Widget _buildExamCard(String title, String date) {
    return _buildCard(
      child: Row(
        children: [
          const Icon(Icons.assignment, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(date, style: const TextStyle(color: AppColor.lightGray)),
        ],
      ),
    );
  }

  Widget _buildHolidayCard(String title, String date) {
    return _buildCard(
      child: Row(
        children: [
          const Icon(Icons.event, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(date, style: const TextStyle(color: AppColor.lightGray)),
        ],
      ),
    );
  }

  Widget _buildProgressList() {
    return Column(
      children: [
        _buildProgressItem('ریاضی', '۹۲٪', '+۸', Colors.green),
        _buildProgressItem('شیمی', '۸۸٪', '-۸', Colors.red),
        _buildProgressItem('تاریخ جهان', '۸۵٪', '+۸', Colors.green),
        _buildProgressItem('علوم کامپیوتر', '۹۴٪', 'A', Colors.blue),
      ],
    );
  }

  Widget _buildTeacherProgress() {
    return Column(
      children: [
        _buildProgressItem('ریاضی ۱', '۹۲٪', 'A', Colors.blue),
        _buildProgressItem('ریاضی ۲', '۸۸٪', '-۸', Colors.red),
      ],
    );
  }

  Widget _buildProgressItem(String subject, String percent, String change, Color color) {
    return _buildCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 12,
            child: Text(
              change,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: NumberUtils.parsePersianPercent(percent) / 100,
                  backgroundColor: Colors.grey[300],
                  color: color,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            NumberUtils.replaceFarsiNumber(percent), // Show Persian digits
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColor.purple,
      unselectedItemColor: Colors.grey,
      currentIndex: 4,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'پروفایل'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'آمار'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'امتحانات'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'پیام‌ها'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
      ],
      onTap: (index) {},
    );
  }
}