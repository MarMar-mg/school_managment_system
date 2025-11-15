// features/dashboard/presentation/widgets/events_list_widget.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../applications/colors.dart';
import '../../../../core/services/api_service.dart';
import '../../../../commons/utils/manager/date_manager.dart';

/// Premium animated events list with shimmer, pull-to-refresh,
/// staggered card entrance, and smooth "Show More" animation.
class EventsList extends StatefulWidget {
  const EventsList({super.key});

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList>
    with TickerProviderStateMixin {
  List<dynamic> _allEvents = [];
  List<dynamic> _displayedEvents = [];
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
      duration: const Duration(milliseconds: 1200),
    );
    _cardAnims = [];
    _loadEvents();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final events = await ApiService.getEvents();
      final sortedEvents = events
        ..sort((a, b) {
          final dateA = _parseDate(a['date']);
          final dateB = _parseDate(b['date']);
          return dateA.compareTo(dateB);
        });

      setState(() {
        _allEvents = sortedEvents;
        _displayedEvents = sortedEvents.take(3).toList();
        _isLoading = false;
        _showAll = false;
      });

      // Start staggered animation
      _startCardAnimations(_displayedEvents.length);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startCardAnimations(int count) {
    _cardAnims = List.generate(
      count + 1, // +1 for button
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
    if (date == null) return DateTime.now().add(const Duration(days: 9999));
    final dateStr = date.toString().trim();
    if (dateStr.length >= 8) {
      try {
        final year = int.parse(dateStr.substring(0, 4));
        final month = int.parse(dateStr.substring(4, 6));
        final day = int.parse(dateStr.substring(6, 8));
        return DateTime(year, month, day);
      } catch (_) {}
    }
    return DateTime.now().add(const Duration(days: 9999));
  }

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
      _displayedEvents = _showAll ? _allEvents : _allEvents.take(3).toList();
    });
    _startCardAnimations(_displayedEvents.length);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildShimmer();
    if (_errorMessage != null) return _buildError();
    if (_allEvents.isEmpty) return _buildEmpty();

    return Column(
      children: [
        ..._displayedEvents.asMap().entries.map((entry) {
          final index = entry.key;
          return AnimatedEventCard(
            item: entry.value,
            animation: _cardAnims[index],
          );
        }),

        if (_allEvents.length > 3)
          AnimatedShowMoreButton(
            showAll: _showAll,
            totalCount: _allEvents.length,
            onPressed: _toggleShowAll,
            animation: _cardAnims.last,
          ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(3, (_) => const _ShimmerEventCard())
          .map((card) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: card,
      ))
          .toList(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'خطا در بارگذاری رویدادها',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.darkText),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage!, style: TextStyle(color: AppColor.lightGray)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadEvents,
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
          Icon(Icons.event_busy_outlined, size: 64, color: AppColor.lightGray),
          const SizedBox(height: 16),
          Text('رویدادی موجود نیست', style: TextStyle(color: AppColor.lightGray)),
        ],
      ),
    );
  }
}

// ==================== ANIMATED COMPONENTS ====================

class AnimatedEventCard extends StatelessWidget {
  final dynamic item;
  final Animation<double> animation;

  const AnimatedEventCard({
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
            offset: Offset(0, 60 * (1 - value)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        );
      },
      child: EventCard(item: item),
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
            scale: animation.value,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          elevation: 8,
          shadowColor: AppColor.purple.withOpacity(0.4),
        ),
        child: Text(
          showAll ? 'نمایش کمتر' : 'نمایش همه $totalCount',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}

// ==================== EVENT CARD (PREMIUM) ====================

class EventCard extends StatefulWidget {
  final dynamic item;

  const EventCard({Key? key, required this.item}) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
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
    final date = DateFormatManager.formatDate(widget.item['date']);
    final eventId = widget.item['eventId'];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isPressed ? 0.12 : 0.08),
                  blurRadius: _isPressed ? 16 : 10,
                  offset: Offset(0, _isPressed ? 8 : 4),
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
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.orange.withOpacity(0.2),
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
          onTap: () => debugPrint('Event tapped: $title'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.event_rounded, color: Colors.white, size: 26),
                ),

                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkText,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'شناسه رویداد: $eventId',
                        style: TextStyle(fontSize: 13, color: AppColor.lightGray),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Date Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColor.darkText,
                      fontWeight: FontWeight.w600,
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
}

// ==================== SHIMMER CARD ====================

class _ShimmerEventCard extends StatelessWidget {
  const _ShimmerEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        height: 84,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(width: 52, height: 52, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 120, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 70, height: 32, color: Colors.white),
          ],
        ),
      ),
    );
  }
}