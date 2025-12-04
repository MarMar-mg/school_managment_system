import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';

/// Reusable dialog for submitting/updating answers to exams or assignments.
/// Supports file upload (PDF, ZIP, images) and description.
///
/// When editing, displays the previously submitted file and description as defaults.
/// Students can modify or replace them before updating.
class SubmitAnswerDialog extends StatefulWidget {
  final String type; // 'assignment' or 'exam'
  final int id; // assignmentId or examId
  final int userId;
  final VoidCallback? onSubmitted;
  final bool isEditing; // Whether this is an edit (existing submission)

  // Previous submission data (for editing)
  final String? previousDescription;
  final String? previousFileName;

  const SubmitAnswerDialog({
    super.key,
    required this.type,
    required this.id,
    required this.userId,
    this.onSubmitted,
    this.isEditing = false,
    this.previousDescription,
    this.previousFileName,
  });

  @override
  State<SubmitAnswerDialog> createState() => _SubmitAnswerDialogState();
}

class _SubmitAnswerDialogState extends State<SubmitAnswerDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _fileNameController;
  PlatformFile? _selectedPlatformFile;
  bool _isLoading = false;
  bool _hasExistingSubmission = false;
  String? _errorMessage;
  bool _fileChanged = false; // Track if user selected a new file

  @override
  void initState() {
    super.initState();
    _hasExistingSubmission = widget.isEditing;

    // Initialize with previous data if editing
    _descriptionController = TextEditingController(
      text: widget.isEditing ? (widget.previousDescription ?? '') : '',
    );

    _fileNameController = TextEditingController(
      text: widget.isEditing ? (widget.previousFileName ?? '') : '',
    );

    _checkExistingSubmission();
  }

  Future<void> _checkExistingSubmission() async {
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
        _fileChanged = true; // Mark that file has been changed
        _errorMessage = null;
      });
      print('File selected: Name: $originalName, Size: ${platformFile.size}');
    }
  }

  void _clearNewFile() {
    setState(() {
      _selectedPlatformFile = null;
      _fileChanged = false;

      // Restore previous file name if editing
      if (widget.isEditing && widget.previousFileName != null) {
        _fileNameController.text = widget.previousFileName!;
      } else {
        _fileNameController.clear();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // If not editing or file was changed, require a new file
    if (!widget.isEditing || _fileChanged) {
      if (_selectedPlatformFile == null) {
        setState(() => _errorMessage = 'لطفاً فایل پاسخ را انتخاب کنید');
        return;
      }
    }

    // Validate file name only if file is being submitted
    if (_selectedPlatformFile != null && _fileNameController.text.trim().isEmpty) {
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
          _selectedPlatformFile, // Can be null for updates without file change
          customFileName: customFileName,
          isUpdate: _hasExistingSubmission,
        );
      } else if (widget.type == 'exam') {
        await ApiService.submitExam(
          widget.userId,
          widget.id,
          _descriptionController.text,
          _selectedPlatformFile, // Can be null for updates without file change
          customFileName: customFileName,
          isUpdate: _hasExistingSubmission,
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

              // Previous File Info (when editing)
              if (widget.isEditing && widget.previousFileName != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_present,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'فایل قبلی',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.previousFileName!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'درخواست تغییر فایل:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // File Picker Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_hasExistingSubmission && !_fileChanged
                    ? 'تغییر فایل (اختیاری)'
                    : (widget.isEditing
                    ? 'تغییر فایل (PDF, ZIP, تصویر)'
                    : 'انتخاب فایل (PDF, ZIP, تصویر)')),
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

              // New File Name Field (shown only if file selected or editing with file)
              if (_selectedPlatformFile != null || (widget.isEditing && !_fileChanged))
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
                      Text(
                        _fileChanged ? 'فایل جدید' : 'فایل فعلی',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _fileNameController,
                        decoration: InputDecoration(
                          labelText: 'نام فایل',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: _fileChanged
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: _clearNewFile,
                          )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'نام فایل الزامی است';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
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