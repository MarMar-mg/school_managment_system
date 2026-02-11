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
import '../../../../../applications/role.dart';
import '../../../../../commons/widgets/bottom_sheet_image_picker.dart';
import '../../data/models/news_model.dart';

class AddEditNewsDialog extends StatefulWidget {
  final bool isEdit;
  final NewsModel? news;
  final Role role;

  const AddEditNewsDialog({
    super.key,
    required this.isEdit,
    this.news,
    required this.role,
  });

  @override
  State<AddEditNewsDialog> createState() => _AddEditNewsDialogState();
}

class _AddEditNewsDialogState extends State<AddEditNewsDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String? _selectedCategory;
  Jalali? _startDate;
  Jalali? _endDate;
  XFile? _imageFile;
  Uint8List? _imageBytes;          // ← For web preview
  String? _existingImageUrl;

  final List<String> _newsCategories = [
    'عمومی',
    'آموزشی',
    'رویدادها',
    'اطلاعیه',
    'ورزشی',
    'فرهنگی',
    'اخبار مدرسه',
    'برنامه امتحانات',
    'دانش‌آموزی',
    'معلمی',
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.news?.title ?? '');
    _descriptionController = TextEditingController(text: widget.news?.description ?? '');

    _selectedCategory = widget.news?.category ?? _newsCategories.first;

    if (widget.news != null) {
      try {
        final startParts = widget.news!.startDate.split('-');
        _startDate = Jalali(
          int.parse(startParts[0]),
          int.parse(startParts[1]),
          int.parse(startParts[2]),
        );

        final endParts = widget.news!.endDate.split('-');
        _endDate = Jalali(
          int.parse(endParts[0]),
          int.parse(endParts[1]),
          int.parse(endParts[2]),
        );
      } catch (e) {
        _startDate = Jalali.now();
        _endDate = Jalali.now().addDays(7);
      }

      _existingImageUrl = widget.news?.image;
    } else {
      _startDate = Jalali.now();
      _endDate = Jalali.now().addDays(7);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDialog<Jalali>(
      context: context,
      builder: (context) => ShamsiDatePickerDialog(
        initialDate: isStart ? _startDate! : _endDate!,
        firstDate: Jalali.now().addDays(-365),
        lastDate: Jalali.now().addDays(365 * 2),
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
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

  String _formatJalaliDate(Jalali? date) {
    if (date == null) return '';
    return '${date.formatter.yyyy}/${date.formatter.mm}/${date.formatter.dd}';
  }

  Future<void> _saveNews() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان خبر الزامی است')),
      );
      return;
    }
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دسته‌بندی را انتخاب کنید')),
      );
      return;
    }

    try {
      final news = NewsModel(
        newsId: widget.news?.newsId ?? 0,
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        startDate: '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
        endDate: '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
        description: _descriptionController.text.trim(),
        image: _existingImageUrl,
      );

      if (widget.isEdit) {
        // TODO: Call update API (with optional new image)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ویرایش خبر هنوز پیاده‌سازی نشده است')),
        );
      } else {
        await ApiService.createNewsWithImage(news, _imageFile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خبر با موفقیت ثبت شد')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ذخیره: $e'), backgroundColor: Colors.red),
      );
    }
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
                labelText: 'دسته بندی',
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
                        decoration: InputDecoration(
                          labelText: 'تاریخ شروع',
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        controller: TextEditingController(text: _formatJalaliDate(_startDate)),
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
                        decoration: InputDecoration(
                          labelText: 'تاریخ پایان',
                          suffixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        controller: TextEditingController(text: _formatJalaliDate(_endDate)),
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

            // Pick Image Button
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

            // Image Preview - cross platform
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
                    ? kIsWeb
                    ? (_imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : const Center(child: CircularProgressIndicator()))
                    : Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                    : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                    ? Image.network(
                  _existingImageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) =>
                  progress == null ? child : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, __, ___) => const Center(
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
          onPressed: () => Navigator.pop(context),
          child: const Text('لغو'),
        ),
        ElevatedButton(
          onPressed: _saveNews,
          child: Text(widget.isEdit ? 'ذخیره تغییرات' : 'ثبت خبر'),
        ),
      ],
    );
  }
}