// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart';
// import '../../../applications/role.dart';
//
// class AuthProvider with ChangeNotifier {
//   int? _userId;
//   String? _userName;
//   Role? _userRole;
//   bool _isLoading = false;
//
//   int? get userId => _userId;
//   String? get userName => _userName;
//   Role? get userRole => _userRole;
//   bool get isLoading => _isLoading;
//   bool get isAuthenticated => _userId != null;
//
//   Future<bool> login(int username, String password, String role) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final response = await ApiService.login(username, password, role);
//
//       _userId = response['userId'];
//       _userName = response['fullName'];
//       _userRole = _roleFromString(response['role']);
//
//       // Save to SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('userId', _userId!);
//       await prefs.setString('userName', _userName!);
//       await prefs.setString('userRole', response['role']);
//
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
//
//   Future<void> loadUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     _userId = prefs.getInt('userId');
//     _userName = prefs.getString('userName');
//     final roleStr = prefs.getString('userRole');
//     if (roleStr != null) {
//       _userRole = _roleFromString(roleStr);
//     }
//     notifyListeners();
//   }
//
//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     _userId = null;
//     _userName = null;
//     _userRole = null;
//     notifyListeners();
//   }
//
//   Role _roleFromString(String role) {
//     switch (role.toLowerCase()) {
//       case 'student':
//         return Role.student;
//       case 'teacher':
//         return Role.teacher;
//       case 'admin':
//         return Role.admin;
//       default:
//         return Role.student;
//     }
//   }
// }