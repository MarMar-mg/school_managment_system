// features/profile/presentations/pages/about_page.dart
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_bar.dart';

class AboutPage extends StatelessWidget {
   AboutPage({super.key});

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'ما کی هستیم؟',
      'content':
      'اپلیکیشن سامانه مدیریت مدرسه، پلتفرمی هوشمند و کاربرپسند است که با هدف ساده‌سازی ارتباط بین مدرسه، معلمان، دانش‌آموزان و اولیا طراحی شده است. ما به دنبال ایجاد تجربه‌ای شفاف، سریع و امن برای همه کاربران هستیم.',
      'icon': Icons.school_rounded,
    },
    // {
    //   'title': 'مأموریت ما',
    //   'content':
    //   'کمک به مدارس برای مدیریت بهتر فرآیندهای آموزشی، کاهش کارهای اداری تکراری، افزایش تعامل والدین با مدرسه و ارائه ابزارهای لازم برای موفقیت تحصیلی دانش‌آموزان — همه در یک اپلیکیشن یکپارچه.',
    //   'icon': Icons.emoji_events_rounded,
    // },
    {
      'title': 'چشم‌انداز آینده',
      'content':
      'ما می‌خواهیم به بزرگ‌ترین و قابل‌اعتمادترین همراه دیجیتال خانواده‌های ایرانی در مسیر آموزش فرزندانشان تبدیل شویم و با استفاده از فناوری‌های نوین، آموزش را هوشمندتر، عادلانه‌تر و در دسترس‌تر کنیم.',
      'icon': Icons.visibility_rounded,
    },
    {
      'title': 'ارزش‌های اصلی ما',
      'content':
      '• شفافیت و صداقت در ارائه اطلاعات\n'
          '• امنیت و حفاظت از داده‌های کاربران\n'
          '• سادگی و راحتی استفاده برای همه سنین\n'
          '• پشتیبانی سریع و همدلانه\n'
          '• به‌روزرسانی مداوم با توجه به نیازهای واقعی مدارس',
      'icon': Icons.favorite_rounded,
    },
    {
      'title': 'تیم ما',
      'content':
      'گروهی از توسعه‌دهندگان، طراحان، متخصصان آموزشی و مشاوران با تجربه که عاشق آموزش و فناوری هستند. ما با عشق و تعهد این محصول را می‌سازیم تا تجربه‌ای متفاوت برای شما رقم بزنیم.',
      'icon': Icons.group_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
      title: 'درباره ما',
      bottomRadius: 5.0,           // smaller curve
      gradientColors: [
        AppColor.purple,
        AppColor.purple.withOpacity(0.85),
        AppColor.purple.withOpacity(0.7),
      ],
    ),
      body: ResponsiveContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: AnimationLimiter(
          child: ListView(
            children: [
              // Hero / Welcome Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: AppColor.purple.withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'خوش آمدید به سامانه مدیریت مدرسه',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'همراه هوشمند شما در مسیر آموزش بهتر',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Sections
              ...List.generate(
                _sections.length,
                    (index) => AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 60.0,
                    child: FadeInAnimation(
                      child: _buildInfoCard(
                        title: _sections[index]['title'],
                        content: _sections[index]['content'],
                        icon: _sections[index]['icon'],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Contact / Call to action
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: AppColor.gray.withOpacity(0.01),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'با ما در ارتباط باشید',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'هرگونه پیشنهاد، انتقاد یا سؤال دارید؟\nخوشحال می‌شویم صدای شما را بشنویم.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final Uri emailUri = Uri(
                            scheme: 'mailto',
                            path: 'maghsoodiimaryam@gmail.com',           // ← change to your real support email
                            queryParameters: {
                              'subject': 'پیشنهاد / انتقاد / سؤال از اپلیکیشن مدیریت مدرسه',
                              'body': 'سلام تیم پشتیبانی،\n\n'
                                  'نام من: [نام خود را وارد کنید]\n'
                                  'شماره دانش‌آموزی / کد معلم: [در صورت وجود]\n'
                                  'نسخه اپ: ۱.۰\n'
                                  'سیستم عامل: [اندروید / iOS]\n\n'
                                  'پیام من:\n'
                                  '------------------------------------\n\n',
                            },
                          );

                          try {
                            if (await canLaunchUrl(emailUri)) {
                              await launchUrl(
                                emailUri,
                                mode: LaunchMode.externalApplication, // preferred for mailto
                              );
                            } else {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('برنامه ایمیل نصب نیست یا قابل دسترسی نمی‌باشد'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('خطا در باز کردن ایمیل: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.mail_outline_rounded),
                        label: const Text('maghsoodimaryam@gmail.com'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColor.purple, width: 1.5),
                          foregroundColor: AppColor.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () async {
                          // Define your support phone number here (with country code recommended)
                          const String phoneNumber = '+989381955375'; // ← CHANGE THIS to your real number
                          // Example Iranian format: +98 followed by 10 digits without 0

                          final Uri telUri = Uri(
                            scheme: 'tel',
                            path: phoneNumber,
                          );

                          try {
                            if (await canLaunchUrl(telUri)) {
                              await launchUrl(
                                telUri,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('برنامه تلفن روی دستگاه شما در دسترس نیست'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('خطا در باز کردن شماره: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.phone_rounded),
                        label: const Text('+989381955375'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColor.purple, width: 1.5),
                          foregroundColor: AppColor.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: Text(
                  'نسخه ۱.۰ • © ۱۴۰۴ – ۱۴۰۵ • با عشق ساخته شده برای آموزش بهتر',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.purple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColor.purple, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}