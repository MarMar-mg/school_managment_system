
class ExamModelT {
  final int id;
  final String title;
  final String status; // 'upcoming' or 'completed'
  final String subject;
  final String date;
  final int students;
  final String classTime;
  final int capacity;
  final int duration;
  final int possibleScore;
  final String? location;
  final double? passPercentage;
  final String? filledCapacity;

  ExamModelT({
    required this.id,
    required this.title,
    required this.status,
    required this.subject,
    required this.date,
    required this.students,
    required this.classTime,
    required this.capacity,
    required this.duration,
    required this.possibleScore,
    this.location,
    this.passPercentage,
    this.filledCapacity,
  });

  factory ExamModelT.fromJson(Map<String, dynamic> json) {
    return ExamModelT(
      id: json['id'],
      title: json['title'] ?? 'نامشخص',
      status: json['status'] ?? 'upcoming',
      subject: json['subject'] ?? 'نامشخص',
      date: json['date'] ?? 'نامشخص',
      students: json['students'] ?? 0,
      classTime: json['classTime'] ?? 'نامشخص',
      capacity: json['capacity'] ?? 0,
      duration: json['duration'] ?? 0,
      possibleScore: json['possibleScore'] ?? 0,
      location: json['location'],
      passPercentage: json['passPercentage']?.toDouble(),
      filledCapacity: json['filledCapacity'],
    );
  }

  // Add toJson if needed for POST (creating exams)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': '', // Add if needed
      'startdate': date, // Map accordingly
      // etc., include courseId if selecting course
    };
  }
}

