import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/core/services/exam_time_validator.dart';

/// Reusable dialog for submitting/updating answers to exams or assignments.
/// Supports file upload (PDF, ZIP, images) and description.
///
/// When editing, displays the previously submitted file and description as defaults.
/// Students can modify or replace them before updating.
class SubmitAnswerDialog extends StatefulWidget {
  final String type; // 'assignment' or 'exam'
  final int id;
  final int userId;
  final VoidCallback? onSubmitted;
  final bool isEditing;
  final String? previousDescription;
  final String? previousFileName;

  // For exams: pass these for time validation
  final String? examDate;
  final String? examStartTime;
  final String? examEndTime;

  const SubmitAnswerDialog({
    super.key,
    required this.type,
    required this.id,
    required this.userId,
    this.onSubmitted,
    this.isEditing = false,
    this.previousDescription,
    this.previousFileName,
    this.examDate,
    this.examStartTime,
    this.examEndTime,
  });

  @override
  State<SubmitAnswerDialog> createState() => _SubmitAnswerDialogState();
}

class _SubmitAnswerDialogState extends State<SubmitAnswerDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _fileNameController;

  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String? _examTimeStatus;
  int? _remainingMinutes;
  bool isEmpty = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.previousDescription ?? '',
    );
    _fileNameController = TextEditingController(
      text: widget.previousFileName ?? '',
    );

    // Check exam time if it's an exam submission
    if (widget.type == 'exam' &&
        widget.examDate != null &&
        widget.examStartTime != null &&
        widget.examEndTime != null) {
      _examTimeStatus = ExamTimeValidator.getExamStatus(
        examDate: widget.examDate!,
        startTime: widget.examStartTime!,
        endTime: widget.examEndTime!,
      );

      if (_examTimeStatus == 'during') {
        _remainingMinutes = ExamTimeValidator.getRemainingMinutes(
          examDate: widget.examDate!,
          startTime: widget.examStartTime!,
          endTime: widget.examEndTime!,
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.single;
        _fileNameController.text = _selectedFile!.name;
      });
    }
  }

  Future<void> _submit() async {
    // Validate exam time before submission
    if (widget.type == 'exam' && _examTimeStatus != null) {
      if (_examTimeStatus != 'during') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ExamTimeValidator.getTimeErrorMessage(_examTimeStatus!),
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }



    setState(() => _isLoading = true);

    try {
      if (widget.type == 'exam') {
        await ApiService.submitExam(
          widget.userId,
          widget.id,
          !isEmpty,
          _descriptionController.text,
          isEmpty? null: _selectedFile,
          customFileName: isEmpty? '':_fileNameController.text,
          isUpdate: widget.isEditing,
        );
      } else {
        await ApiService.submitAssignment(
          widget.userId,
          widget.id,
          !isEmpty,
          _descriptionController.text,
          isEmpty? null: _selectedFile,
          customFileName: isEmpty? '':_fileNameController.text,
          isUpdate: widget.isEditing,
        );
      }

      if (mounted) {
        _showSuccess(
          widget.isEditing
              ? 'پاسخ با موفقیت به‌روزرسانی شد'
              : 'پاسخ با موفقیت ارسال شد',
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          widget.onSubmitted?.call();
          Navigator.pop(context);
        }
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
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExamTimeInvalid =
        widget.type == 'exam' && _examTimeStatus != 'during';

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                widget.isEditing ? 'تغییر پاسخ' : 'ارسال پاسخ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),

              // TIME WARNING BANNER
              if (isExamTimeInvalid) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ExamTimeValidator.getTimeErrorMessage(
                            _examTimeStatus!,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else if (widget.type == 'exam' &&
                  _examTimeStatus == 'during' &&
                  _remainingMinutes != null) ...[
                // TIME REMAINING BANNER
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'زمان باقی‌مانده: ${_remainingMinutes!} دقیقه',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Description Input
              Text(
                'توضیحات (اختیاری)',
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
                maxLines: 3,
                textDirection: TextDirection.rtl,
                enabled: !_isLoading && !isExamTimeInvalid,
                decoration: InputDecoration(
                  hintText: 'توضیحات درباره پاسخ خود...',
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // File Selection
              Text(
                'انتخاب فایل',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: (_isLoading || isExamTimeInvalid) ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('انتخاب فایل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.purple,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 12),

              // Selected File Display
              if (_fileNameController.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _fileNameController.text,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _selectedFile = null;
                          _fileNameController.clear();
                          isEmpty = true;
                        }),
                        child: Icon(
                          Icons.close,
                          color: Colors.red.shade600,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: (_isLoading || isExamTimeInvalid)
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('لغو'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isLoading || isExamTimeInvalid)
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isExamTimeInvalid
                            ? Colors.grey.shade400
                            : AppColor.purple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.isEditing ? 'ذخیره تغییرات' : 'ارسال پاسخ',
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
