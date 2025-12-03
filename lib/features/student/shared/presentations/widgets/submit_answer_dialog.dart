import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';

/// Reusable dialog for submitting answers to exams or assignments.
/// Supports file upload (PDF, ZIP, images) and description.
///
/// Usage:
/// showDialog(
///   context: context,
///   builder: (_) => SubmitAnswerDialog(
///     type: 'assignment', // or 'exam'
///     id: assignmentId, // or examId
///     studentId: studentId,
///     onSubmitted: () => refreshList(),
///   ),
/// );
class SubmitAnswerDialog extends StatefulWidget {
  final String type; // 'assignment' or 'exam'
  final int id; // assignmentId or examId
  final int userId;
  final VoidCallback? onSubmitted;

  const SubmitAnswerDialog({
    super.key,
    required this.type,
    required this.id,
    required this.userId,
    this.onSubmitted,
  });

  @override
  State<SubmitAnswerDialog> createState() => _SubmitAnswerDialogState();
}

class _SubmitAnswerDialogState extends State<SubmitAnswerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _fileNameController = TextEditingController(); // For editable file name
  PlatformFile? _selectedPlatformFile; // Change to PlatformFile to handle web bytes
  bool _isLoading = false;
  String? _errorMessage;

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
        _fileNameController.text = originalName; // Pre-fill with original name
        _errorMessage = null;
      });
      print('File selected: Name: $originalName, Size: ${platformFile.size}, Has path: ${platformFile.path != null}, Has bytes: ${platformFile.bytes != null}');
    } else {
      print('No file selected');
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
        );
      } else if (widget.type == 'exam') {
        await ApiService.submitExam(
          widget.userId,
          widget.id,
          _descriptionController.text,
          _selectedPlatformFile!,
          customFileName: customFileName,
        );
      } else {
        throw Exception('نوع نامعتبر');
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSubmitted?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('پاسخ با موفقیت ارسال شد'),
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.type == 'assignment' ? 'ارسال پاسخ تکلیف' : 'ارسال پاسخ آزمون',
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
                label: const Text('انتخاب فایل (PDF, ZIP, تصویر)'),
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
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
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
            child: const Text('ارسال پاسخ'),
          ),
      ],
    );
  }
}