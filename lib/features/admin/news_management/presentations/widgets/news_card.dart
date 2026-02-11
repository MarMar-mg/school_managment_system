import 'package:flutter/material.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../../../../applications/role.dart';
import '../../data/models/news_model.dart';
import 'news_detail_dialog.dart';

class NewsVerticalCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback load;
  final Role role;

  const NewsVerticalCard({
    super.key,
    required this.news,
    this.onEdit,
    this.onDelete,
    required this.role,
    required this.load,
  });

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NewsDetailDialog(
        news: news,
        role: role,
        onNewsChanged: () {
          load; // your refresh method
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetailDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            // Inside NewsVerticalCard → in the image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: news.image != null && news.image!.trim().isNotEmpty
                  ? Image.network(
                      ApiService.getImageFullUrl(news.image!.trim()),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print(
                          "Image load failed: ${ApiService.getImageFullUrl(news.image)} → $error",
                        );
                        return Container(
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : SizedBox(),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${news.startDate} تا ${news.endDate}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  if (news.description != null &&
                      news.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      news.description!.trim(),
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      textDirection: TextDirection.rtl,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (role == Role.manager) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('ویرایش'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('حذف'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }
}
