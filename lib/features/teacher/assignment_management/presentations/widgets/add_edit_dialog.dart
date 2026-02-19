import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:school_management_system/commons/untils.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../commons/shamsi_date_picker_dialog.dart';
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
      return _AddEditAssignmentDialogContent(
        assignment: assignment,
        courses: courses,
        userId: userId,
        addData: addData,
        isAdd: isAdd,
      );
    },
  );
}

class _AddEditAssignmentDialogContent extends StatefulWidget {
  final dynamic assignment;
  final int userId;
  final bool isAdd;
  final VoidCallback addData;
  final List<Map<String, dynamic>> courses;

  const _AddEditAssignmentDialogContent({
    required this.assignment,
    required this.courses,
    required this.userId,
    required this.addData,
    required this.isAdd,
  });

  @override
  State<_AddEditAssignmentDialogContent> createState() =>
      _AddEditAssignmentDialogContentState();
}

class _AddEditAssignmentDialogContentState
    extends State<_AddEditAssignmentDialogContent>
    with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _scoreController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _fileNameController;

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
    _fileNameController = TextEditingController(
      text: widget.assignment?['filename'] ?? '',
    );

    _selectedCourse = widget.assignment?['classId'];

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
      print('File selected: ${platformFile.name}, Size: ${platformFile.size}');
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
      _fileChanged = false;
      _fileNameController.clear();
    });
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) {
      _showError('لطفا عنوان تکلیف را وارد کنید');
      return;
    }
    if (_dateController.text.isEmpty) {
      _showError('لطفا تاریخ تحویل را انتخاب کنید');
      return;
    }
    if (_timeController.text.isEmpty) {
      _showError('لطفا ساعت تحویل را انتخاب کنید');
      return;
    }
    if (widget.isAdd && _selectedCourse == null) {
      _showError('لطفا درس را انتخاب کنید');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isAdd) {
        await ApiService.addTeacherAssignment(
          teacherId: widget.userId,
          courseId: int.tryParse(_selectedCourse ?? '0') ?? 0,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          endDate: _dateController.text,
          endTime: _timeController.text,
          startDate:
              '${Jalali.now().formatter.yyyy}-${Jalali.now().formatter.mm}-${Jalali.now().formatter.dd}',
          startTime:
              '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
          score: int.tryParse(_scoreController.text),
          file: _selectedFile,
          fileName: _fileNameController.text.isNotEmpty
              ? _fileNameController.text
              : null,
        );

        if (mounted) {
          _showSuccess('تکلیف با موفقیت ایجاد شد');
        }
      } else {
        await ApiService.updateTeacherAssignment(
          exerciseId: widget.assignment?['id'],
          teacherId: widget.userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          endDate: _dateController.text,
          endTime: _timeController.text,
          score: int.tryParse(_scoreController.text),
          file: _selectedFile,
          fileName: _fileNameController.text.isNotEmpty
              ? _fileNameController.text
              : null,
        );

        if (mounted) {
          _showSuccess('تکلیف با موفقیت به‌روزرسانی شد');
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        widget.addData();
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scoreController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _fileNameController.dispose();
    _enterController.dispose();
    super.dispose();
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
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                        widget.isAdd ? 'ایجاد تکلیف جدید' : 'ویرایش تکلیف',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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

                  // Course dropdown
                  if (widget.isAdd) ...[
                    Text(
                      'انتخاب درس',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCourse,
                        hint: const Text('درس را انتخاب کنید'),
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
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Title
                  _buildLabel('عنوان تکلیف'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _titleController,
                    1,
                    'مثال: تکلیف ۱ - معادلات',
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildLabel('توضیحات'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _descriptionController,
                    3,
                    'دستورالعمل و توضیحات تکلیف را بنویسید...',
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
                            _buildLabel('تاریخ تحویل'),
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
                            _buildLabel('ساعت تحویل'),
                            const SizedBox(height: 8),
                            _buildTimePickerField(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Score
                  _buildLabel('امتیاز'),
                  const SizedBox(height: 8),
                  _buildTextField(_scoreController, 1, '100', isNumber: true),
                  const SizedBox(height: 20),

                  // FILE UPLOAD SECTION
                  _buildLabel('فایل تکلیف (اختیاری)'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _selectedFile != null
                          ? 'فایل دیگری انتخاب کنید'
                          : 'انتخاب فایل (PDF, ZIP, تصویر, Word)',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
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
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                                onPressed: _clearFile,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

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
                                color: const Color(0xFF7C3AED).withOpacity(0.4),
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
                                  : const Color(0xFF7C3AED),
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
                                        ? 'ایجاد تکلیف'
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
      ),
    );
  }

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
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        filled: _isLoading,
        fillColor: _isLoading ? Colors.grey.shade100 : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
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
            filled: _isLoading,
            fillColor: _isLoading ? Colors.grey.shade100 : null,
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
            filled: _isLoading,
            fillColor: _isLoading ? Colors.grey.shade100 : null,
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
