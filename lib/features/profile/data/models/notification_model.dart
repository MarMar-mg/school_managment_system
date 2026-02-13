class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String createdAt; // ISO string or your custom format
  final bool isRead;
  final String type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? json['notificationId'] as int,
      title: json['title'] as String? ?? 'بدون عنوان',
      body: json['body'] as String? ?? json['message'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? json['date'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
      type: json['type'] as String? ?? 'general',
    );
  }

  // Optional: helper to show relative time (you can use timeago or custom logic)
  String get relativeTime {
    // Implement later or use package:timeago
    return "چند دقیقه پیش"; // placeholder
  }
}