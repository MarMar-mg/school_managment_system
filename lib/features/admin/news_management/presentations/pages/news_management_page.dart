import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/commons/widgets/loading_widget.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/commons/text_style.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../data/models/news_model.dart';
import '../widgets/add_edit_news_dialog.dart';
import '../widgets/news_card.dart';

class NewsManagementPage extends StatefulWidget {
  final Role role;

  const NewsManagementPage({super.key, required this.role});

  @override
  State<NewsManagementPage> createState() => _NewsManagementPageState();
}

class _NewsManagementPageState extends State<NewsManagementPage> {
  late Future<List<NewsModel>> _newsFuture;
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'عمومی',
    'آموزشی',
    'رویدادها',
    'اطلاعیه',
    'ورزشی',
    'فرهنگی',
    'اخبار مدرسه',
    'برنامه امتحانات',
    'دانش‌آموزی',
    'معلمی',
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
    setState(() {
      _newsFuture = ApiService.getAllNews();
    });
  }

  void _addNews() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddEditNewsDialog(isEdit: false),
    );
    if (result == true) _loadNews();
  }

  void _editNews(NewsModel news) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditNewsDialog(isEdit: true, news: news),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'خبر با موفقیت ویرایش شد',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadNews();
    }
  }

  void _deleteNews(int newsId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف خبر', textDirection: TextDirection.rtl),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این خبر را حذف کنید؟ این عملیات قابل بازگشت نیست.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading indicator
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('در حال حذف...')));

    final success = await ApiService().deleteNews(newsId);

    // Hide loading
    ScaffoldMessenger.of(context).clearSnackBars();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'خبر با موفقیت حذف شد',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadNews(); // Refresh the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در حذف خبر', textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<NewsModel> _getFilteredNews(List<NewsModel> allNews) {
    if (_selectedCategoryIndex == 0) return allNews; // "همه"
    final selectedCategory = _categories[_selectedCategoryIndex];
    return allNews.where((news) => news.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'اخبار و اطلاعیه‌ها',
                    style: defaultTextStyle(
                      context,
                      StyleText.bb1,
                    ).s(22).c(AppColor.purple),
                    textDirection: TextDirection.rtl,
                  ),
                  if (widget.role == Role.manager)
                    ElevatedButton.icon(
                      onPressed: _addNews,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('افزودن'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Category Tabs (Navbar at top)
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(_categories.length, (index) {
              final isSelected = index == _selectedCategoryIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _categories[index],
                      style: defaultTextStyle(context, StyleText.bb2)
                          .s(15)
                          .c(
                            isSelected
                                ? Colors.white
                                : AppColor.grey(true, 700),
                          ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 24),

        // News List (vertical)
        Expanded(
          child: FutureBuilder<List<NewsModel>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingWidget();
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'خطا در بارگذاری اخبار\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final allNews = snapshot.data ?? [];
              final filteredNews = _getFilteredNews(allNews);

              if (filteredNews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'هیچ خبری در این دسته وجود ندارد',
                        style: defaultTextStyle(
                          context,
                          StyleText.bb2,
                        ).s(16).c(AppColor.grey(true, 600)),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                );
              }

              return ResponsiveContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: ListView.builder(
                  itemCount: filteredNews.length,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final news = filteredNews[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NewsVerticalCard(
                        news: news,
                        onEdit: () => _editNews(news),
                        onDelete: () => _deleteNews(news.newsId),
                        role: widget.role, load: () => _loadNews(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
