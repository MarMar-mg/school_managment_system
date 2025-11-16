import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../applications/role.dart';
import '../../../../../commons/utils/manager/date_manager.dart';
import '../../../../../core/services/api_service.dart';
import '../widgets/add_edit_dialog.dart';
import '../widgets/assignment_card.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/stat_card.dart';
import '../widgets/header_section.dart';
import '../widgets/section_divider.dart';

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

  List<dynamic> _assignments = [];
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _animations = List.generate(_assignments.length + 4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 + (index * 0.1), 1.0, curve: Curves.easeOutCubic),
        ),
      );
    });

    _controller.forward();
  }

  Future<void> _fetchData() async {
    try {
      setState(() => _isLoading = true);
      final assignments = await ApiService.getTeacherAssignments(widget.userId);
      final courses = await ApiService.getCourses(Role.teacher, widget.userId);

      setState(() {
        _assignments = assignments;
        _courses = courses;
        _isLoading = false;
        _error = '';
      });

      _initializeAnimations();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteData(int exID) async {
    try {
      await ApiService.deleteTeacherAssignment(exID, widget.userId);
      setState(() => _isLoading = true);
      final assignments = await ApiService.getTeacherAssignments(widget.userId);
      final courses = await ApiService.getCourses(Role.teacher, widget.userId);

      setState(() {
        _assignments = assignments;
        _courses = courses;
        _isLoading = false;
        _error = '';
      });

      _initializeAnimations();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Color _getColor(String subject) {
    if (subject.contains('ریاضی')) return Colors.purple;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: Colors.purple,
        child: _isLoading
            ? _buildShimmerState()
            : _error.isNotEmpty
            ? _buildErrorState()
            : _buildSuccessState(),
      ),
    );
  }

  // ==================== SHIMMER LOADING STATE ====================

  Widget _buildShimmerState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer Header
              _buildShimmerHeader(),
              const SizedBox(height: 24),
              _buildShimmerDivider(),
              const SizedBox(height: 24),

              // Shimmer Stats
              _buildShimmerStats(),
              const SizedBox(height: 24),

              // Shimmer Title
              _buildShimmerTitle(),
              const SizedBox(height: 16),

              // Shimmer Cards
              ...List.generate(4, (_) => const _ShimmerAssignmentCard()).map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: card,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildShimmerDivider() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(height: 2, color: Colors.white),
    );
  }

  Widget _buildShimmerStats() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = constraints.maxWidth > 600 ? 16.0 : 12.0;
          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerTitle() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        width: 120,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ==================== ERROR STATE ====================

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'خطا در بارگذاری',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _error,
              style: const TextStyle(color: Colors.red),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUCCESS STATE ====================

  Widget _buildSuccessState() {
    if (_assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'تمرینی یافت نشد',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Header
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

              // Animated Stats Row
              _buildAnimatedWidget(
                index: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = constraints.maxWidth > 600 ? 16.0 : 12.0;
                    return Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            count:
                                '${_assignments.where((a) {
                                  final dueDate = DateFormatManager.convertToDateTime(a['dueDate']);
                                  return dueDate.isAfter(DateTime.now());
                                }).length}',
                            label: 'تمرین فعال',
                          ),
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          child: StatCard(
                            count: '${_assignments.length - _assignments.where((a) {
                              final dueDate = DateFormatManager.convertToDateTime(a['dueDate']);
                              return dueDate.isAfter(DateTime.now());
                            }).length}',
                            label: 'تمرین غیر فعال',
                          ),
                        ),
                        SizedBox(width: spacing),
                        // Expanded(
                        //   child: const StatCard(
                        //     count: '25',
                        //     label: 'نیاز به بررسی',
                        //   ),
                        // ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Animated Section Title
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

              // Animated Assignment Cards
              ..._assignments.asMap().entries.map((entry) {
                final index = entry.key + 4;
                final data = entry.value;
                data['color'] = _getColor(data['subject']);

                return _buildAnimatedWidget(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AssignmentCard(
                      data: data,
                      onDelete: () => showDeleteDialog(
                        context,
                        _deleteData(data['id']) as VoidCallback,
                        assignment: data,
                      ),
                      // _deleteData(data['id']),
                      onEdit: () => showAddEditDialog(
                        context,
                        assignment: data,
                        isAdd: false,
                        courses: _courses,
                        userId: widget.userId,
                        addData: _fetchData,
                      ),
                      onView: () {},
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SHIMMER CARD WIDGET ====================

class _ShimmerAssignmentCard extends StatelessWidget {
  const _ShimmerAssignmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
