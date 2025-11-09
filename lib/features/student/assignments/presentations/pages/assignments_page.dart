import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../applications/colors.dart';
import '../../../../../applications/role.dart';
import '../../../../../core/services/api_service.dart';
import '../../models/assignment_model.dart.dart';
import '../widgets/assignment_section.dart';
import '../widgets/stats_row.dart';

class AssignmentsPage extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const AssignmentsPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage>
    with TickerProviderStateMixin {
  late Future<Map<String, List<AssignmentItemm>>> _assignmentsFuture;
  late AnimationController _controller;
  late List<Animation<double>> _cardAnims = [];

  final Map<String, bool> _expanded = {
    'pending': false,
    'submitted': false,
    'graded': false,
  };

  @override
  void initState() {
    super.initState();
    _assignmentsFuture = ApiService.getAllAssignments(widget.userId);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimations(int totalCount) {
    _cardAnims = List.generate(
      totalCount,
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

  Future<void> _refresh() async {
    setState(() {
      _assignmentsFuture = ApiService.getAllAssignments(widget.userId);
      _expanded.updateAll((k, v) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'تکالیف من',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColor.darkText,
      ),
      body: FutureBuilder<Map<String, List<AssignmentItemm>>>(
        future: _assignmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const _ShimmerAssignmentsPage();
          }

          final data = snapshot.data!;
          final pending = data['pending'] ?? [];
          final submitted = data['submitted'] ?? [];
          final graded = data['graded'] ?? [];
          final all = [...pending, ...submitted, ...graded];

          if (all.isEmpty) {
            return _buildEmpty();
          }

          // Start animation once
          if (_cardAnims.length != all.length) {
            _startAnimations(all.length);
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColor.purple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats
                  AnimatedStatsRow(
                    pending: pending.length,
                    submitted: submitted.length,
                    graded: graded.length,
                  ),
                  const SizedBox(height: 28),

                  // Sections
                  AssignmentSection(
                    title: 'در انتظار ارسال',
                    color: Colors.blue.shade600,
                    items: pending,
                    startIndex: 0,
                    sectionKey: 'pending',
                    isExpanded: _expanded['pending']!,
                    onToggle: () => _toggle('pending'),
                    animations: _cardAnims,
                  ),
                  const SizedBox(height: 24),
                  AssignmentSection(
                    title: 'ارسال شده (بدون نمره)',
                    color: Colors.orange.shade600,
                    items: submitted,
                    startIndex: pending.length,
                    sectionKey: 'submitted',
                    isExpanded: _expanded['submitted']!,
                    onToggle: () => _toggle('submitted'),
                    animations: _cardAnims,
                  ),
                  const SizedBox(height: 24),
                  AssignmentSection(
                    title: 'نمره‌دار',
                    color: Colors.green.shade600,
                    items: graded,
                    startIndex: pending.length + submitted.length,
                    sectionKey: 'graded',
                    isExpanded: _expanded['graded']!,
                    onToggle: () => _toggle('graded'),
                    animations: _cardAnims,
                  ),
                  const SizedBox(height: 100), // Extra space for pull-to-refresh
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text('خطا در بارگذاری تکالیف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: AppColor.lightGray)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: AppColor.lightGray),
          const SizedBox(height: 16),
          const Text(
            'تکلیفی یافت نشد',
            style: TextStyle(fontSize: 16, color: AppColor.lightGray),
          ),
        ],
      ),
    );
  }
}

// Subtle fade-in for StatsRow
class AnimatedStatsRow extends StatelessWidget {
  final int pending, submitted, graded;

  const AnimatedStatsRow({
    super.key,
    required this.pending,
    required this.submitted,
    required this.graded,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: StatsRow(pending: pending, submitted: submitted, graded: graded),
    );
  }
}

// Full-page shimmer
class _ShimmerAssignmentsPage extends StatelessWidget {
  const _ShimmerAssignmentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats placeholder
            Container(height: 100, color: Colors.white, margin: const EdgeInsets.only(bottom: 28)),
            // 3 sections
            ...List.generate(3, (_) => Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            )),
          ],
        ),
      ),
    );
  }
}