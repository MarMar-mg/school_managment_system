import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../applications/colors.dart';
import '../../../../../applications/role.dart';
import '../../../../../commons/responsive_container.dart';
import '../../../../../core/services/api_service.dart';
import '../../data/models/assignment_model.dart.dart';
import '../widgets/assignment_section.dart';
import '../widgets/shimmer_placeholder.dart';
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
  late AnimationController _controller;
  late List<Animation<double>> _cardAnims = [];

  List<AssignmentItemm> _pending = [];
  List<AssignmentItemm> _answered = [];
  List<AssignmentItemm> _notAnswered = [];
  List<AssignmentItemm> _scored = [];

  bool _isLoading = true;
  String _error = '';

  final Map<String, bool> _expanded = {
    'pending': false,
    'answered': false,
    'notAnswered': false,
    'scored': false,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fetchAssignments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchAssignments() async {
    try {
      setState(() => _isLoading = true);

      final data = await ApiService.getAllAssignments(widget.userId);

      // Organize assignments into correct categories
      _pending = [];
      _answered = [];
      _notAnswered = [];
      _scored = [];

      final pending = data['pending'] ?? [];
      final submitted = data['submitted'] ?? [];
      final graded = data['graded'] ?? [];

      // Pending: no deadline (status = 'pending')
      for (var item in pending) {
        if (item.status == 'pending') {
          _pending.add(item);
        }
      }

      // Answered: deadline passed AND has answer (status = 'submitted')
      for (var item in submitted) {
        if (item.status == 'submitted') {
          _answered.add(item);
        }
      }

      // Not Answered: deadline passed but NO answer (status = 'notSubmitted')
      for (var item in submitted) {
        if (item.status == 'notSubmitted') {
          _notAnswered.add(item);
        }
      }
      print(_notAnswered);

      // Scored: deadline passed AND answered AND graded (status = 'graded')
      for (var item in graded) {
        if (item.status == 'graded') {
          _scored.add(item);
        }
      }

      setState(() {
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
    final totalCount = _pending.length +
        _answered.length +
        _notAnswered.length +
        _scored.length;
    _cardAnims = List.generate(
      totalCount + 2, // +2 for header and stats
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
      _expanded.updateAll((_, __) => false);
      _cardAnims.clear();
    });
    await _fetchAssignments();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const ShimmerPlaceholder();
    if (_error.isNotEmpty) return _buildError();

    final all = [..._pending, ..._answered, ..._notAnswered, ..._scored];
    if (all.isEmpty) return _buildEmpty();

    if (_cardAnims.isEmpty) {
      _initializeAnimations();
    }

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: RefreshIndicator(
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

                  // === Animated Stats Row ===
                  AnimatedStatsRow(
                    pending: _pending.length,
                    submitted: _answered.length,
                    graded: _scored.length,
                  ),

                  const SizedBox(height: 28),

                  // === Pending Section (No Deadline) ===
                  AssignmentSection(
                    title: 'در انتظار',
                    color: Colors.orange,
                    items: _pending,
                    startIndex: 0,
                    sectionKey: 'pending',
                    isExpanded: _expanded['pending']!,
                    onToggle: () => _toggle('pending'),
                    animations: _cardAnims,
                    userId: widget.userId,
                    onRefresh: _refresh,
                  ),
                  const SizedBox(height: 24),

                  // === Answered Section (Deadline Passed, Has Answer) ===
                  AssignmentSection(
                    title: 'پاسخ داده شده',
                    color: Colors.blue,
                    items: _answered,
                    startIndex: _pending.length,
                    sectionKey: 'answered',
                    isExpanded: _expanded['answered']!,
                    onToggle: () => _toggle('answered'),
                    animations: _cardAnims,
                    userId: widget.userId,
                    onRefresh: _refresh,
                  ),
                  const SizedBox(height: 24),

                  // === Not Answered Section (Deadline Passed, No Answer) ===
                  AssignmentSection(
                    title: 'پاسخ داده نشده',
                    color: Colors.red,
                    items: _notAnswered,
                    startIndex: _pending.length + _answered.length,
                    sectionKey: 'notAnswered',
                    isExpanded: _expanded['notAnswered']!,
                    onToggle: () => _toggle('notAnswered'),
                    animations: _cardAnims,
                    userId: widget.userId,
                    onRefresh: _refresh,
                  ),
                  const SizedBox(height: 24),

                  // === Scored Section (Deadline Passed, Answered, Graded) ===
                  AssignmentSection(
                    title: 'نمره‌دار',
                    color: Colors.green,
                    items: _scored,
                    startIndex: _pending.length + _answered.length + _notAnswered.length,
                    sectionKey: 'scored',
                    isExpanded: _expanded['scored']!,
                    onToggle: () => _toggle('scored'),
                    animations: _cardAnims,
                    userId: widget.userId,
                    onRefresh: _refresh,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'خطا در بارگذاری تکالیف',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(_error, style: TextStyle(color: AppColor.lightGray)),
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
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 80,
            color: AppColor.lightGray,
          ),
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

// === Animated Stats Row ===
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
      child: StatsRow(
        pending: pending,
        submitted: submitted,
        graded: graded,
      ),
    );
  }
}