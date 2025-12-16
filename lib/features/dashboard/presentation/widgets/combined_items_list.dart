import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../../../applications/colors.dart';
import '../../../../core/services/api_service.dart';

import '../../../student/exam/entities/models/exam_model.dart';
import '../../../student/assignments/data/models/assignment_model.dart.dart';

import '../../../student/exam/presentations/widgets/exam_card.dart';
import '../../../student/assignments/presentations/widgets/assignment_card.dart';

class CombinedItemsList extends StatefulWidget {
  final int studentId;
  final VoidCallback? onRefresh;

  const CombinedItemsList({
    super.key,
    required this.studentId,
    this.onRefresh,
  });

  @override
  State<CombinedItemsList> createState() => _CombinedItemsListState();
}

class _CombinedItemsListState extends State<CombinedItemsList>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  List<ExamItem> _exams = [];
  List<AssignmentItemm> _assignments = [];

  bool _loading = true;
  String? _error;

  bool _examsExpanded = false;
  bool _assignmentsExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _loadItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= DATA =================

  Future<void> _loadItems() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final now = DateTime.now();
      final twoDaysLater = now.add(const Duration(days: 2));

      final examsResult = await ApiService.getAllExams(widget.studentId);
      final assignmentsResult =
      await ApiService.getAllAssignments(widget.studentId);

      final exams = <ExamItem>[
        ...examsResult['pending'] ?? [],
        ...examsResult['answered'] ?? [],
        ...examsResult['scored'] ?? [],
      ].where((e) {
        final d = _parseDate(e.dueDate);
        return d.isAfter(now) && d.isBefore(twoDaysLater);
      }).toList()
        ..sort((a, b) =>
            _parseDate(a.dueDate).compareTo(_parseDate(b.dueDate)));

      final assignments = <AssignmentItemm>[
        ...assignmentsResult['pending'] ?? [],
        ...assignmentsResult['submitted'] ?? [],
        ...assignmentsResult['graded'] ?? [],
      ].where((a) {
        final d = _parseDate(a.dueDate);
        return d.isAfter(now) && d.isBefore(twoDaysLater);
      }).toList()
        ..sort((a, b) =>
            _parseDate(a.dueDate).compareTo(_parseDate(b.dueDate)));

      setState(() {
        _exams = exams;
        _assignments = assignments;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now().add(const Duration(days: 9999));
    }

    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final j = Jalali(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final g = j.toGregorian();
      return DateTime(g.year, g.month, g.day);
    }

    return DateTime.now().add(const Duration(days: 9999));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildShimmer();
    if (_error != null) return _buildError();
    if (_exams.isEmpty && _assignments.isEmpty) return _buildEmpty();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [

          if (_exams.isNotEmpty)
            _buildExpandableSection(
              title: 'امتحانات پیش رو',
              icon: Icons.quiz_outlined,
              expanded: _examsExpanded,
              onToggle: () =>
                  setState(() => _examsExpanded = !_examsExpanded),
              children: _exams.map((e) {
                return ExamCard(
                  item: e,
                  userId: widget.studentId,
                  onRefresh: _loadItems,
                );
              }).toList(),
            ),

          if (_assignments.isNotEmpty)
            _buildExpandableSection(
              title: 'تکالیف پیش رو',
              icon: Icons.assignment_outlined,
              expanded: _assignmentsExpanded,
              onToggle: () => setState(
                      () => _assignmentsExpanded = !_assignmentsExpanded),
              children: _assignments.map((a) {
                return AssignmentCard(
                  item: a,
                  userId: widget.studentId,
                  onRefresh: _loadItems,
                  isDone:
                  a.status == 'graded' || a.status == 'submitted',
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ================= EXPANDABLE SECTION =================

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [

          // HEADER
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: AppColor.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),

          // BODY
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: children
                    .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                ))
                    .toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ================= STATES =================

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text('خطا در بارگذاری', style: TextStyle(color: Colors.red)),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'هیچ امتحان یا تکلیفی وجود ندارد',
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
