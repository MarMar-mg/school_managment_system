
class ExamModel {
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

  ExamModel({
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

}

