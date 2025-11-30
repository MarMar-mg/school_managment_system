import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:school_management_system/applications/colors.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../applications/role.dart';
import '../../features/dashboard/data/models/dashboard_models.dart';
import '../../features/student/assignments/data/models/assignment_model.dart.dart';
import '../../features/student/exam/entities/models/exam_model.dart';
import '../../features/student/scores/data/models/score_model.dart';
import '../../features/teacher/exam_management/data/models/exam_model.dart';

class ApiService {
  // Update this based on your testing environment
  static const String baseUrl = 'http://localhost:5105/api';

  // For Android Emulator: 'http://10.0.2.2:5105/api'
  // For iOS Simulator: 'http://localhost:5105/api'
  // For Real Device: 'http://YOUR_COMPUTER_IP:5105/api'

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const Duration _timeout = Duration(seconds: 10);

  // ==================== AUTH ====================

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(_timeout);

      print('Login Status: ${response.statusCode}');
      print('Login Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('نام کاربری یا رمز عبور اشتباه است');
      } else {
        throw Exception('خطای سرور: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception('خطا در اتصال به سرور. آیا API اجرا شده؟');
    } catch (e) {
      print('Error: $e');
      throw Exception('خطا: $e');
    }
  }

  // ==================== NEWS ====================

  static Future<List<dynamic>> getNews() async {
    final url = Uri.parse('$baseUrl/news');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('News Status: ${response.statusCode}');
      print('News Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('خطا در دریافت اخبار: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception('خطا در اتصال به سرور');
    } catch (e) {
      print('Error: $e');
      throw Exception('خطا: $e');
    }
  }

  static Future<Map<String, dynamic>> getNewsById(int newsId) async {
    final url = Uri.parse('$baseUrl/news/$newsId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('خبر یافت نشد');
      } else {
        throw Exception('خطا در دریافت خبر: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  // ==================== EVENTS ====================

  static Future<List<dynamic>> getEvents() async {
    final url = Uri.parse('$baseUrl/calender');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Events Status: ${response.statusCode}');
      print('Events Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('خطا در دریافت رویدادها: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  // ==================== STUDENT ====================

  static Future<Map<String, dynamic>> getStudentDashboard(int userId) async {
    final url = Uri.parse('$baseUrl/student/dashboard/$userId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Student Dashboard Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('دانش‌آموز یافت نشد');
      } else {
        throw Exception('خطا در دریافت داده‌ها: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  // static Future<List<dynamic>> getStudentExercises(int studentId) async {
  //   final url = Uri.parse('$baseUrl/student/assignment/$studentId');
  //
  //   try {
  //     final response = await http.get(url, headers: _headers).timeout(_timeout);
  //
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body) as List<dynamic>;
  //     } else {
  //       throw Exception('خطا در دریافت تمرین‌ها: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('خطا: $e');
  //   }
  // }

  // static Future<List<dynamic>> getStudentExams(int studentId) async {
  //   final url = Uri.parse('$baseUrl/student/exams/$studentId');
  //
  //   try {
  //     final response = await http.get(url, headers: _headers).timeout(_timeout);
  //
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body) as List<dynamic>;
  //     } else {
  //       throw Exception('خطا در دریافت امتحانات: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('خطا: $e');
  //   }
  // }

  // ==================== TEACHER ====================

  static Future<Map<String, dynamic>> getTeacherDashboard(int userId) async {
    final url = Uri.parse('$baseUrl/teacher/dashboard/$userId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('معلم یافت نشد');
      } else {
        throw Exception('خطا در دریافت داده‌ها: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  // ==================== COURSES ====================

  // core/services/api_service.dart
  static Future<List<Map<String, dynamic>>> getCourses(
    Role role,
    int userId,
  ) async {
    final List<Map<String, dynamic>> courses = [];

    try {
      switch (role) {
        case Role.student:
          final response = await http.get(
            Uri.parse('$baseUrl/student/courses/$userId'),
          );
          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            courses.addAll(
              data.map(
                (c) => {
                  'name': c['courseName'] ?? 'نامشخص',
                  'code': c['courseCode'] ?? '',
                  'teacher': c['teacherName'] ?? 'نامشخص',
                  'location': c['location'] ?? 'نامشخص',
                  'Classtime': c['classtime'] ?? 'نامشخص',
                  'progress': c['progress'] ?? 0,
                  'grade': c['grade'] ?? '-',
                  'id': c['courseId'] ?? '',
                  'color': _getColor(c['courseName']),
                  'icon': _getIcon(c['courseName']),
                },
              ),
            );
          }
          break;

        case Role.teacher:
          final response = await http.get(
            Uri.parse('$baseUrl/teacher/courses/$userId'),
          );
          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            courses.addAll(
              data.map(
                (c) => {
                  'name': c['courseName'] ?? 'نامشخص',
                  'code': c['courseCode'] ?? '',
                  'id': c['courseId'] ?? '',
                  'teacher': c['teacherName'] ?? 'نامشخص',
                  'location': c['location'] ?? 'نامشخص',
                  'Classtime': c['time'] ?? 'نامشخص',
                  'progress': c['progress'] ?? 0,
                  'grade': c['grade'] ?? '-',
                  'color': _getColor(c['courseName']),
                  'icon': _getIcon(c['courseName']),
                },
              ),
            );
          }
          break;

        default:
          break;
      }
    } catch (e) {
      print('Error loading courses: $e');
    }

    return courses;
  }

  static Color _getColor(String? name) {
    if (name == null) return Colors.grey;
    if (name.contains('ریاضی')) return AppColor.purple;
    if (name.contains('شیمی')) return Colors.blue;
    if (name.contains('فیزیک')) return Colors.orange;
    return Colors.green;
  }

  static IconData _getIcon(String? name) {
    if (name == null) return Icons.book;
    if (name.contains('ریاضی')) return Icons.calculate_rounded;
    if (name.contains('شیمی')) return Icons.science_rounded;
    if (name.contains('فیزیک')) return Icons.flash_on_rounded;
    return Icons.menu_book_rounded;
  }

  // =================== GET PROGRESS ====================================
  static Future<List<ProgressItem>> getProgress({
    required Role role,
    required int userId,
  }) async {
    String endpoint;
    switch (role) {
      case Role.student:
        endpoint = '$baseUrl/student/progress/$userId';
        break;
      case Role.teacher:
        endpoint = '$baseUrl/teacher/progress/$userId';
        break;
      case Role.manager:
        endpoint = '$baseUrl/admin/progress';
        break;
    }

    try {
      final response = await http.get(Uri.parse(endpoint), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProgressItem.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('API Error: $e');
      return [];
    }
  }

  static Future<List<StatCard>> getStats(Role role, int userId) async {
    final List<StatCard> stats = [];

    try {
      String endpoint;
      switch (role) {
        case Role.student:
          endpoint = '$baseUrl/student/stats/$userId';
          break;
        case Role.teacher:
          endpoint = '$baseUrl/teacher/stats/$userId';
          break;
        case Role.manager:
          endpoint = '$baseUrl/admin/stats';
          break;
        default:
          return stats;
      }

      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        stats.addAll(data.map((s) => StatCard.fromJson(s)));
      }
    } catch (e) {
      print('Error loading stats: $e');
    }

    return stats;
  }

  // ==================== EXAMS ====================
  static Future<Map<String, List<ExamItem>>> getAllExams(int studentId) async {
    final pending = <ExamItem>[];
    final answered = <ExamItem>[];
    final scored = <ExamItem>[];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/exam/$studentId'),
      );
      if (response.statusCode != 200) {
        throw Exception('خطا: ${response.statusCode}');
      }
      final List<dynamic> list = json.decode(response.body);

      for (var json in list) {
        final score = json['score'];
        final status = score == null
            ? ExamStatus.pending
            : (score > 0 ? ExamStatus.scored : ExamStatus.answered);

        final item = ExamItem(
          title: json['title'],
          courseName: json['courseName'],
          dueDate: json['examDate'],
          startTime: json['startTime'],
          endTime: json['endTime'],
          submittedDate: json['submittedDate'],
          score: score,
          totalScore: 100,
          status: status,
          answerImage: json['answerImage'],
          filename: json['filename'],
          onReminderTap: () => print('Reminder set'),
          onViewAnswer: () => print('View answer'),
        );

        switch (status) {
          case ExamStatus.pending:
            pending.add(item);
            break;
          case ExamStatus.answered:
            answered.add(item);
            break;
          case ExamStatus.scored:
            scored.add(item);
            break;
        }
      }
    } catch (e) {
      throw Exception('خطا در بارگذاری');
    }

    return {'pending': pending, 'answered': answered, 'scored': scored};
  }

  // ==================== ASSIGNMENTS ====================
  static Future<Map<String, List<AssignmentItemm>>> getAllAssignments(
    int studentId,
  ) async {
    final url = Uri.parse('$baseUrl/student/exercises/$studentId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        final pending = (json['pending'] as List<dynamic>? ?? [])
            .map((e) => AssignmentItemm.fromJson(e as Map<String, dynamic>))
            .toList();

        final submittedNoGrade =
            (json['submittedNoGrade'] as List<dynamic>? ?? [])
                .map(
                  (e) => AssignmentItemm.fromJson({
                    ...e as Map<String, dynamic>,
                  }),
                )
                .toList();

        final graded = (json['graded'] as List<dynamic>? ?? [])
            .map(
              (e) => AssignmentItemm.fromJson({
                ...e as Map<String, dynamic>,
                'status': 'graded',
              }),
            )
            .toList();

        return {
          'pending': pending,
          'submitted': submittedNoGrade,
          'graded': graded,
        };
      } else {
        throw Exception('خطا: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assignments: $e');
      return {
        'pending': <AssignmentItemm>[],
        'submitted': <AssignmentItemm>[],
        'graded': <AssignmentItemm>[],
      };
    }
  }

  // ==================== SCORES ====================
  static Future<DashboardData> getMyScore(int studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/my-score/$studentId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode}');
    }
    return DashboardData.fromJson(json.decode(response.body));
  }

  // ==================== USERNAME ====================
  static Future<String> getUserDisplayName(Role role, int userId) async {
    try {
      final endpoint = switch (role) {
        Role.student => '$baseUrl/student/name/$userId',
        Role.teacher => '$baseUrl/teacher/name/$userId',
        Role.manager => '$baseUrl/admin/name/$userId',
      };

      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['name'] ?? 'کاربر';
      }
    } catch (e) {
      print('Error loading name: $e');
    }
    return 'کاربر';
  }

  // ==================== AVERAGE_GRADE ====================
  static Future<double> getAverageGrade(Role role, int userId) async {
    try {
      final endpoint = role == Role.student
          ? '$baseUrl/student/average/$userId'
          : '$baseUrl/teacher/average/$userId';

      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['average'] as num).toDouble();
      }
    } catch (e) {
      print('Error loading average: $e');
    }
    return 0.0;
  }

  // دریافت تمرین‌ها و امتحان‌های دو روز آینده
  static Future<List<AssignmentItem>> getUpcomingAssignments(
    int studentId,
  ) async {
    final now = DateTime.now();
    final twoDaysLater = now.add(const Duration(days: 2));

    // فرمت تاریخ: 14030901
    final startDate = _formatShamsiDate(now);
    final endDate = _formatShamsiDate(twoDaysLater);

    final List<AssignmentItem> assignments = [];

    try {
      // تمرین‌ها
      final exerciseResponse = await http.get(
        Uri.parse(
          '$baseUrl/student/assignment/$studentId?start=$startDate&end=$endDate',
        ),
      );

      if (exerciseResponse.statusCode == 200) {
        final List<dynamic> exercises = json.decode(exerciseResponse.body);
        assignments.addAll(
          exercises.map(
            (e) => AssignmentItem(
              title: e['title'] ?? 'تمرین',
              subject: e['courseName'] ?? 'نامشخص',
              badge: _formatDisplayShamsiDate(e['dueDate']),
              endTime: e['endTime'] ?? 'نامشخص',
              badgeColor: Colors.orange,
              icon: Icons.assignment_rounded,
            ),
          ),
        );
      }

      // امتحان‌ها
      final examResponse = await http.get(
        Uri.parse(
          '$baseUrl/student/exams/$studentId?start=$startDate&end=$endDate',
        ),
      );

      if (examResponse.statusCode == 200) {
        final List<dynamic> exams = json.decode(examResponse.body);
        assignments.addAll(
          exams.map(
            (e) => AssignmentItem(
              title: e['title'] ?? 'امتحان',
              subject: e['courseName'] ?? 'نامشخص',
              badge: _formatDisplayShamsiDate(e['examDate']),
              badgeColor: Colors.red,
              icon: Icons.quiz_rounded,
              endTime: e['endTime'],
            ),
          ),
        );
      }
    } catch (e) {
      print('Error fetching assignments: $e');
    }

    // مرتب‌سازی بر اساس تاریخ
    assignments.sort((a, b) {
      final dateA = _parseBadgeDate(a.badge);
      final dateB = _parseBadgeDate(b.badge);
      return dateA.compareTo(dateB);
    });

    return assignments;
  }

  // ==================== TEACHER ASSIGNMENTS ====================

  static Future<List<dynamic>> getTeacherAssignments(int teacherId) async {
    final url = Uri.parse('$baseUrl/teacher/exercises/$teacherId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('خطا در دریافت تمرین‌ها: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  // ====================== ADD ASSIGNMENT ===============================
  static Future<Map<String, dynamic>> addTeacherAssignment({
    required int teacherId,
    required int courseId,
    required String title,
    String? description,
    String? endDate,
    String? endTime,
    String? startDate,
    String? startTime,
    int? score,
  }) async {
    final url = Uri.parse('$baseUrl/teacher/exercises');

    final body = json.encode({
      'teacherid': teacherId,
      'courseid': courseId,
      'title': title,
      'description': description,
      'enddate': endDate,
      'endtime': endTime,
      'startdate': startDate,
      'starttime': startTime,
      'score': score,
    });

    try {
      final response = await http.post(url, headers: _headers, body: body).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در اضافه کردن تمرین: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  // ========================= UPDATE ASSIGNMENT ================================
  static Future<Map<String, dynamic>> updateTeacherAssignment({
    required int exerciseId,
    required int teacherId,
    String? title,
    String? description,
    String? endDate,
    String? endTime,
    int? score,
  }) async {
    final url = Uri.parse('$baseUrl/teacher/exercises/$exerciseId');

    final body = json.encode({
      'teacherid': teacherId,
      'title': title,
      'description': description,
      'enddate': endDate,
      'endtime': endTime,
      'score': score,
    });

    try {
      final response = await http.put(url, headers: _headers, body: body).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در به‌روزرسانی تمرین: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  // ===============================DELETE ASSIGNMENT======================================
  static Future<Map<String, dynamic>> deleteTeacherAssignment(int exerciseId, int teacherId) async {
    final url = Uri.parse('$baseUrl/teacher/exercises/$exerciseId?teacherId=$teacherId');

    try {
      final response = await http.delete(url, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در حذف تمرین: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

 // ================================= GET SUBMISSION FOR ASSIGNMENT =============================
  static Future<List<dynamic>> getAssignmentSubmissions(int exerciseId, int teacherId) async {
    final url = Uri.parse('$baseUrl/teacher/exercises/$exerciseId/submissions?teacherId=$teacherId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('خطا در دریافت رسالت‌ها: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  // ================================= GET EXAMS FOR TEACHER =============================
  static Future<List<ExamModelT>> getTeacherExams(int teacherId) async {
    final url = Uri.parse('$baseUrl/teacher/exams/$teacherId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Teacher Exams Status: ${response.statusCode}');
      print('Teacher Exams Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ExamModelT.fromJson(e)).toList();
      } else {
        throw Exception('خطا در دریافت امتحانات: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching teacher exams: $e');
      throw Exception('خطا: $e');
    }
  }

  // ================================= CREATE EXAMS =============================
  static Future<void> createExam(int teacherId, Map<String, dynamic> examData) async {
    final url = Uri.parse('$baseUrl/teacher/exam'); // Or '$baseUrl/teacher/exams/$teacherId' if adding to TeacherController

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(examData),
      ).timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('خطا در ایجاد امتحان: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  ///////////////////////////////////////////

  // تبدیل DateTime میلادی به رشته شمسی (14030825)
  static String _formatShamsiDate(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}${jalali.month.toString().padLeft(2, '0')}${jalali.day.toString().padLeft(2, '0')}';
  }

  // تبدیل رشته شمسی (14030825) به نمایش (۱۴۰۳/۰۸/۲۵)
  static String _formatDisplayShamsiDate(String? shamsiStr) {
    if (shamsiStr == null || shamsiStr.length < 8) return 'نامشخص';
    final year = shamsiStr.substring(0, 4);
    final month = shamsiStr.substring(4, 6);
    final day = shamsiStr.substring(6, 8);
    return shamsiStr;
  }

  // static String DateFormatManager.formatDate(DateTime date.) {
  //   return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  // }
  //
  // static String _formatDisplayDate(String? date) {
  //   if (date == null || date.length < 8) return '';
  //   return '${date.substring(0,4)}/${date.substring(4,6)}/${date.substring(6,8)}';
  // }

  static DateTime _parseBadgeDate(String badge) {
    final parts = badge.split('/');
    if (parts.length != 3) return DateTime.now().add(const Duration(days: 999));
    try {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return DateTime.now().add(const Duration(days: 999));
    }
  }
}
