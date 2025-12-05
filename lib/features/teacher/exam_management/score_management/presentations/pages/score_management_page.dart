// lib/features/teacher/score_management/presentations/pages/score_management_page.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/features/teacher/exam_management/data/models/exam_model.dart';

class ScoreManagementPage extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const ScoreManagementPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<ScoreManagementPage> createState() => _ScoreManagementPageState();
}

class _ScoreManagementPageState extends State<ScoreManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  String _selectedType = 'exam';

  List<ExamModelT> _exams = [];
  List<dynamic> _assignments = [];

  dynamic _selectedItem;
  List<dynamic> _selectedItemSubmissions = [];

  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final exams = await ApiService.getTeacherExams(widget.userId);
      final assignments =
      await ApiService.getTeacherAssignments(widget.userId);

      setState(() {
        _exams = exams;
        _assignments = assignments;
        _isLoading = false;
      });

      _controller.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubmissions(dynamic item) async {
    setState(() {
      _selectedItem = item;
      _isLoading = true;
    });

    try {
      late List<dynamic> submissions;

      if (_selectedType == 'exam') {
        final exam = item as ExamModelT;
        submissions = await ApiService.getExamSubmissions(exam.id);
      } else {
        submissions = await ApiService.getAssignmentSubmissions(
          item['id'],
          widget.userId,
        );
      }

      setState(() {
        _selectedItemSubmissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ResponsiveContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                _buildClassSelection(),
                const SizedBox(height: 24),

                _buildTypeSelector(),
                const SizedBox(height: 24),

                _buildItemSelector(),
                const SizedBox(height: 24),

                if (_selectedItem != null)
                  _buildSubmissionsView()
                else
                  _buildEmptyState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'مدیریت نمرات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 4),
        Text(
          'تصحیح و پیگیری نمرات دانش‌آموزان',
          style: TextStyle(
            fontSize: 13,
            color: AppColor.lightGray,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'انتخاب کلاس',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.expand_more, color: AppColor.lightGray),
              Text(
                'ریاضی - ۲ - پخش الف',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'نوع ارزیابی',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  'امتحانات',
                  'exam',
                  Icons.description_outlined,
                ),
              ),
              Expanded(
                child: _buildTypeButton(
                  'تمرین‌ها',
                  'assignment',
                  Icons.assignment_outlined,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String label, String type, IconData icon) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedItem = null;
          _selectedItemSubmissions = [];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.purple.withOpacity(0.1) : Colors.transparent,
          border: isSelected
              ? Border(
            top: BorderSide(color: AppColor.purple, width: 3),
          )
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColor.purple : AppColor.lightGray,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColor.purple : AppColor.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSelector() {
    final items = _selectedType == 'exam' ? _exams : _assignments;

    if (_isLoading && items.isEmpty) {
      return _buildShimmerLoader();
    }

    if (items.isEmpty) {
      return _buildEmptyItemsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'انتخاب ${_selectedType == 'exam' ? 'امتحان' : 'تمرین'}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: _selectedItem,
              hint: Text(
                '${_selectedType == 'exam' ? 'امتحان' : 'تمرین'} را انتخاب کنید',
                textDirection: TextDirection.rtl,
              ),
              isExpanded: true,
              items: items.map<DropdownMenuItem<dynamic>>((item) {
                // Handle both ExamModelT and Map types
                late final String title;
                late final String description;

                if (item is ExamModelT) {
                  title = item.title ?? 'بدون عنوان';
                  description = item.description ?? '';
                } else {
                  title = item['title'] ?? 'بدون عنوان';
                  description = item['description'] ?? '';
                }

                return DropdownMenuItem<dynamic>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.lightGray,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _loadSubmissions(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmissionsView() {
    if (_isLoading) {
      return _buildShimmerLoader();
    }

    if (_error.isNotEmpty) {
      return _buildErrorState();
    }

    if (_selectedItemSubmissions.isEmpty) {
      return _buildNoSubmissionsState();
    }

    // Get title based on item type
    late final String itemTitle;
    late final dynamic maxScore;

    if (_selectedItem is ExamModelT) {
      final exam = _selectedItem as ExamModelT;
      itemTitle = exam.title ?? 'بدون عنوان';
      maxScore = exam.possibleScore;
    } else {
      itemTitle = _selectedItem['title'] ?? 'بدون عنوان';
      final score = _selectedItem['possibleScore'] ?? _selectedItem['score'] ?? 100;
      maxScore = score is String ? int.tryParse(score) ?? 100 : score;
    }

    int graded = 0;
    int submitted = 0;
    for (var sub in _selectedItemSubmissions) {
      if (sub['score'] != null) graded++;
      if (sub['answerImage'] != null || sub['filename'] != null) submitted++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ارسال شده: $submitted',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    itemTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkText,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedType == 'exam' ? 'امتحان' : 'تمرین'} - حداکثر امتیاز: $maxScore',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.lightGray,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'نمره',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.lightGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'وضعیت',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.lightGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'نام دانش‌آموز',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.lightGray,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              ...List.generate(
                _selectedItemSubmissions.length,
                    (index) {
                  final submission = _selectedItemSubmissions[index];
                  final studentName =
                      submission['studentName'] ?? 'نامشخص';
                  final score = submission['score'];
                  final hasFile = submission['answerImage'] != null ||
                      submission['filename'] != null;

                  return Container(
                    decoration: BoxDecoration(
                      border: index != _selectedItemSubmissions.length - 1
                          ? Border(
                        bottom:
                        BorderSide(color: Colors.grey.shade200),
                      )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              score != null ? '$score' : '-',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: score != null
                                    ? AppColor.darkText
                                    : AppColor.lightGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: hasFile
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  hasFile ? 'ارسال شده' : 'ارسال نشده',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: hasFile ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Text(
                              studentName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColor.darkText,
                              ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                'پایین‌ترین',
                '72',
                AppColor.purple,
                Icons.trending_down_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBox(
                'بالاترین',
                '95',
                Colors.green,
                Icons.trending_up_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBox(
                'میانگین',
                '85.8',
                AppColor.purple,
                Icons.equalizer_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStatBox(
      String label,
      String value,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColor.lightGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedType == 'exam' ? 'امتحان' : 'تمرین'} را انتخاب کنید',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'نمرات و وضعیت ارسال دانش‌آموزان نمایش داده خواهد شد',
              style: TextStyle(
                fontSize: 13,
                color: AppColor.lightGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              'هیچ ${_selectedType == 'exam' ? 'امتحان' : 'تمرین'} ایی یافت نشد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSubmissionsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColor.lightGray,
            ),
            const SizedBox(height: 16),
            Text(
              'هنوز پاسخی ارسال نشده',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'خطا در بارگذاری',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error.replaceFirst('Exception: ', ''),
              style: TextStyle(
                fontSize: 13,
                color: AppColor.lightGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}