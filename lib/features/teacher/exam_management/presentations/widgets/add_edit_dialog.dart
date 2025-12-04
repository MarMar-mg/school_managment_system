import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../applications/colors.dart';
import '../../../../../commons/shamsi_date_picker_dialog.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/services/api_service.dart';

/// Show add/edit exam dialog
void showAddEditExamDialog(
  BuildContext context, {
  dynamic exam,
  required int userId,
  required VoidCallback onSuccess,
  required bool isAdd,
  required List<Map<String, dynamic>> courses,
}) {
  showDialog(
    context: context,
    builder: (context) => _AddEditExamDialogContent(
      exam: exam,
      courses: courses,
      userId: userId,
      onSuccess: onSuccess,
      isAdd: isAdd,
    ),
  );
}

class _AddEditExamDialogContent extends StatefulWidget {
  final dynamic exam;
  final int userId;
  final bool isAdd;
  final VoidCallback onSuccess;
  final List<Map<String, dynamic>> courses;

  const _AddEditExamDialogContent({
    required this.exam,
    required this.courses,
    required this.userId,
    required this.onSuccess,
    required this.isAdd,
  });

  @override
  State<_AddEditExamDialogContent> createState() =>
      _AddEditExamDialogContentState();
}

class _AddEditExamDialogContentState extends State<_AddEditExamDialogContent>
    with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _scoreController;
  late TextEditingController _dateController;
  late TextEditingController _fileNameController;
  late TextEditingController _timeController;

  String? _selectedCourse;
  Jalali? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  PlatformFile? _selectedFile;
  bool _fileChanged = false;

  late AnimationController _enterController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    _fileNameController = TextEditingController(
      text: widget.exam?['filename'] ?? '',
    );
    print('_fileNameController.text');
    print(_fileNameController.text);
    _titleController = TextEditingController(text: widget.exam?['title'] ?? '');
    _descriptionController = TextEditingController(
      text: widget.exam?['description'] ?? '',
    );
    _durationController = TextEditingController(
      text: widget.exam?['duration']?.toString() ?? '',
    );
    _scoreController = TextEditingController(
      text: widget.exam?['possibleScore']?.toString() ?? '100',
    );
    _dateController = TextEditingController(text: widget.exam?['date'] ?? '');
    _timeController = TextEditingController(
      text: widget.exam?['classTime'] ?? '',
    );

    _selectedCourse = widget.exam?['courseId']?.toString();

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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _scoreController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _enterController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDialog<Jalali>(
      context: context,
      builder: (context) => ShamsiDatePickerDialog(
        initialDate: _selectedDate ?? Jalali.now(),
        firstDate: Jalali(1400, 1, 1),
        lastDate: Jalali(1410, 12, 29),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final platformFile = result.files.single;
      setState(() {
        _selectedFile = platformFile;
        _fileNameController.text = platformFile.name;
        _fileChanged = true;
      });
      print('File selected: ${platformFile.name}');
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
      _fileChanged = false;
      _fileNameController.clear();
    });
  }

  // Update _submit method:
  Future<void> _submit() async {
    if (_titleController.text.isEmpty) {
      _showError('لطفا عنوان امتحان را وارد کنید');
      return;
    }
    if (_dateController.text.isEmpty) {
      _showError('لطفا تاریخ امتحان را انتخاب کنید');
      return;
    }
    if (_timeController.text.isEmpty) {
      _showError('لطفا ساعت امتحان را انتخاب کنید');
      return;
    }
    if (widget.isAdd && _selectedCourse == null) {
      _showError('لطفا درس را انتخاب کنید');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isAdd) {
        final endTime = _durationController.text.isNotEmpty
            ? addDurationToTime(
                _timeController.text,
                int.tryParse(_durationController.text) ?? 0,
              )
            : _timeController.text;

        await ApiService.createExam(
          teacherId: widget.userId,
          courseId: int.tryParse(_selectedCourse ?? '0') ?? 0,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _dateController.text,
          startTime: _timeController.text,
          endDate: _dateController.text,
          endTime: endTime,
          duration: int.tryParse(_durationController.text),
          possibleScore: int.tryParse(_scoreController.text) ?? 100,
          file: _selectedFile,
          fileName: _fileNameController.text.isNotEmpty
              ? _fileNameController.text
              : null,
        );

        if (mounted) {
          _showSuccess('امتحان با موفقیت ایجاد شد');
        }
      } else {
        final endTime = _durationController.text.isNotEmpty
            ? addDurationToTime(
                _timeController.text,
                int.tryParse(_durationController.text) ?? 0,
              )
            : _timeController.text;

        await ApiService.updateTeacherExam(
          examId: widget.exam?['id'] ?? widget.exam['examId'],
          teacherId: widget.userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          endDate: _dateController.text,
          endTime: endTime,
          duration: int.tryParse(_durationController.text),
          possibleScore: int.tryParse(_scoreController.text) ?? 100,
          file: _selectedFile,
          fileName: _fileNameController.text.isNotEmpty
              ? _fileNameController.text
              : null,
        );

        if (mounted) {
          _showSuccess('امتحان با موفقیت به‌روزرسانی شد');
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        widget.onSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String addDurationToTime(String startTime, int durationMinutes) {
    try {
      // Parse the start time (assumes "HH:MM" format)
      final parts = startTime.split(':');
      if (parts.length != 2) {
        return startTime; // Return original time if invalid format
      }

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // Calculate total minutes and add duration
      int totalMinutes = (hour * 60) + minute + durationMinutes;

      // Compute new hour and minute (wrap around 24 hours if needed)
      int newHour = (totalMinutes ~/ 60) % 24;
      int newMinute = totalMinutes % 60;

      // Format as "HH:MM"
      return '${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error calculating duration: $e');
      return startTime;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      widget.isAdd ? 'ایجاد امتحان جدید' : 'ویرایش امتحان',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: _isLoading ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Course dropdown (only for add)
                if (widget.isAdd) ...[
                  _buildLabel('انتخاب درس'),
                  const SizedBox(height: 8),
                  _buildCourseDropdown(),
                  const SizedBox(height: 20),
                ],

                // Title
                _buildLabel('عنوان امتحان'),
                const SizedBox(height: 8),
                _buildTextField(
                  _titleController,
                  1,
                  'مثال: آزمون ریاضی میان‌ترم',
                ),
                const SizedBox(height: 20),

                // Subject
                _buildLabel('توضیحات'),
                const SizedBox(height: 8),
                _buildTextField(
                  _descriptionController,
                  3,
                  'دستورالعمل و توضیحات تمرین را بنویسید...',
                ),
                const SizedBox(height: 20),

                // Start Date and Time row
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('تاریخ امتحان'),
                          const SizedBox(height: 8),
                          _buildDatePickerField(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('ساعت شروع'),
                          const SizedBox(height: 8),
                          _buildTimePickerField(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // FILE UPLOAD SECTION
                const SizedBox(height: 20),
                _buildLabel('فایل درسنامه (اختیاری)'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _selectedFile != null
                        ? 'فایل دیگری انتخاب کنید'
                        : 'انتخاب فایل (PDF, ZIP, تصویر)',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 12),

                // Show selected file
                if (_selectedFile != null || _fileNameController.text != '')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'فایل انتخاب شده',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _fileNameController.text,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: _clearFile,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Duration and Score row
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('مدت (دقیقه)'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            _durationController,
                            1,
                            '90',
                            isNumber: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('امتیاز کل'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            _scoreController,
                            1,
                            '100',
                            isNumber: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
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
                              color: AppColor.purple.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading
                                ? Colors.grey.shade400
                                : AppColor.purple,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.isAdd
                                      ? 'ایجاد امتحان'
                                      : 'ذخیره تغییرات',
                                  style: const TextStyle(
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

  // Helper Widgets
  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    int maxLines,
    String hint, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        filled: true,
        fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColor.purple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: _selectedCourse,
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
        onChanged: _isLoading
            ? null
            : (value) {
                setState(() => _selectedCourse = value);
              },
      ),
    );
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: _isLoading ? null : _selectDate,
      child: AbsorbPointer(
        child: TextField(
          controller: _dateController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'تاریخ را انتخاب کنید',
            hintTextDirection: TextDirection.rtl,
            suffixIcon: const Icon(Icons.calendar_today),
            filled: true,
            fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField() {
    return GestureDetector(
      onTap: _isLoading ? null : _selectTime,
      child: AbsorbPointer(
        child: TextField(
          controller: _timeController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'ساعت را انتخاب کنید',
            hintTextDirection: TextDirection.rtl,
            suffixIcon: const Icon(Icons.access_time),
            filled: true,
            fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
