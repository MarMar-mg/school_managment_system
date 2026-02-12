class TeacherModel {
  final int teacherId;
  final String name;
  final String? phone;
  final String? nationalCode;
  final String? email;
  final DateTime? createdAt;
  final int? assignedCoursesCount;  // ← make this nullable (int?)
  final String? username;
  final String? password;

  TeacherModel({
    required this.teacherId,
    required this.name,
    this.phone,
    this.nationalCode,
    this.email,
    this.createdAt,
    this.assignedCoursesCount,  // ← no 'required' here
    this.username,
    this.password,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    print('Raw JSON: $json');
    return TeacherModel(
      teacherId: json['teacherid'] as int? ?? 0,
      name: (json['name'] as String?) ?? 'نامشخص',
      phone: json['phone'] as String?,
      nationalCode: json['nationalCode'] as String?,
      email: json['email'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      assignedCoursesCount: json['assignedCoursesCount'] as int?,
      username: json['username'] as String?,
      password: json['password'] as String?,
    );
  }

  // copyWith remains the same
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