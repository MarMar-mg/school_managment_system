import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import '../../../../../commons/shamsi_date_picker_dialog.dart';
import '../../../../../commons/widgets/section_divider.dart';
import '../../../../../core/services/api_service.dart';
import '../../../assignment_management/presentations/widgets/delete_dialog.dart';
import '../../data/models/exam_model.dart';
import '../../../../../commons/responsive_container.dart';
import '../widgets/exam_section.dart';
import '../widgets/header_section.dart';
import '../widgets/stat_card.dart';
import 'package:shamsi_date/shamsi_date.dart';

class ExamManagementPage extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const ExamManagementPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<ExamManagementPage> createState() => _ExamManagementPageState();
}

class _ExamManagementPageState extends State<ExamManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardAnimations;

  List<ExamModelT> _upcomingExams = [];
  List<ExamModelT> _completedExams = [];

  bool _isLoading = true;
  String _error = '';

  final Map<String, bool> _expanded = {
    'upcoming': false,
    'completed': false,
  };


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _cardAnimations = [];
    _fetchExams();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchExams() async {
    try {
      setState(() => _isLoading = true);
      final exams = await ApiService.getTeacherExams(widget.userId);

      setState(() {
        _upcomingExams = exams.where((e) => e.status == 'upcoming').toList();
        _completedExams = exams.where((e) => e.status == 'completed').toList();
        _isLoading = false;
        _error = '';
        _expanded.updateAll((_, __) => false);
      });

      _initializeAnimations();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExam(int examID) async {
    try {
      await ApiService.deleteTeacherExam(examID, widget.userId);
      _fetchExams();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در حذف: $e')),
        );
      }
    }
  }

  void _initializeAnimations() {
    final totalCount = _upcomingExams.length + _completedExams.length;
    _cardAnimations = List.generate(
      totalCount + 2, // +2 for header and stats
          (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.06 + i * 0.04, 1.0, curve: Curves.easeOutCubic),
        ),
      ),
    );
    _controller.forward(from: 0.0);
  }

  void _toggle(String key) {
    setState(() => _expanded[key] = !_expanded[key]!);
  }

  void _showAddExamDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddExamDialogContent(
        userId: widget.userId,
        onSuccess: () {
          Navigator.pop(context);
          _fetchExams();
        },
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColor.lightGray,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: hint,
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: AppColor.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
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
        ),
      ],
    );
  }

  Widget _buildAnimatedWidget({required int index, required Widget child}) {
    if (_cardAnimations.isEmpty || index >= _cardAnimations.length) {
      return child;
    }

    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, _) {
        final value = _cardAnimations[index].value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchExams,
        color: AppColor.purple,
        child: _isLoading
            ? _buildShimmer()
            : _error.isNotEmpty
            ? _buildError()
            : _buildSuccess(),
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: ResponsiveContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey[100]!,
              highlightColor: Colors.grey[300]!,
              child: Container(height: 100, color: Colors.white),
            ),
            const SizedBox(height: 24),
            ...List.generate(3, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[100]!,
                  highlightColor: Colors.grey[300]!,
                  child: Container(height: 180, color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text('خطا در بارگذاری امتحانات'),
          const SizedBox(height: 8),
          Text(_error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchExams,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    if (_upcomingExams.isEmpty && _completedExams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: AppColor.lightGray),
            const SizedBox(height: 16),
            const Text('امتحانی وجود ندارد', style: TextStyle(fontSize: 16, color: AppColor.lightGray)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddExamDialog,
              icon: const Icon(Icons.add),
              label: const Text('افزودن امتحان'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
            ),
          ],
        ),
      );
    }

    int cardIndex = 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: ResponsiveContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            const SizedBox(height: 16),

            _buildAnimatedWidget(
              index: 0,
              child: HeaderSection(
                onAdd: _showAddExamDialog
              ),
            ),

            const SizedBox(height: 24),
            _buildAnimatedWidget(index: 1, child: const SectionDivider()),
            const SizedBox(height: 24),

            // Stats Cards
            _buildAnimatedWidget(
              index: cardIndex++,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '${_upcomingExams.length}',
                      label: 'امتحانات پیش رو',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      value: '${_completedExams.length}',
                      label: 'امتحانات برگزار شده',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Upcoming Exams Section
            ExamTeacherSection(
              title: 'پیش رو',
              color: Colors.orange,
              items: _upcomingExams,
              startIndex: cardIndex,
              sectionKey: 'upcoming',
              isExpanded: _expanded['upcoming']!,
              onToggle: () => _toggle('upcoming'),
              animations: _cardAnimations,
              onDelete: (data) => _deleteExam(data),
            ),
            const SizedBox(height: 24),

            // Completed Exams Section
            ExamTeacherSection(
              title: 'برگزار شده',
              color: Colors.green,
              items: _completedExams,
              startIndex: cardIndex + _upcomingExams.length,
              sectionKey: 'completed',
              isExpanded: _expanded['completed']!,
              onToggle: () => _toggle('completed'),
              animations: _cardAnimations,
              onDelete: (data) => _deleteExam(data['id'])
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _AddExamDialogContent extends StatefulWidget {
  final int userId;
  final VoidCallback onSuccess;

  const _AddExamDialogContent({
    required this.userId,
    required this.onSuccess,
  });

  @override
  State<_AddExamDialogContent> createState() => _AddExamDialogContentState();
}

class _AddExamDialogContentState extends State<_AddExamDialogContent>
    with TickerProviderStateMixin {

  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _capacityController = TextEditingController();
  final _durationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  Jalali? _selectedDate;
  TimeOfDay? _selectedTime;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween(begin: const Offset(0, .25), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutExpo),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _subjectController.dispose();
    _capacityController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // ------- PICKERS -------

  Future<void> _pickDate() async {
    final picked = await showDialog<Jalali>(
      context: context,
      builder: (context) => ShamsiDatePickerDialog(
        initialDate: Jalali.now(),
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  // ------- SUBMIT -------

  Future<void> _submit() async {
    if (_titleController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفا تمام فیلدها را پر کنید')),
      );
      return;
    }

    try {
      final examData = {
        "title": _titleController.text,
        "subject": _subjectController.text,
        "date": _dateController.text,
        "classTime": _timeController.text,
        "capacity": int.tryParse(_capacityController.text) ?? 0,
        "duration": int.tryParse(_durationController.text) ?? 0,
        "status": "upcoming",
        "possibleScore": 20,
        "students": 0
      };

      await ApiService.createExam(widget.userId, examData);

      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'افزودن امتحان جدید',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // fields
                _input('عنوان', 'مثال: آزمون ریاضی', _titleController),
                const SizedBox(height: 14),
                _input('درس', 'مثال: ریاضی', _subjectController),
                const SizedBox(height: 14),

                // date + time
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: _input('تاریخ', '1403/09/12', _dateController),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: AbsorbPointer(
                          child: _input('ساعت', '09:00', _timeController),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                _input('مدت (دقیقه)', '90', _durationController, number: true),
                const SizedBox(height: 14),
                _input('ظرفیت', '100', _capacityController, number: true),

                const SizedBox(height: 26),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('ایجاد', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(String label, String hint, TextEditingController controller,
      {bool number = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        )
      ],
    );
  }
}
