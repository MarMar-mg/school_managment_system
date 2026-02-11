
class CourseModel {
  final int courseId;
  final String name;
  final String className;
  final int? teacherId;

  CourseModel({
    required this.courseId,
    required this.name,
    required this.className,
    this.teacherId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json['courseid'] as int,
      name: json['name'] as String,
      className: json['className'] as String,
      teacherId: json['teacherid'] as int?,
    );
  }
}