// features/profile/presentations/pages/privacy_page.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/responsive_container.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حریم خصوصی'),
        centerTitle: true,
        backgroundColor: AppColor.purple,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سیاست حفظ حریم خصوصی',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.purple,
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                title: 'اطلاعات جمع‌آوری شده',
                content:
                'ما اطلاعاتی مانند نام، نام کاربری، نقش کاربر (دانش‌آموز، معلم، مدیر)، نمرات، تکالیف و اخبار مرتبط با شما را جمع‌آوری می‌کنیم. این اطلاعات صرفاً برای ارائه خدمات آموزشی استفاده می‌شود.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'استفاده از اطلاعات',
                content:
                'اطلاعات شما برای مدیریت کلاس‌ها، ثبت نمرات، ارسال اعلان‌ها، نمایش برنامه امتحانات و ارتباط بین معلم و دانش‌آموز استفاده می‌شود. هیچ اطلاعات شخصی به اشخاص ثالث فروخته نمی‌شود.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'امنیت',
                content:
                'داده‌های شما با رمزنگاری در انتقال و ذخیره‌سازی محافظت می‌شوند. دسترسی به اطلاعات فقط برای کاربران مجاز سیستم امکان‌پذیر است.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'تغییرات در سیاست حریم خصوصی',
                content:
                'هرگونه تغییر در این سیاست از طریق همین صفحه اطلاع‌رسانی خواهد شد.',
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'نسخه ۱.۰ - آخرین به‌روزرسانی: بهمن ۱۴۰۴',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}