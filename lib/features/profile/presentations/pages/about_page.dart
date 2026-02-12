// features/profile/presentations/pages/about_page.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/responsive_container.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درباره ما'),
        centerTitle: true,
        backgroundColor: AppColor.purple,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColor.purple.withOpacity(0.1),
                child: Icon(
                  Icons.school,
                  size: 80,
                  color: AppColor.purple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'سامانه مدیریت مدرسه',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.purple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'نسخه ۱.۰.۰',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoRow(Icons.calendar_today, 'سال تحصیلی ۱۴۰۴-۱۴۰۵'),
              _buildInfoRow(Icons.location_on, 'طراحی شده برای مدارس ایران'),
              _buildInfoRow(Icons.code, 'توسعه با Flutter & .NET Core'),
              const SizedBox(height: 32),
              const Text(
                'ما در تلاش هستیم تا مدیریت آموزشی را ساده‌تر، سریع‌تر و هوشمندتر کنیم.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.6),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: () {
                  // You can open website, email, etc.
                },
                icon: const Icon(Icons.language),
                label: const Text('وب‌سایت رسمی'),
                style: OutlinedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  side: BorderSide(color: AppColor.purple),
                  foregroundColor: AppColor.purple,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '© ۱۴۰۴ - تمامی حقوق محفوظ است',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColor.purple, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}