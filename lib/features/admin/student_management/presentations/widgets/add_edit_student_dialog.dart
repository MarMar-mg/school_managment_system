import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../data/models/student_model.dart';

class AddEditStudentDialog extends StatefulWidget {
  final bool isEdit;
  final StudentModel? student;

  const AddEditStudentDialog({
    super.key,
    required this.isEdit,
    this.student,
  });

  @override
  State<AddEditStudentDialog> createState() => _AddEditStudentDialogState();
}

class _AddEditStudentDialogState extends State<AddEditStudentDialog> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _phoneController;
  late TextEditingController _parentPhoneController;
  late TextEditingController _birthDateController;
  late TextEditingController _addressController;
  late TextEditingController _debtController;

  // Class dropdown
  int? _selectedClassId;
  List<Map<String, dynamic>> _classList = [];
  bool _loadingClasses = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _codeController = TextEditingController(text: widget.student?.studentCode ?? '');
    _phoneController = TextEditingController(text: widget.student?.phone ?? '');
    _parentPhoneController = TextEditingController(text: widget.student?.parentPhone ?? '');
    _birthDateController = TextEditingController(text: widget.student?.birthDate ?? '');
    _addressController = TextEditingController(text: widget.student?.address ?? '');
    _debtController = TextEditingController(text: widget.student?.debt.toString() ?? '0');
    _selectedClassId = widget.student?.stuClass;

    // Load classes
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final classes = await ApiService.getAllClasses();
      setState(() {
        _classList = classes.cast<Map<String, dynamic>>();
        _loadingClasses = false;
      });
    } catch (e) {
      print('Error loading classes: $e');
      setState(() {
        _loadingClasses = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _phoneController.dispose();
    _parentPhoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _debtController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool required = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
              textDirection: TextDirection.rtl,
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColor.purple, size: 18),
              hintText: 'وارد کنید',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  // Class Dropdown Widget
  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'کلاس',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
              textDirection: TextDirection.rtl,
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _loadingClasses
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.purple,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'در حال بارگذاری کلاس‌ها...',
                  style: TextStyle(fontSize: 12, color: AppColor.lightGray),
                ),
              ],
            ),
          )
              : DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedClassId,
              hint: const Text(
                'کلاس را انتخاب کنید',
                style: TextStyle(fontSize: 12, color: AppColor.lightGray),
                textDirection: TextDirection.rtl,
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppColor.purple),
              items: _classList.map((classData) {
                final classId = classData['id'] as int;
                final className = classData['name'] ?? 'نامشخص';
                final grade = classData['grade'] ?? '';

                return DropdownMenuItem<int>(
                  value: classId,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          grade,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColor.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          className,
                          style: const TextStyle(fontSize: 12),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showError('نام دانش‌آموز الزامی است');
      return false;
    }
    if (_codeController.text.trim().isEmpty) {
      _showError('کد دانش‌آموزی الزامی است');
      return false;
    }
    if (_selectedClassId == null) {
      _showError('لطفا کلاس را انتخاب کنید');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 420,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEdit ? 'ویرایش دانش‌آموز' : 'افزودن دانش‌آموز',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkText,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isEdit ? 'اطلاعات را ویرایش کنید' : 'دانش‌آموز جدید را اضافه کنید',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.lightGray,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColor.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                        color: AppColor.purple,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                _buildTextField(_nameController, 'نام', Icons.person_rounded, required: true),
                const SizedBox(height: 14),
                _buildTextField(_codeController, 'کد دانش‌آموزی', Icons.badge_rounded, required: true),
                const SizedBox(height: 14),
                _buildClassDropdown(),
                const SizedBox(height: 14),
                _buildTextField(_phoneController, 'شماره تلفن', Icons.phone_rounded,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                _buildTextField(_parentPhoneController, 'شماره ولی', Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                _buildTextField(_birthDateController, 'تاریخ تولد', Icons.cake_rounded),
                const SizedBox(height: 14),
                _buildTextField(_addressController, 'آدرس', Icons.location_on_rounded),
                const SizedBox(height: 14),
                _buildTextField(_debtController, 'بدهی', Icons.money_rounded,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'لغو',
                          style: TextStyle(
                            color: AppColor.lightGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColor.purple, AppColor.lightPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.purple.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (!_validateForm()) return;

                              final debt = int.tryParse(_debtController.text) ?? 0;

                              final newStudent = StudentModel(
                                studentId: widget.student?.studentId ?? 0,
                                name: _nameController.text.trim(),
                                studentCode: _codeController.text.trim(),
                                stuClass: _selectedClassId,
                                phone: _phoneController.text.trim(),
                                parentPhone: _parentPhoneController.text.trim(),
                                birthDate: _birthDateController.text.trim(),
                                address: _addressController.text.trim(),
                                debt: debt,
                              );
                              Navigator.pop(context, newStudent);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  widget.isEdit ? 'ویرایش' : 'افزودن',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
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