import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';

/// Reusable dialog for submitting/updating answers to exams or assignments.
/// Supports file upload (PDF, ZIP, images) and description.
///
/// After submission, the button changes to "تغییر پاسخ" (Change Answer)
/// allowing students to update their submission.
class SubmitAnswerDialog extends StatefulWidget {
  final String type; // 'assignment' or 'exam'
  final int id; // assignmentId or examId
  final int userId;
  final VoidCallback? onSubmitted;
  final bool isEditing; // Whether this is an edit (existing submission)

  const SubmitAnswerDialog({
    super.key,
    required this.type,
    required this.id,
    required this.userId,
    this.onSubmitted,
    this.isEditing = false,
  });

  @override
  State<SubmitAnswerDialog> createState() => _SubmitAnswerDialogState();
}

class _SubmitAnswerDialogState extends State<SubmitAnswerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _fileNameController = TextEditingController();
  PlatformFile? _selectedPlatformFile;
  bool _isLoading = false;
  bool _hasExistingSubmission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _hasExistingSubmission = widget.isEditing;
    _checkExistingSubmission();
  }

  Future<void> _checkExistingSubmission() async {
    // This method checks if student has already submitted
    // In a real app, you'd fetch this from the API
    // For now, we'll rely on the isEditing parameter passed from parent
    setState(() {
      _hasExistingSubmission = widget.isEditing;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'zip', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final platformFile = result.files.single;
      final originalName = platformFile.name;

      setState(() {
        _selectedPlatformFile = platformFile;
        _fileNameController.text = originalName;
        _errorMessage = null;
      });
      print('File selected: Name: $originalName, Size: ${platformFile.size}');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPlatformFile == null) {
      setState(() => _errorMessage = 'لطفاً فایل پاسخ را انتخاب کنید');
      return;
    }

    if (_fileNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'لطفاً نام فایل را وارد کنید');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customFileName = _fileNameController.text.trim();

      // Call appropriate API based on type
      if (widget.type == 'assignment') {
        await ApiService.submitAssignment(
          widget.userId,
          widget.id,
          _descriptionController.text,
          _selectedPlatformFile!,
          customFileName: customFileName,
          isUpdate: _hasExistingSubmission, // Pass whether this is an update
        );
      } else if (widget.type == 'exam') {
        await ApiService.submitExam(
          widget.userId,
          widget.id,
          _descriptionController.text,
          _selectedPlatformFile!,
          customFileName: customFileName,
          isUpdate: _hasExistingSubmission, // Pass whether this is an update
        );
      } else {
        throw Exception('نوع نامعتبر');
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSubmitted?.call();

        final message = _hasExistingSubmission
            ? 'پاسخ با موفقیت به‌روزرسانی شد'
            : 'پاسخ با موفقیت ارسال شد';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطا در ارسال: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogTitle = _hasExistingSubmission
        ? 'تغییر پاسخ'
        : (widget.type == 'assignment' ? 'ارسال پاسخ تکلیف' : 'ارسال پاسخ آزمون');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dialogTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'توضیحات (اختیاری)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'توضیحات حداکثر ۵۰۰ کاراکتر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // File Picker Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_hasExistingSubmission
                    ? 'تغییر فایل (PDF, ZIP, تصویر)'
                    : 'انتخاب فایل (PDF, ZIP, تصویر)'),
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
              const SizedBox(height: 16),

              // Editable File Name Field (shown only if file selected)
              if (_selectedPlatformFile != null)
                TextFormField(
                  controller: _fileNameController,
                  decoration: InputDecoration(
                    labelText: 'نام فایل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedPlatformFile = null;
                          _fileNameController.clear();
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'نام فایل الزامی است';
                    }
                    return null;
                  },
                ),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(_hasExistingSubmission ? 'تغییر پاسخ' : 'ارسال پاسخ'),
          ),
      ],
    );
  }
}