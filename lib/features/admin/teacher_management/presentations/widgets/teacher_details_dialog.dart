import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../../../../core/services/api_service.dart';
import '../../data/models/course_model.dart';
import '../../data/models/teacher_model.dart';

class TeacherDetailsDialog extends StatefulWidget {
  final TeacherModel teacher;

  const TeacherDetailsDialog({super.key, required this.teacher});

  @override
  State<TeacherDetailsDialog> createState() => _TeacherDetailsDialogState();
}

class _TeacherDetailsDialogState extends State<TeacherDetailsDialog> {
  List<CourseModel>? _teacherCourses;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTeacherCourses();
  }

  Future<void> _loadTeacherCourses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teacherId = widget.teacher.teacherId;
      print('Loading courses for teacher ID: $teacherId');

      final courses = await ApiService().getTeacherCourses(teacherId);

      if (mounted) {
        setState(() {
          _teacherCourses = courses;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load teacher courses: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'ناتوانی در بارگذاری دروس معلم';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'خطا رخ داد'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return
    // title: Row(
    //   children: [
    //     const Icon(Icons.person, color: AppColor.purple),
    //     const SizedBox(width: 12),
    //     Expanded(
    //       child: Text(
    //         widget.teacher.name,
    //         style: const TextStyle(fontWeight: FontWeight.bold),
    //       ),
    //     ),
    //   ],
    // ),
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.purple.withOpacity(0.8),
                      AppColor.purple.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.purple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.teacher.name.isNotEmpty
                        ? widget.teacher.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                widget.teacher.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),

              // ─── Login Credentials Section ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.vpn_key_rounded,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'اطلاعات ورود',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCredentialRow(
                      'نام کاربری',
                      widget.teacher.username ?? '—',
                    ),
                    const SizedBox(height: 8),
                    _buildCredentialRow(
                      'رمز عبور',
                      widget.teacher.password ?? '—',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Teacher Details ───
              _buildDetailRow(
                'شناسه',
                widget.teacher.teacherId.toString(),
                Icons.badge,
              ),
              _buildDetailRow(
                'شماره موبایل',
                widget.teacher.phone ?? 'ثبت نشده',
                Icons.phone,
                canCopy: true,
              ),
              _buildDetailRow(
                'کد ملی',
                widget.teacher.nationalCode ?? 'ثبت نشده',
                Icons.credit_card,
                canCopy: true,
              ),
              _buildDetailRow(
                'ایمیل',
                widget.teacher.email ?? 'ثبت نشده',
                Icons.email,
                canCopy: true,
              ),
              _buildDetailRow(
                'تخصص',
                widget.teacher.specialty ?? 'ثبت نشده',
                Icons.psychology,
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // ─── Assigned Courses Section ───
              Text(
                'دروس تدریس شده',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColor.purple,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),

              if (_isLoading)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                )
              else if (_teacherCourses == null || _teacherCourses!.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'هیچ درسی ثبت نشده است',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                )
              else
                ..._teacherCourses!.map(
                  (course) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.book_outlined,
                          size: 18,
                          color: AppColor.purple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            course.name ?? 'بدون عنوان',
                            style: const TextStyle(fontSize: 14),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.purple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'بستن',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 13),
            textDirection: TextDirection.rtl,
          ),
        ),
        _buildCopyButton(value),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool canCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColor.purple, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColor.lightGray,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    if (canCopy && value != 'ثبت نشده') _buildCopyButton(value),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(String text) {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.copy_rounded, size: 16),
        color: AppColor.purple,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('کپی شد', textDirection: TextDirection.rtl),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
