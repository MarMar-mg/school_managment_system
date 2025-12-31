/// Model for class statistics data
class ClassStatsModel {
  final int id;
  final String name;
  final String grade;
  final int capacity;
  final int totalStudents;
  final double avgScore;
  final int passPercentage;
  final List<ScoreRangeModel> scoreRanges;
  final List<SubjectScoreModel> subjectScores;
  final List<TopPerformerModel> topPerformers;

  ClassStatsModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.capacity,
    required this.totalStudents,
    required this.avgScore,
    required this.passPercentage,
    required this.scoreRanges,
    required this.subjectScores,
    required this.topPerformers,
  });

  /// Create ClassStatsModel from JSON
  factory ClassStatsModel.fromJson(Map<String, dynamic> json) {
    return ClassStatsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'نامشخص',
      grade: json['grade'] ?? 'نامشخص',
      capacity: json['capacity'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      passPercentage: json['passPercentage'] ?? 0,
      scoreRanges: (json['scoreRanges'] as List<dynamic>? ?? [])
          .map((e) => ScoreRangeModel.fromJson(e))
          .toList(),
      subjectScores: (json['subjectScores'] as List<dynamic>? ?? [])
          .map((e) => SubjectScoreModel.fromJson(e))
          .toList(),
      topPerformers: (json['topPerformers'] as List<dynamic>? ?? [])
          .map((e) => TopPerformerModel.fromJson(e))
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'capacity': capacity,
      'totalStudents': totalStudents,
      'avgScore': avgScore,
      'passPercentage': passPercentage,
      'scoreRanges': scoreRanges.map((e) => e.toJson()).toList(),
      'subjectScores': subjectScores.map((e) => e.toJson()).toList(),
      'topPerformers': topPerformers.map((e) => e.toJson()).toList(),
    };
  }
}

/// Model for score range distribution
class ScoreRangeModel {
  final String range;
  final int count;
  final int percentage;

  ScoreRangeModel({
    required this.range,
    required this.count,
    required this.percentage,
  });

  factory ScoreRangeModel.fromJson(Map<String, dynamic> json) {
    return ScoreRangeModel(
      range: json['range'] ?? 'نامشخص',
      count: json['count'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'range': range,
      'count': count,
      'percentage': percentage,
    };
  }
}

/// Model for subject average scores
class SubjectScoreModel {
  final String name;
  final double avgScore;
  final int totalCount;

  SubjectScoreModel({
    required this.name,
    required this.avgScore,
    required this.totalCount,
  });

  factory SubjectScoreModel.fromJson(Map<String, dynamic> json) {
    return SubjectScoreModel(
      name: json['name'] ?? 'نامشخص',
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avgScore': avgScore,
      'totalCount': totalCount,
    };
  }
}

/// Model for top performing students
class TopPerformerModel {
  final int studentId;
  final String studentName;
  final String stuCode;
  final double avgScore;
  final int rank;

  TopPerformerModel({
    required this.studentId,
    required this.studentName,
    required this.stuCode,
    required this.avgScore,
    required this.rank,
  });

  factory TopPerformerModel.fromJson(Map<String, dynamic> json) {
    return TopPerformerModel(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? 'نامشخص',
      stuCode: json['stuCode'] ?? 'نامشخص',
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'stuCode': stuCode,
      'avgScore': avgScore,
      'rank': rank,
    };
  }
}

/// Model for class overview (used in list)
class ClassOverviewModel {
  final int id;
  final String name;
  final String grade;
  final int studentCount;
  final double avgScore;
  final int passPercentage;

  ClassOverviewModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.studentCount,
    required this.avgScore,
    required this.passPercentage,
  });

  factory ClassOverviewModel.fromJson(Map<String, dynamic> json) {
    return ClassOverviewModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'نامشخص',
      grade: json['grade'] ?? 'نامشخص',
      studentCount: json['studentCount'] ?? 0,
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      passPercentage: json['passPercentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'studentCount': studentCount,
      'avgScore': avgScore,
      'passPercentage': passPercentage,
    };
  }
}