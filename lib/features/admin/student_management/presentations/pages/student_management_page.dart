import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';

class StudentManagementPage extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const StudentManagementPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  late Future<List<dynamic>> _studentsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  bool _isLoading = false;
  final Map<int, String> _classNameCache = {}; // Cache for class IDs to names

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    _studentsFuture = ApiService.getAllStudents();
  }

  // Fetch all classes and cache them
  Future<void> _loadClassNames(List<dynamic> students) async {
    try {
      // Get unique class IDs from students
      final classIds = students
          .map((s) => s['classs'] as int?)
          .where((id) => id != null)
          .cast<int>()
          .toSet();

      if (classIds.isEmpty) return;

      // Fetch all classes from API
      final allClasses = await ApiService.getAllClasses();

      // Create a map of classId -> className
      for (var classData in allClasses) {
        final classId = classData['id'] as int;
        final className = classData['name'] ?? 'نامشخص';

        _classNameCache[classId] = className;
      }

      // Update UI with new cached data
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading class names: $e');
      // Fallback: use class IDs as labels
      final classIds = students
          .map((s) => s['classs'] as int?)
          .where((id) => id != null)
          .cast<int>()
          .toSet();

      for (var classId in classIds) {
        if (!_classNameCache.containsKey(classId)) {
          _classNameCache[classId] = 'کلاس $classId';
        }
      }

      if (mounted) {
        setState(() {});
      }
    }
  }

  String _getClassName(int? classId) {
    if (classId == null) return 'نامشخص';
    return _classNameCache[classId] ?? 'در حال بارگذاری...';
  }

  Future<void> _addOrEditStudent({
    required String name,
    required String studentCode,
    required String stuClass,
    required String phone,
    required String parentPhone,
    required String birthDate,
    required String address,
    required int debt,
    int? studentId,
  }) async {
    setState(() => _isLoading = true);
    try {
      if (studentId != null) {
        await ApiService.updateStudent(
          studentId: studentId,
          name: name,
          studentCode: studentCode,
          stuClass: stuClass,
          phone: phone,
          parentPhone: parentPhone,
          birthDate: birthDate,
          address: address,
          debt: debt,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('دانش‌آموز با موفقیت به‌روزرسانی شد'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await ApiService.createStudent(
          name: name,
          studentCode: studentCode,
          stuClass: stuClass,
          phone: phone,
          parentPhone: parentPhone,
          birthDate: birthDate,
          address: address,
          debt: debt,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('دانش‌آموز با موفقیت افزوده شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadStudents();
      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStudent(int studentId) async {
    if (!await _showConfirmDialog('آیا از حذف این دانش‌آموز اطمینان دارید؟')) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.deleteStudent(studentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('دانش‌آموز با موفقیت حذف شد'),
          backgroundColor: Colors.green,
        ),
      );
      _loadStudents();
      if (mounted) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأیید'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأیید'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadStudents(),
          color: AppColor.purple,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ResponsiveContainer(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    FutureBuilder<List<dynamic>>(
                      future: _studentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColor.purple),
                          );
                        }

                        if (snapshot.hasError) {
                          return _buildError(snapshot.error.toString());
                        }

                        final students = snapshot.data ?? [];

                        // Load class names when data is available
                        _loadClassNames(students);

                        final filtered = students.where((s) {
                          final name = s['name'] ?? '';
                          final code = s['studentCode'] ?? '';
                          return name.contains(_searchTerm) ||
                              code.contains(_searchTerm);
                        }).toList();

                        if (filtered.isEmpty) {
                          return _buildEmpty();
                        }

                        return Column(
                          children: [
                            _buildStatsCards(filtered),
                            const SizedBox(height: 24),
                            ..._buildStudentCards(filtered),
                            const SizedBox(height: 100),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColor.purple,
        icon: const Icon(Icons.add),
        label: const Text('دانش‌آموز جدید'),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'مدیریت دانش‌آموزان',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        const Text(
          'نمایش و مدیریت اطلاعات تمام دانش‌آموزان',
          style: TextStyle(
            fontSize: 14,
            color: AppColor.lightGray,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchTerm = value),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'جستجو بر اساس نام یا کد...',
          hintTextDirection: TextDirection.rtl,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: AppColor.lightGray),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatsCards(List<dynamic> students) {
    final noDept = students.where((s) => (s['debt'] ?? 0) == 0).length;
    final withDebt = students.where((s) => (s['debt'] ?? 0) > 0).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'کل دانش‌آموزان',
            value: '${students.length}',
            icon: Icons.group_rounded,
            color: AppColor.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'بدون بدهی',
            value: '$noDept',
            icon: Icons.check_circle_rounded,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'دارای بدهی',
            value: '$withDebt',
            icon: Icons.warning_rounded,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.lightGray,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStudentCards(List<dynamic> students) {
    return students.map((student) {
      final debt = student['debt'] ?? 0;
      final hasDept = debt > 0;
      final classId = student['classs'] as int?;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border(
              right: BorderSide(color: AppColor.purple, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColor.purple, AppColor.lightPurple],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          (student['name'] ?? 'N').substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'] ?? 'نامشخص',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.darkText,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'کد: ${student['studentCode'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColor.lightGray,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Debt Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: hasDept
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hasDept
                            ? '${_formatNumber(debt)} تومان'
                            : 'بدون بدهی',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasDept ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),

                // Details
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDetailChip(
                      icon: Icons.class_rounded,
                      label: _getClassName(classId),
                    ),
                    _buildDetailChip(
                      icon: Icons.phone_rounded,
                      label: student['phone'] ?? 'N/A',
                    ),
                    _buildDetailChip(
                      icon: Icons.calendar_today_rounded,
                      label: student['birthDate'] ?? 'N/A',
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _showViewDialog(student),
                      icon: const Icon(Icons.visibility_rounded),
                      color: Colors.blue,
                      tooltip: 'مشاهده',
                    ),
                    IconButton(
                      onPressed: () => _showAddEditDialog(student: student),
                      icon: const Icon(Icons.edit_rounded),
                      color: AppColor.purple,
                      tooltip: 'ویرایش',
                    ),
                    IconButton(
                      onPressed: () => _deleteStudent(student['id']),
                      icon: const Icon(Icons.delete_rounded),
                      color: Colors.red,
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildDetailChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.purple),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColor.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({dynamic student}) {
    showDialog(
      context: context,
      builder: (ctx) => StudentFormDialog(
        student: student,
        onSubmit: _addOrEditStudent,
      ),
    );
  }

  void _showViewDialog(dynamic student) {
    showDialog(
      context: context,
      builder: (ctx) => StudentDetailDialog(student: student, classNameCache: _classNameCache),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text('خطا در بارگذاری'),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: AppColor.lightGray),
          const SizedBox(height: 16),
          const Text(
            'دانش‌آموزی یافت نشد',
            style: TextStyle(fontSize: 16, color: AppColor.lightGray),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Student Form Dialog
class StudentFormDialog extends StatefulWidget {
  final dynamic student;
  final Function onSubmit;

  const StudentFormDialog({
    super.key,
    this.student,
    required this.onSubmit,
  });

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController classController;
  late TextEditingController phoneController;
  late TextEditingController parentPhoneController;
  late TextEditingController birthDateController;
  late TextEditingController addressController;
  late TextEditingController debtController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.student?['name'] ?? '');
    codeController = TextEditingController(text: widget.student?['studentCode'] ?? '');
    classController = TextEditingController(text: widget.student?['classs']?.toString() ?? '');
    phoneController = TextEditingController(text: widget.student?['phone'] ?? '');
    parentPhoneController = TextEditingController(text: widget.student?['parentPhone'] ?? '');
    birthDateController = TextEditingController(text: widget.student?['birthDate'] ?? '');
    addressController = TextEditingController(text: widget.student?['address'] ?? '');
    debtController = TextEditingController(text: '${widget.student?['debt'] ?? 0}');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  Text(
                    widget.student == null ? 'افزودن دانش‌آموز' : 'ویرایش دانش‌آموز',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkText,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField('نام دانش‌آموز', nameController, Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField('کد دانش‌آموز', codeController, Icons.badge),
                  const SizedBox(height: 16),
                  _buildTextField('کلاس', classController, Icons.class_rounded),
                  const SizedBox(height: 16),
                  _buildTextField('تاریخ تولد', birthDateController, Icons.calendar_today),
                  const SizedBox(height: 16),
                  _buildTextField('شماره تلفن', phoneController, Icons.phone),
                  const SizedBox(height: 16),
                  _buildTextField('شماره تلفن ولی', parentPhoneController, Icons.phone_forwarded),
                  const SizedBox(height: 16),
                  _buildTextField('آدرس', addressController, Icons.location_on, maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField('بدهی (تومان)', debtController, Icons.attach_money, isNumber: true),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('انصراف'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.purple,
                    ),
                    child: const Text('ذخیره'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        int maxLines = 1,
        bool isNumber = false,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.purple, width: 2),
        ),
      ),
    );
  }

  void _submitForm() {
    if (nameController.text.isEmpty || codeController.text.isEmpty || classController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا تمام فیلدهای الزامی را پر کنید')),
      );
      return;
    }

    widget.onSubmit(
      name: nameController.text,
      studentCode: codeController.text,
      stuClass: classController.text,
      phone: phoneController.text,
      parentPhone: parentPhoneController.text,
      birthDate: birthDateController.text,
      address: addressController.text,
      debt: int.tryParse(debtController.text) ?? 0,
      studentId: widget.student?['id'],
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    classController.dispose();
    phoneController.dispose();
    parentPhoneController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    debtController.dispose();
    super.dispose();
  }
}

// Student Detail Dialog
class StudentDetailDialog extends StatelessWidget {
  final dynamic student;
  final Map<int, String> classNameCache;

  const StudentDetailDialog({
    super.key,
    required this.student,
    required this.classNameCache,
  });

  String _getClassName(int? classId) {
    if (classId == null) return 'نامشخص';
    return classNameCache[classId] ?? 'کلاس $classId';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const Text(
                    'جزئیات دانش‌آموز',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkText,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.purple, AppColor.lightPurple],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (student['name'] ?? 'N').substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          student['name'] ?? 'نامشخص',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkText,
                          ),
                        ),
                        Text(
                          'کد: ${student['studentCode'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('کلاس', _getClassName(student['classs'] as int?)),
                  _buildDetailRow('تاریخ تولد', student['birthDate'] ?? 'N/A'),
                  _buildDetailRow('شماره تلفن', student['phone'] ?? 'N/A'),
                  _buildDetailRow('شماره ولی', student['parentPhone'] ?? 'N/A'),
                  _buildDetailRow(
                    'بدهی',
                    (student['debt'] ?? 0) == 0
                        ? 'بدون بدهی'
                        : '${student['debt']} تومان',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColor.lightGray,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}