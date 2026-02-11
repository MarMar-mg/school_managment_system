import 'package:flutter/material.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../data/models/news_model.dart';
import '../../../../../applications/role.dart';
import 'add_edit_news_dialog.dart';

class NewsDetailDialog extends StatelessWidget {
  final NewsModel news;
  final Role role;
  final VoidCallback? onNewsChanged; // ← callback to refresh parent list

  const NewsDetailDialog({
    super.key,
    required this.news,
    required this.role,
    this.onNewsChanged, // optional, but very useful
  });

  void _editNews(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEditNewsDialog(isEdit: true, news: news),
    ).then((result) {
      // If edit was successful (returned true), refresh parent
      if (result == true && onNewsChanged != null) {
        onNewsChanged!();
      }
    });
  }

  void _deleteNews(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف خبر', textDirection: TextDirection.rtl),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این خبر را حذف کنید؟',
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

    final success = await ApiService().deleteNews(news.newsId);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'خبر با موفقیت حذف شد',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // close detail dialog
      if (onNewsChanged != null) {
        onNewsChanged!(); // refresh parent list
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در حذف خبر', textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Image
            if (news.image != null && news.image!.trim().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(),
                child: Image.network(
                  ApiService.getImageFullUrl(news.image!.trim()),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print(
                      "Detail image failed: ${ApiService.getImageFullUrl(news.image)} → $error",
                    );
                    return Container(
                      height: 220,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 80),
                    );
                  },
                ),
              ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          'از ${news.startDate} تا ${news.endDate}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 15,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (news.description != null &&
                        news.description!.trim().isNotEmpty)
                      Text(
                        news.description!.trim(),
                        style: const TextStyle(fontSize: 16, height: 1.6),
                        textDirection: TextDirection.rtl,
                      )
                    else
                      const Text(
                        'توضیحاتی ثبت نشده است.',
                        style: TextStyle(color: Colors.grey),
                        textDirection: TextDirection.rtl,
                      ),

                    // Manager actions
                    if (role == Role.manager) ...[
                      const SizedBox(height: 32),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     ElevatedButton.icon(
                      //       onPressed: () => _editNews(context),
                      //       icon: const Icon(Icons.edit),
                      //       label: const Text('ویرایش خبر'),
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.blue,
                      //         foregroundColor: Colors.white,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 16),
                      //     ElevatedButton.icon(
                      //       onPressed: () => _deleteNews(context),
                      //       icon: const Icon(Icons.delete),
                      //       label: const Text('حذف خبر'),
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.red,
                      //         foregroundColor: Colors.white,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
