// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // CHANGE THIS TO YOUR MACHINE'S IP (real device) OR keep localhost for emulator
  // Android Emulator: 10.0.2.2
  // iOS Simulator / Web: localhost
  // Real device: http://192.168.x.x:5105/api
  static const String baseUrl = 'http://localhost:5105/api';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ===================================================================
  // AUTH
  // ===================================================================
  static Future<Map<String, dynamic>> login(
      String username,
      String password,
      ) async {
    final http.Response response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  // ===================================================================
  // STUDENT
  // ===================================================================
  static Future<Map<String, dynamic>> getStudentDashboard(int userId) async {
    return _get('$baseUrl/student/dashboard/$userId');
  }

  static Future<List<dynamic>> getStudentExercises(int studentId) async {
    return _getList('$baseUrl/student/exercises/$studentId');
  }

  static Future<List<dynamic>> getStudentExams(int studentId) async {
    return _getList('$baseUrl/student/exams/$studentId');
  }

  static Future<Map<String, dynamic>> getStudentProfile(int studentId) async {
    return _get('$baseUrl/student/profile/$studentId');
  }

  // ===================================================================
  // TEACHER
  // ===================================================================
  static Future<Map<String, dynamic>> getTeacherDashboard(int teacherId) async {
    return _get('$baseUrl/teacher/dashboard/$teacherId');
  }

  static Future<List<dynamic>> getTeacherStudents(int teacherId) async {
    return _getList('$baseUrl/teacher/students/$teacherId');
  }

  // ===================================================================
  // NEWS
  // ===================================================================
  static Future<List<dynamic>> getNews() async {
    return _getList('$baseUrl/news');
  }

  static Future<Map<String, dynamic>> getNewsById(int newsId) async {
    return _get('$baseUrl/news/$newsId');
  }

  static Future<Map<String, dynamic>> createNews(Map<String, dynamic> news) async {
    return _post('$baseUrl/news', news);
  }

  // ===================================================================
  // EVENTS (Calendar)
  // ===================================================================
  static Future<List<dynamic>> getEvents() async {
    return _getList('$baseUrl/calender');
  }

  static Future<Map<String, dynamic>> createEvent(Map<String, dynamic> event) async {
    return _post('$baseUrl/calender', event);
  }

  // ===================================================================
  // COURSES
  // ===================================================================
  static Future<List<dynamic>> getCourses() async {
    return _getList('$baseUrl/course');
  }

  static Future<Map<String, dynamic>> getCourseById(int courseId) async {
    return _get('$baseUrl/course/$courseId');
  }

  // ===================================================================
  // CLASSES
  // ===================================================================
  static Future<List<dynamic>> getClasses() async {
    return _getList('$baseUrl/classes');
  }

  // ===================================================================
  // PRIVATE HELPERS
  // ===================================================================
  static Future<Map<String, dynamic>> _get(String url) async {
    final http.Response response = await http.get(Uri.parse(url), headers: _headers);
    return _handleResponse(response);
  }

  static Future<List<dynamic>> _getList(String url) async {
    final http.Response response = await http.get(Uri.parse(url), headers: _headers);
    final dynamic data = _handleResponse(response);
    return data is List ? data : [data];
  }

  static Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> body) async {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final String error = _tryParseError(response);
      throw Exception(error);
    }
  }

  static String _tryParseError(http.Response response) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return json['message']?.toString() ??
          json['error']?.toString() ??
          'خطای ناشناخته';
    } catch (_) {
      return 'خطا در سرور: ${response.statusCode}';
    }
  }
}