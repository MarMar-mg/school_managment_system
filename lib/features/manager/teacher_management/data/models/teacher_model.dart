class TeacherModel {
  final int teacherId;
  final String name;
  final String? phone;
  final String? nationalCode;
  final String? email;
  final String? specialty;          // جدید: تخصص
  final DateTime? createdAt;
  final int? assignedCoursesCount;
  final String? username;
  final String? password;

  TeacherModel({
    required this.teacherId,
    required this.name,
    this.phone,
    this.nationalCode,
    this.email,
    this.specialty,
    this.createdAt,
    this.assignedCoursesCount,
    this.username,
    this.password,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      teacherId: json['teacherid'] as int? ?? 0,
      name: json['name'] as String? ?? 'نامشخص',
      phone: json['phone'] as String?,
      nationalCode: json['nationalCode'] as String?,
      email: json['email'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      assignedCoursesCount: json['assignedCoursesCount'] as int?,
      specialty: json['specialty'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
    );
  }

  // copyWith هم به‌روزرسانی شود (اگر استفاده می‌کنید)
  TeacherModel copyWith({
    int? teacherId,
    String? name,
    String? phone,
    String? nationalCode,
    String? email,
    String? specialty,
    DateTime? createdAt,
    int? assignedCoursesCount,
    String? username,
    String? password,
  }) {
    return TeacherModel(
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalCode: nationalCode ?? this.nationalCode,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
      createdAt: createdAt ?? this.createdAt,
      assignedCoursesCount: assignedCoursesCount ?? this.assignedCoursesCount,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}