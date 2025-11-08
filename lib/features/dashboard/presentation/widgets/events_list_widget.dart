import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../core/services/api_service.dart';

class EventsList extends StatefulWidget {
  const EventsList({super.key});

  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  List<dynamic> _allEvents = [];
  List<dynamic> _displayedEvents = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
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
        _displayedEvents = sortedEvents.take(2).toList();
        _isLoading = false;
        _showAll = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error loading events: $e');
    }
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
      } catch (e) {
        return DateTime.now().add(const Duration(days: 9999));
      }
    }
    return DateTime.now().add(const Duration(days: 9999));
  }

  void _toggleShowAll() {
    setState(() {
      _showAll = !_showAll;
      _displayedEvents = _showAll ? _allEvents : _allEvents.take(3).toList();
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

    if (_allEvents.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        ..._displayedEvents.map((item) => EventCard(item: item)).toList(),

        if (_allEvents.length > 2)
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
                _showAll ? 'نمایش کمتر' : ' نمایش همه ${_allEvents.length}',
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
              'خطا در بارگذاری رویدادها',
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
              onPressed: _loadEvents,
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
          'رویدادی موجود نیست',
          style: TextStyle(fontSize: 14, color: AppColor.lightGray),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final dynamic item;

  const EventCard({Key? key, required this.item}) : super(key: key);

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
    final date = _formatDate(item['date']);
    final eventId = item['eventId'];

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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_rounded,
              color: Colors.orange,
              size: 24,
            ),
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
                  'شناسه رویداد: $eventId',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.lightGray,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 11,
                color: AppColor.darkText,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
