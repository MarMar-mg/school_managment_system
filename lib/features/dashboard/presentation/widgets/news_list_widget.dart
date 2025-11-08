import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../core/services/api_service.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  List<dynamic> _allNews = [];
  List<dynamic> _displayedNews = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final news = await ApiService.getNews();

      final sortedNews = news
        ..sort((a, b) {
          final dateA = _parseDate(a['Startdate']);
          final dateB = _parseDate(b['Startdate']);
          return dateA.compareTo(dateB);
        });

      setState(() {
        _allNews = sortedNews;
        _displayedNews = sortedNews.take(2).toList();
        _isLoading = false;
        _showAll = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error loading news: $e');
    }
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now().add(const Duration(days: 9999));
    final dateStr = date.toString().trim();
    if (dateStr.length >= 8) {
      try {
        final year = int.parse(dateStr.substring(0, 4));
        final month = int.parse(dateStr.substring(4, 6));
        final day = dateStr.length > 6 ? int.parse(dateStr.substring(6, 8)) : 1;
        return DateTime(year, month, day);
      } catch (e) {
        return DateTime.now().add(const Duration(days: 9999));
      }
    }
    return DateTime.now().add(const Duration(days: 9999));
  }

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
      _displayedNews = _showAll ? _allNews : _allNews.take(3).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_allNews.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        ..._displayedNews.map((item) => NewsCard(item: item)).toList(),

        if (_allNews.length > 2)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton(
              onPressed: _toggleShowAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                _showAll ? 'نمایش کمتر' : 'نمایش همه ${_allNews.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            const Text(
              'خطا در بارگذاری اخبار',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 13, color: AppColor.lightGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNews,
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'خبری موجود نیست',
          style: TextStyle(fontSize: 14, color: AppColor.lightGray),
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final dynamic item;

  const NewsCard({Key? key, required this.item}) : super(key: key);

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'اطلاعیه':
        return AppColor.purple;
      case 'رویداد':
        return Colors.blue;
      case 'تعطیلات':
        return Colors.orange;
      default:
        return AppColor.purple;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'اطلاعیه':
        return Icons.campaign_rounded;
      case 'رویداد':
        return Icons.event_rounded;
      case 'تعطیلات':
        return Icons.beach_access_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    final dateStr = date.toString().trim();
    if (dateStr.length >= 8) {
      final year = dateStr.substring(0, 4);
      final month = dateStr.substring(5, 7);
      final day = dateStr.substring(8, 10);
      return '$year/$month/$day';
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? 'بدون عنوان';
    final description = item['description'] ?? '';
    final category = item['category'] ?? '';
    final startDate = _formatDate(item['startdate']);
    final endDate = _formatDate(item['enddate']);

    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.lightGray,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              //   child: Text(
              //     startDate,
              //     style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              //     textDirection: TextDirection.rtl,
              //   ),
              // ),
              // Text(
              //   'الی',
              //   style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              //   textDirection: TextDirection.rtl,
              // ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  endDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
