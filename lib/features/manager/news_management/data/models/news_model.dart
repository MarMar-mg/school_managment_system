// features/news/data/models/news_model.dart
class NewsModel {
  final int newsId;
  final String title;
  final String category;
  final String startDate;
  final String endDate;
  final String? description;
  final String? image;

  NewsModel({
    required this.newsId,
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.description,
    this.image,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      newsId: json['newsid'] as int? ?? 0,  // Handle potential null ID for new items
      title: json['title'] as String,
      category: json['category'] as String,
      startDate: json['startdate'] as String,
      endDate: json['enddate'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'startdate': startDate,
      'enddate': endDate,
      'description': description,
      'image': image,
    };
  }
}