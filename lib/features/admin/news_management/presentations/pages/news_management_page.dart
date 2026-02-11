import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/commons/widgets/loading_widget.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/commons/text_style.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../data/models/news_model.dart';
import '../widgets/add_edit_news_dialog.dart';

class NewsManagementPage extends StatefulWidget {
  final Role role;

  const NewsManagementPage({super.key, required this.role});

  @override
  State<NewsManagementPage> createState() => _NewsManagementPageState();
}

class _NewsManagementPageState extends State<NewsManagementPage> {
  List<NewsModel> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final news = await ApiService.getAllNews();
      setState(() {
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بارگیری اخبار: $e')));
    }
  }

  Future<void> _addNews() async {
    if (widget.role != Role.manager) return;  // Only managers can add
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditNewsDialog(isEdit: false, role: widget.role),
    );
    if (result == true) {
      _fetchNews();
    }
  }

  void _showNewsDetails(BuildContext context, NewsModel news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          news.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textDirection: TextDirection.rtl,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Dates
              Row(
                children: [
                  Chip(
                    label: Text(news.category),
                    backgroundColor: AppColor.purple.withOpacity(0.1),
                  ),
                  const Spacer(),
                  Text(
                    '${news.startDate} - ${news.endDate}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Image (if exists)
              if (news.image != null && news.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // child: CircleAvatar(backgroundImage: NetworkImage(news.image!))
                  child: Image.network(
                    news.image!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Description
              Text(
                'توضیحات:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                news.description?.trim().isNotEmpty == true
                    ? news.description!
                    : 'این خبر توضیحات بیشتری ندارد.',
                style: const TextStyle(fontSize: 15, height: 1.5),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
          if (widget.role == Role.manager)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editNews(news);
              },
              child: const Text('ویرایش'),
            ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 16, 16),
      ),
    );
  }

  void _editNews(NewsModel news) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditNewsDialog(
        isEdit: true,
        news: news,
        role: widget.role,
      ),
    );

    if (result == true) {
      _fetchNews(); // refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Scaffold(
        appBar: AppBar(
          title: Text('مدیریت اخبار', style: defaultTextStyle(context, StyleText.bb1).c(Colors.white)),
          backgroundColor: AppColor.adminBaseColor,
          actions: widget.role == Role.manager
              ? [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _addNews,
            ),
          ]
              : null,
        ),
        body: _isLoading
            ? LoadingWidget()
            : RefreshIndicator(
          onRefresh: _fetchNews,
          child: ListView.builder(
            itemCount: _news.length,
            itemBuilder: (context, index) {
              final newsItem = _news[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    _showNewsDetails(context, newsItem);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: newsItem.image != null && newsItem.image!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CircleAvatar(backgroundImage: NetworkImage(newsItem.image!))
                    )
                        : const Icon(Icons.newspaper, size: 50, color: AppColor.purple),
                    title: Text(
                      newsItem.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${newsItem.category} • ${newsItem.startDate} تا ${newsItem.endDate}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          newsItem.description ?? 'بدون توضیحات',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: widget.role == Role.manager
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editNews(newsItem),
                        ),
                        // delete button if you have it
                      ],
                    )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}