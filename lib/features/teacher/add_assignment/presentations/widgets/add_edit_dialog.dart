import 'package:flutter/material.dart';
import 'package:school_management_system/commons/untils.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../core/services/api_service.dart';

void showAddEditDialog(
    BuildContext context, {
      dynamic assignment,
      required int userId,
      required VoidCallback addData,
      required bool isAdd,
      required List<Map<String, dynamic>> courses,
    }) {
  showDialog(
    context: context,
    builder: (context) {
      return _AddEditDialogContent(
        assignment: assignment,
        courses: courses,
        userId: userId,
        addData: addData,
        isAdd: isAdd,
      );
    },
  );
}

class _AddEditDialogContent extends StatefulWidget {
  final dynamic assignment;
  final int userId;
  final bool isAdd;
  final VoidCallback addData;
  final List<Map<String, dynamic>> courses;

  const _AddEditDialogContent({
    required this.assignment,
    required this.courses,
    required this.userId,
    required this.addData,
    required this.isAdd,
  });

  @override
  State<_AddEditDialogContent> createState() => _AddEditDialogContentState();
}

class _AddEditDialogContentState extends State<_AddEditDialogContent>
    with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _scoreController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  String? _selectedClass;
  String? _selectedSubject;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  late AnimationController _enterController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _titleController = TextEditingController(
      text: widget.assignment?['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.assignment?['description'] ?? '',
    );
    _scoreController = TextEditingController(
      text: widget.assignment?['score']?.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: widget.assignment?['dueDate'] ?? '',
    );
    _timeController = TextEditingController(
      text: widget.assignment?['dueTime'] ?? '',
    );

    _selectedClass = widget.assignment?['classId'];
    _selectedSubject = widget.assignment?['subject'];

    // Enter animation
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
        );

    _enterController.forward();
  }

  Future<void> _addData({
    required int courseId,
    required String title,
    String? description,
    String? endDate,
    String? endTime,
    int? score,
  }) async {
    try {
      // setState(() => _isLoading = true);

      // Call the API to add a new assignment
      final result = await ApiService.addTeacherAssignment(
        teacherId: widget.userId,
        courseId: courseId,
        title: title,
        description: description,
        endDate: endDate,
        endTime: endTime,
        startDate:
        '${Jalali.now().formatter.yyyy}-${Jalali.now().formatter.mm}-${Jalali.now().formatter.dd}',
        startTime:
        '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
        score: score,
      );

      // Optionally, print or log the result
      print('Assignment added: $result');
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  Future<void> _editData({
    required String title,
    String? description,
    String? endDate,
    String? endTime,
    int? score,
  }) async {
    try {
      // setState(() => _isLoading = true);

      // Call the API to add a new assignment
      final result = await ApiService.updateTeacherAssignment(
        exerciseId: widget.assignment?['id'],
        teacherId: widget.userId,
        title: title,
        description: description,
        endDate: endDate,
        endTime: endTime,
        score: score,
      );

      // Optionally, print or log the result
      print('Assignment edited: $result');
    } catch (e) {
      throw Exception('خطا: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scoreController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        final jalali = Jalali.fromDateTime(picked);
        _dateController.text =
        '${jalali.formatter.yyyy}-${jalali.formatter.mm}-${jalali.formatter.dd}';
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.assignment == null
                          ? 'ایجاد تمرین جدید'
                          : 'ویرایش تمرین',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Class dropdown
                widget.isAdd
                    ? Text(
                  'انتخاب کلاس',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textDirection: TextDirection.rtl,
                )
                    : SizedBox(),
                const SizedBox(height: 8),
                widget.isAdd
                    ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedClass,
                    hint: const Text(
                      'درس را انتخاب کنید',
                      textDirection: TextDirection.rtl,
                    ),
                    isExpanded: true,
                    underline: const SizedBox(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: widget.courses.map((course) {
                      return DropdownMenuItem(
                        value: course['id'].toString(),
                        child: Text(
                          course['name'] ?? 'نام نامشخص',
                          textDirection: TextDirection.rtl,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedClass = value);
                    },
                  ),
                )
                    : SizedBox(),
                const SizedBox(height: 20),

                // Title
                Text(
                  'عنوان تمرین',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'مثال تمرین ۱ - مثلثات',
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C3AED),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'توضیحات',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'دستورالعمل و توضیحات تمرین را بنویسید...',
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C3AED),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Score
                Text(
                  'امتیاز',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'نمره(100)',
                    hintTextDirection: TextDirection.rtl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF7C3AED),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Date and Time
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تاریخ تحویل',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectDate,
                            child: TextField(
                              controller: _dateController,
                              enabled: false,
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                hintText: 'تاریخ را انتخاب کنید',
                                hintTextDirection: TextDirection.rtl,
                                suffixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ساعت تحویل',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _selectTime,
                            child: TextField(
                              controller: _timeController,
                              enabled: false,
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                hintText: 'ساعت را انتخاب کنید',
                                hintTextDirection: TextDirection.rtl,
                                suffixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'انصراف',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              widget.isAdd
                                  ? _addData(
                                courseId: _selectedClass!.toInt(),
                                // ID of the selected course
                                title: _titleController.text,
                                // Assignment title
                                description: _descriptionController.text,
                                // Optional
                                endDate: _dateController.text,
                                // Optional
                                endTime: _timeController.text,
                                // Optional
                                score: _scoreController.text
                                    .toInt(), // Optional
                              )
                                  : _editData(
                                title: _titleController.text,
                                // Assignment title
                                description: _descriptionController.text,
                                // Optional
                                endDate: _dateController.text,
                                // Optional
                                endTime: _timeController.text,
                                // Optional
                                score: _scoreController.text
                                    .toInt(), // Optional
                              );
                            });
                            widget.addData();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'ایجاد تمرین',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
