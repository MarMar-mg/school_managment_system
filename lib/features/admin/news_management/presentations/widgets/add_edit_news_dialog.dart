import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/shamsi_date_picker_dialog.dart';
import 'package:school_management_system/commons/text_style.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../../commons/widgets/bottom_sheet_image_picker.dart';
import '../../data/models/news_model.dart';

class AddEditNewsDialog extends StatefulWidget {
  final bool isEdit;
  final NewsModel? news;

  const AddEditNewsDialog({
    super.key,
    required this.isEdit,
    this.news,
  });

  @override
  State<AddEditNewsDialog> createState() => _AddEditNewsDialogState();
}

class _AddEditNewsDialogState extends State<AddEditNewsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  String? _selectedCategory;
  XFile? _imageFile;               // selected new image file
  Uint8List? _imageBytes;          // for web preview
  String? _existingImageUrl;       // old image url (for edit mode)

  bool _isLoading = false;

  final List<String> _newsCategories = [
    'عمومی',
    'آموزشی',
    'فرهنگی و هنری',
    'ورزشی',
    'دانش‌آموزی',
    'معلمی',

  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.news?.title ?? '');
    _descriptionController = TextEditingController(text: widget.news?.description ?? '');

    _startDateController = TextEditingController();
    _endDateController = TextEditingController();

    _selectedCategory = widget.news?.category ?? _newsCategories.first;

    if (widget.news != null) {
      _existingImageUrl = widget.news?.image;

      // Parse and set dates
      try {
        final startParts = widget.news!.startDate.split('/');
        final startJalali = Jalali(
          int.parse(startParts[0]),
          int.parse(startParts[1]),
          int.parse(startParts[2]),
        );
        _startDateController.text = _formatJalaliDate(startJalali);

        final endParts = widget.news!.endDate.split('/');
        final endJalali = Jalali(
          int.parse(endParts[0]),
          int.parse(endParts[1]),
          int.parse(endParts[2]),
        );
        _endDateController.text = _formatJalaliDate(endJalali);
      } catch (e) {
        _startDateController.text = _formatJalaliDate(Jalali.now());
        _endDateController.text = _formatJalaliDate(Jalali.now().addDays(7));
      }
    } else {
      _startDateController.text = _formatJalaliDate(Jalali.now());
      _endDateController.text = _formatJalaliDate(Jalali.now().addDays(7));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatJalaliDate(Jalali date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart
        ? _startDateController.text.isNotEmpty
        ? _parseDate(_startDateController.text)
        : Jalali.now()
        : _endDateController.text.isNotEmpty
        ? _parseDate(_endDateController.text)
        : Jalali.now();

    final picked = await showDialog<Jalali>(
      context: context,
      builder: (context) => ShamsiDatePickerDialog(
        initialDate: initial,
        firstDate: Jalali.now().addDays(-365),
        lastDate: Jalali.now().addDays(365 * 2),
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        final formatted = _formatJalaliDate(picked);
        if (isStart) {
          _startDateController.text = formatted;
        } else {
          _endDateController.text = formatted;
        }
      });
    }
  }

  Jalali _parseDate(String text) {
    try {
      final parts = text.split('/');
      return Jalali(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return Jalali.now();
    }
  }

  Future<void> _pickImage() async {
    final file = await showBottomSheetFilePicker(context);
    if (file != null) {
      if (kIsWeb) {
        // On web: read bytes for preview
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = file;
          _existingImageUrl = null; // clear old url when new image picked
        });
      } else {
        // On mobile/desktop
        setState(() {
          _imageFile = file;
          _imageBytes = null;
          _existingImageUrl = null;
        });
      }
    }
  }

  Future<void> _saveNews() async {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('عنوان خبر الزامی است', Colors.orange);
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.trim().isEmpty) {
      _showSnackBar('دسته‌بندی را انتخاب کنید', Colors.orange);
      return;
    }

    if (_startDateController.text.trim().isEmpty || _endDateController.text.trim().isEmpty) {
      _showSnackBar('تاریخ شروع و پایان الزامی است', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newsData = NewsModel(
        newsId: widget.isEdit ? widget.news!.newsId : 0,
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        image: widget.isEdit ? widget.news?.image : _existingImageUrl, // old image - will be replaced if new file
      );

      bool success = false;

      if (widget.isEdit) {
        success = await ApiService().updateNews(
          widget.news!.newsId,
          newsData,
          _imageFile, // new image (null = keep old)
        );
      } else {
        await ApiService.createNewsWithImage(
          newsData,
            _imageFile
        );
      }

      if (mounted) {
        _showSnackBar(
          widget.isEdit ? 'خبر با موفقیت ویرایش شد' : 'خبر با موفقیت ثبت شد',
          Colors.green,
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        _showSnackBar('عملیات ناموفق بود', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('خطا در ذخیره: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      title: Text(
        widget.isEdit ? 'ویرایش خبر' : 'افزودن خبر جدید',
        style: defaultTextStyle(context, StyleText.bb1).c(AppColor.purple),
        textDirection: TextDirection.rtl,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان خبر',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 20),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'دسته‌بندی',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _newsCategories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              isExpanded: true,
            ),
            const SizedBox(height: 20),

            // Dates
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(true),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'تاریخ شروع',
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(false),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: 'تاریخ پایان',
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'توضیحات',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 5,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 20),

            // Pick Image
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_imageFile == null ? 'انتخاب تصویر' : 'تغییر تصویر'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),

            // Image Preview
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _imageFile != null
                    ? (kIsWeb
                    ? (_imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : const Center(child: CircularProgressIndicator()))
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover))
                    : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                    ? Image.network(
                  ApiService.getImageFullUrl(_existingImageUrl!),
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) =>
                  progress == null ? child : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (ctx, error, stack) => const Center(
                    child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  ),
                )
                    : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('هیچ تصویری انتخاب نشده است', textDirection: TextDirection.rtl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('لغو'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveNews,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.purple,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : Text(widget.isEdit ? 'ذخیره تغییرات' : 'ثبت خبر'),
        ),
      ],
    );
  }
}