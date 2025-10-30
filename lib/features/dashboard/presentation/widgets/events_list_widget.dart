import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../models/dashboard_models.dart';

class EventsList extends StatelessWidget {
  final List<EventItem> eventItems;

  const EventsList({
    Key? key,
    required this.eventItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: eventItems.map((item) => EventCard(item: item)).toList(),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventItem item;

  const EventCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
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

          // Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.date,
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