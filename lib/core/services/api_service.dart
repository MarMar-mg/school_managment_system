// core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5105/api';

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'Username': username,
          'Password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

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
}