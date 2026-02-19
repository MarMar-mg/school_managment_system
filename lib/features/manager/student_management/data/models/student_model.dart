class StudentModel {
  final int studentId;
  final String name;
  final String studentCode;
  final int? stuClass;
  final String? phone;
  final String? parentPhone;
  final String? birthDate;
  final String? address;
  final int debt;
  final String? username;
  final String? password;

  StudentModel({
    required this.studentId,
    required this.name,
    required this.studentCode,
    this.stuClass,
    this.phone,
    this.parentPhone,
    this.birthDate,
    this.address,
    required this.debt,
    this.username,
    this.password
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json['id'] as int,
      name: json['name'] ?? 'نامشخص',
      studentCode: json['studentCode'] ?? 'N/A',
      stuClass: json['classs'] as int?,
      phone: json['phone'] as String?,
      parentPhone: json['parentPhone'] as String?,
      birthDate: json['birthDate'] as String?,
      address: json['address'] as String?,
      debt: (json['debt'] as num? ?? 0).toInt(),
      username: json['username'] as String?,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'studentCode': studentCode,
      'classId': stuClass?.toString() ?? '',
      'phone': phone ?? '',
      'parentPhone': parentPhone ?? '',
      'birthDate': birthDate ?? '',
      'address': address ?? '',
      'debt': debt,
    };
  }
}