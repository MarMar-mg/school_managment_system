import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
import '../../../../commons/utils/manager/date_manager.dart';
import '../../../admin/news_management/presentations/widgets/news_card.dart';

/// Premium animated news list with category colors, shimmer loading,
/// pull-to-refresh, and stunning staggered card animations.
class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList>
    with TickerProviderStateMixin {
  List<dynamic> _allNews = [];
  List<dynamic> _displayedNews = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showAll = false;

  late AnimationController _controller;
  late List<Animation<double>> _cardAnims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _cardAnims = [];
    _loadNews();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final news = await ApiService.getAllNews();
      final sortedNews = news
        ..sort((a, b) {
          final dateA = _parseDate(a.startDate);
          final dateB = _parseDate(b.startDate);
          return dateB.compareTo(dateA); // newest first
        });

      setState(() {
        _allNews = sortedNews;
        _displayedNews = sortedNews.take(3).toList();
        _isLoading = false;
        _showAll = false;
      });

      _startCardAnimations(_displayedNews.length);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startCardAnimations(int count) {
    _cardAnims = List.generate(
      count + 1,
          (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 + i * 0.08, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
    );
    _controller.forward(from: 0.0);
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    final dateStr = date.toString().trim();
    if (dateStr.length >= 8) {
      try {
        final year = int.parse(dateStr.substring(0, 4));
        final month = int.parse(dateStr.substring(4, 6));
        final day = dateStr.length > 6 ? int.parse(dateStr.substring(6, 8)) : 1;
        return DateTime(year, month, day);
      } catch (_) {}
    }
    return DateTime.now();
  }

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
      _displayedNews = _showAll ? _allNews : _allNews.take(3).toList();
    });
    _startCardAnimations(_displayedNews.length);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildShimmer();
    if (_errorMessage != null) return _buildError();
    if (_allNews.isEmpty) return _buildEmpty();

    return Column(
      children: [
        ..._displayedNews.asMap().entries.map((entry) {
          final index = entry.key;
          return AnimatedNewsCard(
            item: entry.value,
            animation: _cardAnims[index],
          );
        }),

        if (_allNews.length > 3)
          AnimatedShowMoreButton(
            showAll: _showAll,
            totalCount: _allNews.length,
            onPressed: _toggleShowAll,
            animation: _cardAnims.last,
          ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(3, (_) => const _ShimmerNewsCard())
          .map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: e))
          .toList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text('خطا در بارگذاری اخبار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_errorMessage!, style: TextStyle(color: AppColor.lightGray, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadNews,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 64, color: AppColor.lightGray),
          const SizedBox(height: 16),
          const Text('خبری موجود نیست', style: TextStyle(color: AppColor.lightGray)),
        ],
      ),
    );
  }
}

// ==================== ANIMATED COMPONENTS ====================

class AnimatedNewsCard extends StatelessWidget {
  final dynamic item;
  final Animation<double> animation;

  const AnimatedNewsCard({
    super.key,
    required this.item,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 70 * (1 - value)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        );
      },
      child:  NewsVerticalCard(
        news: item,
        onEdit: () => {},
        onDelete: () => {},
        role: Role.teacher, load: () => {},
      ),
    );
  }
}

class AnimatedShowMoreButton extends StatelessWidget {
  final bool showAll;
  final int totalCount;
  final VoidCallback onPressed;
  final Animation<double> animation;

  const AnimatedShowMoreButton({
    super.key,
    required this.showAll,
    required this.totalCount,
    required this.onPressed,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: 0.9 + (animation.value * 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: child,
            ),
          ),
        );
      },
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          elevation: 12,
          shadowColor: AppColor.purple.withOpacity(0.5),
        ),
        child: Text(
          showAll ? 'نمایش کمتر' : 'نمایش همه $totalCount',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ==================== PREMIUM NEWS CARD ====================

class NewsCard extends StatefulWidget {
  final dynamic item;

  const NewsCard({Key? key, required this.item}) : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item['title'] ?? 'بدون عنوان';
    final description = widget.item['description'] ?? '';
    final category = widget.item['category'] ?? '';
    final endDate = DateFormatManager.formatDate(widget.item['enddate']);

    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(_isPressed ? 0.3 : 0.18),
                  blurRadius: _isPressed ? 20 : 12,
                  offset: Offset(0, _isPressed ? 10 : 6),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.25),
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          onTap: () => debugPrint('News tapped: $title'),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient Icon Badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkText,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColor.lightGray,
                          height: 1.5,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // End Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    endDate,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'اطلاعیه':
        return AppColor.purple;
      case 'رویداد':
        return Colors.blue.shade600;
      case 'تعطیلات':
        return Colors.orange.shade600;
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
}

// ==================== SHIMMER CARD ====================

class _ShimmerNewsCard extends StatelessWidget {
  const _ShimmerNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(width: 56, height: 56, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 14, width: 200, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 150, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 70, height: 34, color: Colors.white),
          ],
        ),
      ),
    );
  }
}