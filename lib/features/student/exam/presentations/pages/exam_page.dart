import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/features/student/exam/entities/models/exam_model.dart';
import 'package:school_management_system/features/student/exam/presentations/widgets/exam_section.dart';
import 'package:school_management_system/features/student/assignments/presentations/widgets/stats_row.dart';

import '../../../../../commons/responsive_container.dart';

class ExamPage extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const ExamPage({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> with TickerProviderStateMixin {
  late Future<Map<String, List<ExamItem>>> _examsFuture;
  late AnimationController _controller;
  late List<Animation<double>> _cardAnims = [];

  final Map<String, bool> _expanded = {
    'pending': false,
    'answered_submitted': false,
    'answered_not_submitted': false,
    'scored': false,
  };

  @override
  void initState() {
    super.initState();
    _examsFuture = ApiService.getAllExams(widget.userId);
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
          curve: Interval(
            0.06 + (i * 0.04).clamp(0.0, 0.9),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    _controller.forward(from: 0.0);
  }

  void _toggle(String key) => setState(() => _expanded[key] = !_expanded[key]!);

  Future<void> _refresh() async {
    setState(() {
      _examsFuture = ApiService.getAllExams(widget.userId);
      _expanded.updateAll((_, __) => false);
      _cardAnims.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: FutureBuilder<Map<String, List<ExamItem>>>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildError(snapshot.error.toString());
          if (!snapshot.hasData) return const _ShimmerExamPage();

          final data = snapshot.data!;
          final pending = data['pending'] ?? [];
          final answered = data['answered'] ?? [];
          final scored = data['scored'] ?? [];

          // Separate answered into submitted and not submitted
          final answeredSubmitted = answered.where((e) => e.submittedDate != null).toList();
          final answeredNotSubmitted = answered.where((e) => e.submittedDate == null).toList();

          final all = [...pending, ...answeredSubmitted, ...answeredNotSubmitted, ...scored];

          if (all.isEmpty) return _buildEmpty();

          if (_cardAnims.isEmpty && all.isNotEmpty) {
            _startAnimations(all.length);
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColor.purple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ResponsiveContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      AnimatedStatsRow(
                        pending: pending.length,
                        submitted: answeredSubmitted.length,
                        graded: scored.length,
                      ),
                      const SizedBox(height: 28),

                      // Pending Section
                      ExamSection(
                        title: 'در انتظار',
                        color: Colors.orange,
                        items: pending,
                        startIndex: 0,
                        sectionKey: 'pending',
                        isExpanded: _expanded['pending']!,
                        onToggle: () => _toggle('pending'),
                        animations: _cardAnims,
                      ),
                      const SizedBox(height: 24),

                      // Answered - Submitted Section
                      ExamSection(
                        title: 'ارسال شده',
                        color: Colors.blue,
                        items: answeredSubmitted,
                        startIndex: pending.length,
                        sectionKey: 'answered_submitted',
                        isExpanded: _expanded['answered_submitted']!,
                        onToggle: () => _toggle('answered_submitted'),
                        animations: _cardAnims,
                      ),
                      const SizedBox(height: 24),

                      // Answered - Not Submitted Section
                      if (answeredNotSubmitted.isNotEmpty) ...[
                        ExamSection(
                          title: 'ارسال نشده',
                          color: Colors.red,
                          items: answeredNotSubmitted,
                          startIndex: pending.length + answeredSubmitted.length,
                          sectionKey: 'answered_not_submitted',
                          isExpanded: _expanded['answered_not_submitted']!,
                          onToggle: () => _toggle('answered_not_submitted'),
                          animations: _cardAnims,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Scored Section
                      ExamSection(
                        title: 'نمره‌دار',
                        color: Colors.green,
                        items: scored,
                        startIndex: pending.length + answeredSubmitted.length + answeredNotSubmitted.length,
                        sectionKey: 'scored',
                        isExpanded: _expanded['scored']!,
                        onToggle: () => _toggle('scored'),
                        animations: _cardAnims,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text('خطا در بارگذاری امتحانات'),
          const SizedBox(height: 8),
          Text(msg, textAlign: TextAlign.center),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: AppColor.lightGray),
          const SizedBox(height: 16),
          const Text('هیچ امتحانی یافت نشد'),
        ],
      ),
    );
  }
}

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
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 30 * (1 - v)), child: c),
      ),
      child: StatsRow(pending: pending, submitted: submitted, graded: graded),
    );
  }
}

class _ShimmerExamPage extends StatelessWidget {
  const _ShimmerExamPage();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.grey[100]!,
    highlightColor: Colors.grey[300]!,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 100,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 28),
          ),
          ...List.generate(
            4,
                (_) => Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}