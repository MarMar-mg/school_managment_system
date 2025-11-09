import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../models/assignment_model.dart.dart';
import '../widgets/assignment_section.dart';
import '../widgets/stats_row.dart';
import '../widgets/shimmer_placeholder.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimations(int count) {
    _cardAnims = List.generate(count, (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.08 + i * 0.05, 1.0, curve: Curves.easeOutCubic)),
    ));
    _controller.forward(from: 0.0);
  }

  void _toggle(String key) => setState(() => _expanded[key] = !_expanded[key]!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: const Text('تکالیف من', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColor.darkText,
      ),
      body: FutureBuilder<Map<String, List<AssignmentItemm>>>(
        future: _assignmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطا: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData) return const ShimmerPlaceholder();

          final data = snapshot.data!;
          final pending = data['pending'] ?? [];
          final submitted = data['submitted'] ?? [];
          final graded = data['graded'] ?? [];
          final all = [...pending, ...submitted, ...graded];

          if (all.isEmpty) {
            return const Center(child: Text('تکلیفی یافت نشد', style: TextStyle(fontSize: 16, color: AppColor.lightGray)));
          }

          if (_cardAnims.length != all.length) _startAnimations(all.length);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _assignmentsFuture = ApiService.getAllAssignments(widget.userId);
                _expanded.updateAll((k, v) => false);
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StatsRow(pending: pending.length, submitted: submitted.length, graded: graded.length),
                  const SizedBox(height: 24),
                  AssignmentSection(
                    title: 'در انتظار ارسال',
                    color: Colors.blue,
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
                    color: Colors.orange,
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
                    color: Colors.green,
                    items: graded,
                    startIndex: pending.length + submitted.length,
                    sectionKey: 'graded',
                    isExpanded: _expanded['graded']!,
                    onToggle: () => _toggle('graded'),
                    animations: _cardAnims,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}