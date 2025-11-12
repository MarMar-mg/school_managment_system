import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/features/student/exam/models/exam_model.dart';
import 'package:school_management_system/features/student/exam/presentations/widgets/exam_section.dart';
import 'package:school_management_system/features/student/assignments/presentations/widgets/stats_row.dart';

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
    'answered': false,
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
          curve: Interval(0.06 + i * 0.04, 1.0, curve: Curves.easeOutCubic),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'امتحانات من',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColor.darkText,
      ),
      body: FutureBuilder<Map<String, List<ExamItem>>>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildError(snapshot.error.toString());
          if (!snapshot.hasData) return const _ShimmerExamPage();

          final data = snapshot.data!;
          final pending = data['pending'] ?? [];
          final answered = data['answered'] ?? [];
          final scored = data['scored'] ?? [];
          final all = [...pending, ...answered, ...scored];

          if (all.isEmpty) return _buildEmpty();

          if (_cardAnims.length != all.length) _startAnimations(all.length);

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColor.purple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AnimatedStatsRow(
                    pending: pending.length,
                    submitted: answered.length,
                    graded: scored.length,
                  ),
                  const SizedBox(height: 28),
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
                  ExamSection(
                    title: 'ارسال شده',
                    color: Colors.blue,
                    items: answered,
                    startIndex: pending.length,
                    sectionKey: 'answered',
                    isExpanded: _expanded['answered']!,
                    onToggle: () => _toggle('answered'),
                    animations: _cardAnims,
                  ),
                  const SizedBox(height: 24),
                  ExamSection(
                    title: 'نمره‌دار',
                    color: Colors.green,
                    items: scored,
                    startIndex: pending.length + answered.length,
                    sectionKey: 'scored',
                    isExpanded: _expanded['scored']!,
                    onToggle: () => _toggle('scored'),
                    animations: _cardAnims,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String msg) => Center(child: Text('Error: $msg'));

  Widget _buildEmpty() => const Center(child: Text('هیچ امتحانی یافت نشد'));
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
            3,
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
