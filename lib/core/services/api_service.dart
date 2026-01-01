import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
                  'grade': c['averageGrade'] ?? '-',
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
      final response = await http
          .get(Uri.parse('$baseUrl/student/exam/$studentId'), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('خطا: ${response.statusCode}');
      }

      final List<dynamic> list = json.decode(response.body);

      for (var json in list) {
        final score = json['score'];
        final examDate = json['examDate']; // "1403-09-20"
        final endTime = json['endTime']; // "14:30"

        // IMPORTANT: Extract exam ID correctly
        final examId = json['id'];

        print('DEBUG: Exam ID from API: $examId, Title: ${json['title']}');

        // Parse exam end time to determine status
        late final ExamStatus status;
        try {
          // Parse date and time: "1403-09-20" + "14:30"
          final dateParts = examDate.split('-');
          final timeParts = endTime.split(':');

          final jalaliYear = int.parse(dateParts[0]);
          final jalaliMonth = int.parse(dateParts[1]);
          final jalaliDay = int.parse(dateParts[2]);

          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          // Convert Jalali to Gregorian using shamsi_date package
          final jalaliDate = Jalali(jalaliYear, jalaliMonth, jalaliDay);
          final gregorianDate = jalaliDate.toGregorian();

          final examEndTime = DateTime(
            gregorianDate.year,
            gregorianDate.month,
            gregorianDate.day,
            hour,
            minute,
          );

          final now = DateTime.now();

          // Determine status based on exam end time
          if (now.isBefore(examEndTime)) {
            // Exam time hasn't ended yet
            status = ExamStatus.pending;
          } else if (score == null) {
            // Exam time is over but no score yet
            status = ExamStatus.answered;
          } else {
            // Exam time is over and score exists
            status = ExamStatus.scored;
          }
        } catch (e) {
          print('Error parsing exam date/time: $e');
          // Fallback: use score to determine status
          status = score == null ? ExamStatus.answered : ExamStatus.scored;
        }

        final item = ExamItem(
          title: json['title'] ?? 'بدون عنوان',
          courseName: json['courseName'] ?? 'نامشخص',
          dueDate: json['examDate'],
          startTime: json['startTime'],
          endTime: json['endTime'],
          submittedDate: json['submittedDate'],
          submittedTime: json['submittedTime'],
          score: score,
          totalScore: (json['possibleScore'] ?? 100).toString(),
          status: status,
          answerImage: json['answerImage'],
          filename: json['filename'],
          file: json['file'],
          filenameQ: json['filenameQ'],
          onReminderTap: () => print('Reminder set for ${json['title']}'),
          onViewAnswer: () => print('View answer for ${json['title']}'),
          duration: (json['duration'] ?? 0).toString(),
          description: json['description'] ?? '',
          submittedDescription: json['submittedDescription'],
          estId: json['estid'],
          examId: examId, // ENSURE THIS IS SET CORRECTLY
        );

        print('DEBUG: Created ExamItem with examId=$examId, status=$status');

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

      print(
        'Exams loaded: ${pending.length} pending, ${answered.length} answered, ${scored.length} scored',
      );
    } catch (e) {
      print('Error loading exams: $e');
      throw Exception('خطا در بارگذاری امتحانات: $e');
    }

    return {'pending': pending, 'answered': answered, 'scored': scored};
  }

  // // ==================== EXAMS ====================
  // static Future<Map<String, List<ExamItem>>> getAllExams(int studentId) async {
  //   final pending = <ExamItem>[];
  //   final answered = <ExamItem>[];
  //   final scored = <ExamItem>[];
  //
  //   try {
  //     final response = await http
  //         .get(Uri.parse('$baseUrl/student/exam/$studentId'), headers: _headers)
  //         .timeout(_timeout);
  //
  //     if (response.statusCode != 200) {
  //       throw Exception('خطا: ${response.statusCode}');
  //     }
  //
  //     final List<dynamic> list = json.decode(response.body);
  //
  //     for (var json in list) {
  //       final score = json['score'];
  //       final examDate = json['examDate']; // "1403-09-20"
  //       final endTime = json['endTime']; // "14:30"
  //
  //       // Parse exam end time to determine status
  //       late final ExamStatus status;
  //       try {
  //         // Parse date and time: "1403-09-20" + "14:30"
  //         final dateParts = examDate.split('-');
  //         final timeParts = endTime.split(':');
  //
  //         final jalaliYear = int.parse(dateParts[0]);
  //         final jalaliMonth = int.parse(dateParts[1]);
  //         final jalaliDay = int.parse(dateParts[2]);
  //
  //         final hour = int.parse(timeParts[0]);
  //         final minute = int.parse(timeParts[1]);
  //
  //         // Convert Jalali to Gregorian using shamsi_date package
  //         final jalaliDate = Jalali(jalaliYear, jalaliMonth, jalaliDay);
  //         final gregorianDate = jalaliDate.toGregorian();
  //
  //         final examEndTime = DateTime(
  //           gregorianDate.year,
  //           gregorianDate.month,
  //           gregorianDate.day,
  //           hour,
  //           minute,
  //         );
  //
  //         final now = DateTime.now();
  //
  //         // Determine status based on exam end time
  //         if (now.isBefore(examEndTime)) {
  //           // Exam time hasn't ended yet
  //           status = ExamStatus.pending;
  //         } else if (score == null) {
  //           // Exam time is over but no score yet
  //           status = ExamStatus.answered;
  //         } else {
  //           // Exam time is over and score exists
  //           status = ExamStatus.scored;
  //         }
  //       } catch (e) {
  //         print('Error parsing exam date/time: $e');
  //         // Fallback: use score to determine status
  //         status = score == null ? ExamStatus.answered : ExamStatus.scored;
  //       }
  //
  //       final item = ExamItem(
  //         title: json['title'] ?? 'بدون عنوان',
  //         courseName: json['courseName'] ?? 'نامشخص',
  //         dueDate: json['examDate'],
  //         startTime: json['startTime'],
  //         endTime: json['endTime'],
  //         submittedDate: json['submittedDate'],
  //         submittedTime: json['submittedTime'],
  //         score: score,
  //         totalScore: (json['possibleScore'] ?? 100).toString(),
  //         status: status,
  //         answerImage: json['answerImage'],
  //         filename: json['filename'],
  //         onReminderTap: () => print('Reminder set for ${json['title']}'),
  //         onViewAnswer: () => print('View answer for ${json['title']}'),
  //         duration: (json['duration'] ?? 0).toString(),
  //         description: json['description'] ?? '',
  //         examId: json['id'],
  //       );
  //
  //       switch (status) {
  //         case ExamStatus.pending:
  //           pending.add(item);
  //           break;
  //         case ExamStatus.answered:
  //           answered.add(item);
  //           break;
  //         case ExamStatus.scored:
  //           scored.add(item);
  //           break;
  //       }
  //     }
  //
  //     print(
  //       'Exams loaded: ${pending.length} pending, ${answered.length} answered, ${scored.length} scored',
  //     );
  //   } catch (e) {
  //     print('Error loading exams: $e');
  //     throw Exception('خطا در بارگذاری امتحانات: $e');
  //   }
  //
  //   return {'pending': pending, 'answered': answered, 'scored': scored};
  // }

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
                  (e) =>
                      AssignmentItemm.fromJson({...e as Map<String, dynamic>}),
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

  // ===============================DELETE ASSIGNMENT======================================
  static Future<Map<String, dynamic>> deleteTeacherAssignment(
    int ExamId,
    int teacherId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/teacher/exercises/$ExamId?teacherId=$teacherId',
    );

    try {
      final response = await http
          .delete(url, headers: _headers)
          .timeout(_timeout);

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
  static Future<List<dynamic>> getAssignmentSubmissions(
    int exerciseId,
    int teacherId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/teacher/exercises/$exerciseId/submissions?teacherId=$teacherId',
    );

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

  // ================================= GET EXAMS SUBMISSION(students who answered) =============================
  static Future<List<dynamic>> getExamSubmissions(int examId) async {
    final url = Uri.parse('$baseUrl/teacher/exams/$examId/submissions');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Submissions Status: ${response.statusCode}');
      print('Submissions Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('خطا در دریافت رسالت‌ها: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching submissions: $e');
      throw Exception('خطا: $e');
    }
  }

  // Get exam statistics (pass percentage, average score, etc.)
  static Future<Map<String, dynamic>> getExamStats(int examId) async {
    final url = Uri.parse('$baseUrl/teacher/exams/$examId/stats');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Stats Status: ${response.statusCode}');
      print('Stats Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در دریافت آمار: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stats: $e');
      throw Exception('خطا: $e');
    }
  }

  // Update a single student's exam score
  static Future<Map<String, dynamic>> updateSubmissionScore(
    int submissionId,
    double score,
  ) async {
    final url = Uri.parse(
      '$baseUrl/teacher/exams/submissions/$submissionId/score',
    );

    try {
      final response = await http
          .put(url, headers: _headers, body: json.encode({'score': score}))
          .timeout(_timeout);

      print('Update Score Status: ${response.statusCode}');
      print('Update Score Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در به‌روزرسانی نمره: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating score: $e');
      throw Exception('خطا: $e');
    }
  }

  static Future<Map<String, dynamic>> updateSubmissionScoreEx(
    int submissionId,
    double score,
  ) async {
    final url = Uri.parse(
      '$baseUrl/teacher/exercises/submissions/$submissionId/score',
    );

    try {
      final response = await http
          .put(url, headers: _headers, body: json.encode({'score': score}))
          .timeout(_timeout);

      print('Update Score Status: ${response.statusCode}');
      print('Update Score Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در به‌روزرسانی نمره: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating score: $e');
      throw Exception('خطا: $e');
    }
  }

  // Update multiple students' scores at once
  static Future<Map<String, dynamic>> batchUpdateScores(
    int examId,
    List<Map<String, dynamic>> scores,
  ) async {
    final url = Uri.parse('$baseUrl/teacher/exams/$examId/scores/batch');

    try {
      final response = await http
          .post(url, headers: _headers, body: json.encode(scores))
          .timeout(_timeout);

      print('Batch Update Status: ${response.statusCode}');
      print('Batch Update Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در به‌روزرسانی نمرات: ${response.statusCode}');
      }
    } catch (e) {
      print('Error batch updating scores: $e');
      throw Exception('خطا: $e');
    }
  }

  // ========================= DELETE EXAM ===============================
  static Future<Map<String, dynamic>> deleteTeacherExam(
    int examId,
    int teacherId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/teacher/exams/$examId?teacherId=$teacherId',
    );

    try {
      final response = await http
          .delete(url, headers: _headers)
          .timeout(_timeout);

      print('Delete Exam Status: ${response.statusCode}');
      print('Delete Exam Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در حذف امتحان: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting exam: $e');
      throw Exception('خطا: $e');
    }
  }

  // ====================== ADD ASSIGNMENT WITH FILE ===============================
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
    PlatformFile? file,
    String? fileName,
  }) async {
    final url = Uri.parse('$baseUrl/teacher/exercises');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add form fields
      request.fields['teacherid'] = teacherId.toString();
      request.fields['courseid'] = courseId.toString();
      request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (endDate != null) request.fields['enddate'] = endDate;
      if (endTime != null) request.fields['endtime'] = endTime;
      if (startDate != null) request.fields['startdate'] = startDate;
      if (startTime != null) request.fields['starttime'] = startTime;
      if (score != null) request.fields['score'] = score.toString();
      if (fileName != null) request.fields['filename'] = fileName;

      // Add file if provided
      if (file != null) {
        http.MultipartFile multipartFile;
        if (file.bytes != null) {
          multipartFile = http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: fileName ?? file.name,
          );
        } else if (file.path != null) {
          multipartFile = await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: fileName ?? file.name,
          );
        } else {
          throw Exception('فایل معتبر نیست');
        }
        request.files.add(multipartFile);
      }

      final response = await request.send().timeout(_timeout);

      print('Add Assignment Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('خطا: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('خطا: $e');
    }
  }

  // ========================= UPDATE ASSIGNMENT WITH FILE ================================
  static Future<Map<String, dynamic>> updateTeacherAssignment({
    required int exerciseId,
    required int teacherId,
    String? title,
    String? description,
    String? endDate,
    String? endTime,
    int? score,
    PlatformFile? file,
    String? fileName,
  }) async {
    final url = Uri.parse('$baseUrl/teacher/exercises/$exerciseId');

    try {
      var request = http.MultipartRequest('PUT', url);

      // Add form fields
      request.fields['teacherid'] = teacherId.toString();
      if (title != null) request.fields['title'] = title;
      if (description != null) request.fields['description'] = description;
      if (endDate != null) request.fields['enddate'] = endDate;
      if (endTime != null) request.fields['endtime'] = endTime;
      if (score != null) request.fields['score'] = score.toString();
      if (fileName != null) request.fields['filename'] = fileName;

      // Add file if provided
      if (file != null) {
        http.MultipartFile multipartFile;
        if (file.bytes != null) {
          multipartFile = http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: fileName ?? file.name,
          );
        } else if (file.path != null) {
          multipartFile = await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: fileName ?? file.name,
          );
        } else {
          throw Exception('فایل معتبر نیست');
        }
        request.files.add(multipartFile);
      }

      final response = await request.send().timeout(_timeout);

      print('Update Assignment Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('خطا: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('خطا: $e');
    }
  }

  // ========================= CREATE EXAM WITH FILE ===============================
  static Future<Map<String, dynamic>> createExam({
    required int teacherId,
    required int courseId,
    required String title,
    String? endDate,
    String? endTime,
    String? startDate,
    String? startTime,
    int? possibleScore,
    int? duration,
    String? description,
    PlatformFile? file,
    String? fileName,
  }) async {
    final url = Uri.parse('$baseUrl/teacher/exams');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add form fields
      request.fields['teacherid'] = teacherId.toString();
      request.fields['courseid'] = courseId.toString();
      request.fields['title'] = title;
      if (endDate != null) request.fields['enddate'] = endDate;
      if (endTime != null) request.fields['endtime'] = endTime;
      if (startDate != null) request.fields['startdate'] = startDate;
      if (startTime != null) request.fields['starttime'] = startTime;
      if (possibleScore != null)
        request.fields['possibleScore'] = possibleScore.toString();
      if (duration != null) request.fields['duration'] = duration.toString();
      if (description != null) request.fields['description'] = description;
      if (fileName != null) request.fields['filename'] = fileName;

      // Add file if provided
      if (file != null) {
        http.MultipartFile multipartFile;
        if (file.bytes != null) {
          multipartFile = http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: fileName ?? file.name,
          );
        } else if (file.path != null) {
          multipartFile = await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: fileName ?? file.name,
          );
        } else {
          throw Exception('فایل معتبر نیست');
        }
        request.files.add(multipartFile);
      }

      final response = await request.send().timeout(_timeout);

      print('Create Exam Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('خطا: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('خطا: $e');
    }
  }

  // ========================= UPDATE EXAM WITH FILE ===============================
  static Future<Map<String, dynamic>> updateTeacherExam({
    required int examId,
    required int teacherId,
    String? title,
    String? endDate,
    String? endTime,
    int? possibleScore,
    int? duration,
    String? description,
    PlatformFile? file,
    String? fileName,
  }) async {
    final url = Uri.parse('$baseUrl/teacher/exams/$examId');

    try {
      var request = http.MultipartRequest('PUT', url);

      // Add form fields
      request.fields['teacherid'] = teacherId.toString();
      if (title != null) request.fields['title'] = title;
      if (endDate != null) request.fields['enddate'] = endDate;
      if (endTime != null) request.fields['endtime'] = endTime;
      if (possibleScore != null)
        request.fields['possibleScore'] = possibleScore.toString();
      if (duration != null) request.fields['duration'] = duration.toString();
      if (description != null) request.fields['description'] = description;
      if (fileName != null) request.fields['filename'] = fileName;

      // Add file if provided
      if (file != null) {
        http.MultipartFile multipartFile;
        if (file.bytes != null) {
          multipartFile = http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: fileName ?? file.name,
          );
        } else if (file.path != null) {
          multipartFile = await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: fileName ?? file.name,
          );
        } else {
          throw Exception('فایل معتبر نیست');
        }
        request.files.add(multipartFile);
      }

      final response = await request.send().timeout(_timeout);

      print('Update Exam Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception('خطا: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('خطا: $e');
    }
  }

  //================================= DOWNLOAD ASSIGNMENT FILE ======================
  static Future<Uint8List> downloadAssignmentFile(int submissionId) async {
    final url = Uri.parse('$baseUrl/student/download/assignment/$submissionId');

    try {
      final response = await http.get(url).timeout(_timeout);

      print('Download Assignment Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        throw Exception('فایل یافت نشد');
      } else {
        throw Exception('خطا در دانلود: ${response.statusCode}');
      }
    } catch (e) {
      print('Download Assignment Error: $e');
      throw Exception('خطا در دانلود فایل: $e');
    }
  }

  //================================= DOWNLOAD EXAM FILE ======================
  static Future<Uint8List> downloadExamFile(int submissionId) async {
    final url = Uri.parse('$baseUrl/student/download/exam/$submissionId');

    try {
      final response = await http.get(url).timeout(_timeout);

      print('Download Exam Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        throw Exception('فایل یافت نشد');
      } else {
        throw Exception('خطا در دانلود: ${response.statusCode}');
      }
    } catch (e) {
      print('Download Exam Error: $e');
      throw Exception('خطا در دانلود فایل: $e');
    }
  }

  //================================= SAVE FILE TO DEVICE ======================
  static Future<String> saveFileToDevice(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      // Check if running on web
      if (kIsWeb) {
        // For web, use html package to trigger browser download
        return _downloadFileWeb(fileBytes, fileName);
      }

      // For mobile/desktop platforms
      final directory = await getDownloadsDirectory();

      if (directory == null) {
        throw Exception('دایرکتوری دانلود یافت نشد');
      }

      // Create file path
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Write file to device
      await file.writeAsBytes(fileBytes);

      print('File saved: $filePath');
      return filePath;
    } catch (e) {
      print('Save File Error: $e');
      throw Exception('خطا در ذخیره فایل: $e');
    }
  }

  /// Download file for web platform
  static String _downloadFileWeb(Uint8List fileBytes, String fileName) {
    try {
      // Using dart:html for web
      final blob = html.Blob([fileBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      print('Web download triggered: $fileName');
      return 'Downloaded: $fileName';
    } catch (e) {
      print('Web Download Error: $e');
      throw Exception('خطا در دانلود فایل: $e');
    }
  }

  //================================= DOWNLOAD AND SAVE FILE ======================
  static Future<String> downloadAndSaveFile({
    required String type, // 'assignment' or 'exam'
    required int? submissionId,
    required String fileName,
  }) async {
    try {
      // Download file
      final fileBytes = type == 'assignment'
          ? await downloadAssignmentFile(submissionId!)
          : await downloadExamFile(submissionId!);

      // Save to device (handles both web and mobile)
      final filePath = await saveFileToDevice(fileBytes, fileName);

      return filePath;
    } catch (e) {
      print('Download and Save Error: $e');
      throw Exception('خطا: $e');
    }
  }

  // Add these methods to lib/core/services/api_service.dart

  // ========================= GET EXAM SUBMISSIONS WITH ALL STUDENTS =============================
  static Future<List<dynamic>> getExamStudents(int examId) async {
    final url = Uri.parse('$baseUrl/teacher/exams/$examId/students');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Exam Students Status: ${response.statusCode}');
      print('Exam Students Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('خطا در دریافت دانش‌آموزان: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exam students: $e');
      throw Exception('خطا: $e');
    }
  }

  // ========================= GET EXERCISE SUBMISSIONS WITH ALL STUDENTS =============================
  static Future<List<dynamic>> getExerciseStudents(int exerciseId) async {
    final url = Uri.parse('$baseUrl/teacher/exercises/$exerciseId/students');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Exercise Students Status: ${response.statusCode}');
      print('Exercise Students Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('خطا در دریافت دانش‌آموزان: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exercise students: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Download exam question file (from Exam.File field)
  static Future<Uint8List> downloadExamQuestionFile(int examId) async {
    final url = Uri.parse('$baseUrl/student/download/exam-question/$examId');

    try {
      final response = await http.get(url).timeout(_timeout);

      print('Download Exam Question Status: ${response.statusCode}');
      print('Download Exam Question Body Length: ${response.bodyBytes.length}');

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        throw Exception('فایل سوال یافت نشد');
      } else if (response.bodyBytes.isEmpty) {
        throw Exception('فایل خالی است');
      } else {
        throw Exception('خطا در دانلود: ${response.statusCode}');
      }
    } catch (e) {
      print('Download Exam Question Error: $e');
      throw Exception('خطا در دانلود فایل: $e');
    }
  }

  /// Download assignment question file (from Exercise.File field)
  static Future<Uint8List> downloadAssignmentQuestionFile(
    int assignmentId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/student/download/assignment-question/$assignmentId',
    );

    try {
      final response = await http.get(url).timeout(_timeout);

      print('Download Assignment Question Status: ${response.statusCode}');
      print(
        'Download Assignment Question Body Length: ${response.bodyBytes.length}',
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        throw Exception('فایل تمرین یافت نشد');
      } else if (response.bodyBytes.isEmpty) {
        throw Exception('فایل خالی است');
      } else {
        throw Exception('خطا در دانلود: ${response.statusCode}');
      }
    } catch (e) {
      print('Download Assignment Question Error: $e');
      throw Exception('خطا در دانلود فایل: $e');
    }
  }

  // ========================= CREATE EXAM SCORE FOR STUDENT (NO SUBMISSION) =============================
  static Future<Map<String, dynamic>> createExamScoreForStudent(
    int examId,
    int studentId,
    double score,
  ) async {
    final url = Uri.parse(
      '$baseUrl/teacher/exams/$examId/students/$studentId/score',
    );

    try {
      final response = await http
          .post(url, headers: _headers, body: json.encode({'score': score}))
          .timeout(_timeout);

      print('Create Exam Score Status: ${response.statusCode}');
      print('Create Exam Score Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در ذخیره نمره: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating exam score: $e');
      throw Exception('خطا: $e');
    }
  }

  // ========================= CREATE EXERCISE SCORE FOR STUDENT (NO SUBMISSION) =============================
  static Future<Map<String, dynamic>> createExerciseScoreForStudent(
    int exerciseId,
    int studentId,
    double score,
  ) async {
    final url = Uri.parse(
      '$baseUrl/teacher/exercises/$exerciseId/students/$studentId/score',
    );

    try {
      final response = await http
          .post(url, headers: _headers, body: json.encode({'score': score}))
          .timeout(_timeout);

      print('Create Exercise Score Status: ${response.statusCode}');
      print('Create Exercise Score Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در ذخیره نمره: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating exercise score: $e');
      throw Exception('خطا: $e');
    }
  }

  //================================= SUBMIT EXERCISES ======================
  static Future<void> submitAssignment(
    int userId,
    int assignmentId,
    bool isFile,
    String description,
    PlatformFile? platformFile, {
    required String customFileName,
    bool isUpdate = false,
  }) async {
    final endpoint = isUpdate
        ? '$baseUrl/student/update/assignment/$userId/$assignmentId/$isFile'
        : '$baseUrl/student/submit/assignment/$userId/$assignmentId';

    final url = Uri.parse(endpoint);

    try {
      var request = http.MultipartRequest('POST', url);

      if (description.isNotEmpty) {
        request.fields['description'] = description;
      }

      // Only add file if provided
      if (platformFile != null) {
        http.MultipartFile multipartFile;
        if (platformFile.bytes != null) {
          // For web or bytes-based
          multipartFile = http.MultipartFile.fromBytes(
            'file',
            platformFile.bytes!,
            filename: customFileName,
          );
        } else if (platformFile.path != null) {
          // For mobile/desktop
          multipartFile = await http.MultipartFile.fromPath(
            'file',
            platformFile.path!,
            filename: customFileName,
          );
        } else {
          throw Exception('فایل معتبر نیست: بدون مسیر یا بایت');
        }

        request.files.add(multipartFile);
      }
      // If no file provided, that's OK - submission can happen without file

      final response = await request.send().timeout(_timeout);

      print('Submit Assignment Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return;
      } else {
        final errorBody = await response.stream.bytesToString();
        print('Error Body: $errorBody');
        throw Exception(
          'خطا در ارسال تکلیف: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      print('Submit Assignment Error: $e');
      throw Exception('خطا در ارسال: $e');
    }
  }

  //================================= SUBMIT EXAM ==========================
  static Future<void> submitExam(
    int userId,
    int examId,
    bool isFile,
    String description,
    PlatformFile? platformFile, {
    required String customFileName,
    bool isUpdate = false,
  }) async {
    final url = Uri.parse(
      '$baseUrl/student/submit/exam/$userId/$examId/$isFile',
    );

    try {
      var request = http.MultipartRequest('POST', url);

      // Add the isUpdate flag as form field
      request.fields['isUpdate'] = isUpdate.toString().toLowerCase();

      if (description.isNotEmpty) {
        request.fields['description'] = description;
      }

      // Only add file if provided
      if (platformFile != null) {
        http.MultipartFile multipartFile;
        if (platformFile.bytes != null) {
          multipartFile = http.MultipartFile.fromBytes(
            'file',
            platformFile.bytes!,
            filename: customFileName,
          );
        } else if (platformFile.path != null) {
          multipartFile = await http.MultipartFile.fromPath(
            'file',
            platformFile.path!,
            filename: customFileName,
          );
        } else {
          throw Exception('فایل معتبر نیست: بدون مسیر یا بایت');
        }

        request.files.add(multipartFile);
      }
      // If no file provided, that's OK - submission can happen without file

      print('=== SUBMIT EXAM REQUEST ===');
      print('URL: ${request.url}');
      print('isUpdate field: ${request.fields['isUpdate']}');
      print('File: ${platformFile?.name ?? "NO FILE"}');

      final response = await request.send().timeout(_timeout);

      print('Submit Exam Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');
        return;
      } else {
        final errorBody = await response.stream.bytesToString();
        print('Error Body: $errorBody');
        throw Exception(
          'خطا در ارسال آزمون: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      print('Submit Exam Error: $e');
      throw Exception('خطا در ارسال: $e');
    }
  }

  static Future<Map<String, dynamic>> getAssignmentStats(
    int assignmentId,
  ) async {
    final url = Uri.parse('$baseUrl/assignments/$assignmentId/stats');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Assignment Stats Status: ${response.statusCode}');
      print('Assignment Stats Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در دریافت آمار تکلیف: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('خطا: $e');
    }
  }

  // ==================== ADMIN CLASS SCORES ====================

  /// Get all classes with basic statistics
  static Future<List<dynamic>> getAdminClasses() async {
    final url = Uri.parse('$baseUrl/admin/classes');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Admin Classes Status: ${response.statusCode}');
      print('Admin Classes Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطا در دریافت کلاس‌ها: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching admin classes: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Get overview statistics for all classes
  static Future<List<dynamic>> getAdminOverview() async {
    final url = Uri.parse('$baseUrl/admin/overview');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Admin Overview Status: ${response.statusCode}');
      print('Admin Overview Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطا در دریافت آمار کلی: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching admin overview: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Get detailed statistics for a specific class
  /// Returns: {
  ///   id, name, grade, capacity, totalStudents, avgScore, passPercentage,
  ///   scoreRanges: [{range, count, percentage}, ...],
  ///   subjectScores: [{name, avgScore, totalCount}, ...],
  ///   topPerformers: [{studentId, name, avgScore, rank}, ...]
  /// }
  static Future<Map<String, dynamic>> getClassStatistics(int classId) async {
    final url = Uri.parse('$baseUrl/admin/class/$classId/statistics');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Class Statistics Status: ${response.statusCode}');
      print('Class Statistics Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('کلاس یافت نشد');
      } else {
        throw Exception('خطا: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching class statistics: $e');
      throw Exception('خطا در دریافت آمار کلاس: $e');
    }
  }

  /// Get monthly trend for a class
  /// Returns: [{month, avgScore, count}, ...]
  static Future<List<dynamic>> getClassMonthlyTrend(int classId) async {
    final url = Uri.parse('$baseUrl/admin/class/$classId/monthly-trend');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Monthly Trend Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطا در دریافت روند ماهانه: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching monthly trend: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Get comparison data for all classes
  /// Returns: [{id, name, grade, studentCount, avgScore, passPercentage}, ...]
  static Future<List<dynamic>> getClassesComparison() async {
    final url = Uri.parse('$baseUrl/admin/classes-comparison');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Classes Comparison Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطا در مقایسه کلاس‌ها: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching classes comparison: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Get detailed student list for a class
  /// Returns: [{id, name, stuCode, avgScore, scoreCount}, ...]
  static Future<List<dynamic>> getClassStudents(int classId) async {
    final url = Uri.parse('$baseUrl/admin/class/$classId/students');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Class Students Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطا در دریافت دانش‌آموزان: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching class students: $e');
      throw Exception('خطا: $e');
    }
  }

  // ==================== STUDENTS ====================

  /// Get all students
  static Future<List<dynamic>> getAllStudents() async {
    final url = Uri.parse('$baseUrl/admin/students');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Get All Students Status: ${response.statusCode}');
      print('Get All Students Body: ${response.body}');

      if (response.statusCode == 200) {
        // ✅ FIX: Handle both array and object responses
        final dynamic decoded = json.decode(response.body);

        // If response is already a list, return it directly
        if (decoded is List) {
          return decoded as List<dynamic>;
        }

        // If response is an object with 'data' field (paginated)
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'];
          if (data is List) {
            return data as List<dynamic>;
          }
        }

        // Fallback: empty list if format is unexpected
        print('Unexpected response format: ${decoded.runtimeType}');
        return [];
      } else {
        throw Exception('خطا در دریافت دانش‌آموزان: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching students: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Get student by ID
  static Future<Map<String, dynamic>> getStudentById(int studentId) async {
    final url = Uri.parse('$baseUrl/admin/students/$studentId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Get Student Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('دانش‌آموز یافت نشد');
      } else {
        throw Exception('خطا: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching student: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Create new student
  static Future<Map<String, dynamic>> createStudent({
    required String name,
    required String studentCode,
    required String stuClass,
    required String phone,
    required String parentPhone,
    required String birthDate,
    required String address,
    required int debt,
  }) async {
    final url = Uri.parse('$baseUrl/admin/students');

    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: json.encode({
              'name': name,
              'studentCode': studentCode,
              'classId': stuClass, // ✅ Changed from 'class' to 'classId'
              'phone': phone,
              'parentPhone': parentPhone,
              'birthDate': birthDate,
              'address': address,
              'debt': debt,
            }),
          )
          .timeout(_timeout);

      print('Create Student Status: ${response.statusCode}');
      print('Create Student Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در ایجاد دانش‌آموز: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating student: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Update student
  static Future<Map<String, dynamic>> updateStudent({
    required int studentId,
    required String name,
    required String studentCode,
    required String stuClass,
    required String phone,
    required String parentPhone,
    required String birthDate,
    required String address,
    required int debt,
  }) async {
    final url = Uri.parse('$baseUrl/admin/students/$studentId');

    try {
      final response = await http
          .put(
            url,
            headers: _headers,
            body: json.encode({
              'name': name,
              'studentCode': studentCode,
              'classId': stuClass, // ✅ Changed from 'class' to 'classId'
              'phone': phone,
              'parentPhone': parentPhone,
              'birthDate': birthDate,
              'address': address,
              'debt': debt,
            }),
          )
          .timeout(_timeout);

      print('Update Student Status: ${response.statusCode}');
      print('Update Student Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('دانش‌آموز یافت نشد');
      } else {
        throw Exception('خطا در به‌روزرسانی: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating student: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Delete student
  static Future<Map<String, dynamic>> deleteStudent(int studentId) async {
    final url = Uri.parse('$baseUrl/admin/students/$studentId');

    try {
      final response = await http
          .delete(url, headers: _headers)
          .timeout(_timeout);

      print('Delete Student Status: ${response.statusCode}');
      print('Delete Student Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('دانش‌آموز یافت نشد');
      } else {
        throw Exception('خطا در حذف: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting student: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Get student stats
  static Future<Map<String, dynamic>> getStudentStats() async {
    final url = Uri.parse('$baseUrl/admin/students-stats');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Get Student Stats Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('خطا در دریافت آمار: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching student stats: $e');
      throw Exception('خطا: $e');
    }
  }

  /// Search students
  static Future<List<dynamic>> searchStudents(String query) async {
    final url = Uri.parse('$baseUrl/admin/students/search?query=$query');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Search Students Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطا در جستجو: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching students: $e');
      throw Exception('خطا: $e');
    }
  }

  // ==================== GET ALL CLASSES ====================
  static Future<List<dynamic>> getAllClasses() async {
    final url = Uri.parse('$baseUrl/admin/classes');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Get All Classes Status: ${response.statusCode}');
      print('Get All Classes Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('خطا در دریافت کلاس‌ها: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching classes: $e');
      throw Exception('خطا: $e');
    }
  }

  // ==================== GET CLASS BY ID ====================
  static Future<Map<String, dynamic>> getClassById(int classId) async {
    final url = Uri.parse('$baseUrl/admin/classes/$classId');

    try {
      final response = await http.get(url, headers: _headers).timeout(_timeout);

      print('Get Class Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('کلاس یافت نشد');
      } else {
        throw Exception('خطا: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching class: $e');
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
