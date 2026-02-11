class TeacherModel {
  final int teacherId;
  final String name;
  final String? phone;
  final String? nationalCode;
  final String? email;
  final DateTime? createdAt;
  final int? assignedCoursesCount;

  TeacherModel({
    required this.teacherId,
    required this.name,
    this.phone,
    this.nationalCode,
    this.email,
    this.createdAt,
    this.assignedCoursesCount,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      teacherId: json['teacherid'] as int,
      name: (json['name'] as String?) ?? 'نامشخص',
      phone: json['phone'] as String?,
      nationalCode: json['nationalCode'] as String?,
      email: json['email'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      assignedCoursesCount: json['assignedCoursesCount'] as int?,
    );
  }

  // ─── Add this copyWith method ───
  TeacherModel copyWith({
    int? teacherId,
    String? name,
    String? phone,
    String? nationalCode,
    String? email,
    DateTime? createdAt,
    int? assignedCoursesCount,
  }) {
    return TeacherModel(
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalCode: nationalCode ?? this.nationalCode,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      assignedCoursesCount: assignedCoursesCount ?? this.assignedCoursesCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'nationalCode': nationalCode,
      'email': email,
    };
  }
}