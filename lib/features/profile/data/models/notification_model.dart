class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String createdAt;
  final bool isRead;
  final String type;
  final int? relatedId;
  final String? relatedType;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.relatedId,
    this.relatedType,
  });

  // Add this factory if you don't already have it
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: json['createdAt'] as String,
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String? ?? 'general',
      relatedId: json['relatedId'] as int?,
      relatedType: json['relatedType'] as String?,
    );
  }

  // ← Add this copyWith method
  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    String? createdAt,
    bool? isRead,
    String? type,
    int? relatedId,
    String? relatedType,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
    );
  }

  // Optional: toJson if you need to send data back
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt,
      'isRead': isRead,
      'type': type,
      'relatedId': relatedId,
      'relatedType': relatedType,
    };
  }
}
