import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../applications/role.dart';
import '../../../../../commons/utils/manager/date_manager.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../applications/colors.dart';
import '../../../../../commons/responsive_container.dart';
import '../widgets/add_edit_dialog.dart';
import '../widgets/assignment_section.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/header_section.dart';
import '../../../../../commons/widgets/section_divider.dart';
import '../widgets/stat_card.dart';

class AssignmentManagementPage extends StatefulWidget {
  final int userId;

  const AssignmentManagementPage({super.key, required this.userId});

  @override
  State<AssignmentManagementPage> createState() => _AssignmentManagementPageState();
}

class _AssignmentManagementPageState extends State<AssignmentManagementPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  List<dynamic> _activeAssignments = [];
  List<dynamic> _inactiveAssignments = [];
  List<Map<String, dynamic>> _courses = [];

  bool _isLoading = true;
  String _error = '';

  final Map<String, bool> _expanded = {
    'active': false,
    'inactive': false,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);
      final assignments = await ApiService.getTeacherAssignments(widget.userId);
      final courses = await ApiService.getCourses(Role.teacher, widget.userId);

      final now = DateTime.now();

      _activeAssignments = assignments.where((a) {
        try {
          final dueDate = DateFormatManager.convertToDateTime(a['dueDate']);
          return dueDate.isAfter(now);
        } catch (e) {
          return false;
        }
      }).toList();

      _inactiveAssignments = assignments.where((a) {
        try {
          final dueDate = DateFormatManager.convertToDateTime(a['dueDate']);
          return !dueDate.isAfter(now);
        } catch (e) {
          return true;
        }
      }).toList();

      setState(() {
        _courses = courses;
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

  void _initializeAnimations() {
    final totalCount = _activeAssignments.length + _inactiveAssignments.length;
    _animations = List.generate(
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

  Future<void> _deleteAssignment(int exID) async {
    try {
      await ApiService.deleteTeacherAssignment(exID, widget.userId);
      _fetchData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در حذف: $e')),
        );
      }
    }
  }

  Widget _buildAnimatedWidget({required int index, required Widget child}) {
    if (_animations.isEmpty || index >= _animations.length) {
      return child;
    }

    return AnimatedBuilder(
      animation: _animations[index],
      builder: (context, _) {
        final value = _animations[index].value;
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
        onRefresh: _fetchData,
        color: AppColor.purple,
        child: _isLoading
            ? _buildShimmer()
            : _error.isNotEmpty
            ? _buildError()
            : _buildSuccess(),
      ),
    );
  }

  // ==================== SHIMMER CARD WIDGET ====================
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
          const Text('خطا در بارگذاری تمرین‌ها'),
          const SizedBox(height: 8),
          Text(_error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    if (_activeAssignments.isEmpty && _inactiveAssignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: AppColor.lightGray),
            const SizedBox(height: 16),
            const Text('تمرینی وجود ندارد', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => showAddEditDialog(
                context,
                courses: _courses,
                userId: widget.userId,
                addData: _fetchData,
                isAdd: true,
              ),
              icon: const Icon(Icons.add),
              label: const Text('افزودن تمرین'),
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
                onAdd: () => showAddEditDialog(
                  context,
                  courses: _courses,
                  userId: widget.userId,
                  addData: _fetchData,
                  isAdd: true,
                ),
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
                      count: '${_activeAssignments.length}',
                      label: 'تمرین فعال',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      count: '${_inactiveAssignments.length}',
                      label: 'تمرین غیر فعال',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _buildAnimatedWidget(
              index: 3,
              child: const Text(
                'تمرین‌های من',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 16),

            // Active Assignments Section
            AssignmentTeacherSection(
              title: 'فعال',
              color: Colors.orange,
              items: _activeAssignments,
              startIndex: cardIndex,
              sectionKey: 'active',
              isExpanded: _expanded['active']!,
              onToggle: () => _toggle('active'),
              animations: _animations,
              onEdit: (data) => showAddEditDialog(
                context,
                assignment: data,
                isAdd: false,
                courses: _courses,
                userId: widget.userId,
                addData: _fetchData,
              ),
              onDelete: (data) => showDeleteDialog(
                context,
                    () => _deleteAssignment(data['id']),
                assignment: data,
              ),
            ),
            const SizedBox(height: 24),

            // Inactive Assignments Section
            AssignmentTeacherSection(
              title: 'غیر فعال',
              color: Colors.grey,
              items: _inactiveAssignments,
              startIndex: cardIndex + _activeAssignments.length,
              sectionKey: 'inactive',
              isExpanded: _expanded['inactive']!,
              onToggle: () => _toggle('inactive'),
              animations: _animations,
              onEdit: (data) => showAddEditDialog(
                context,
                assignment: data,
                isAdd: false,
                courses: _courses,
                userId: widget.userId,
                addData: _fetchData,
              ),
              onDelete: (data) => showDeleteDialog(
                context,
                    () => _deleteAssignment(data['id']),
                assignment: data,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}