// features/dashboard/presentation/widgets/assignments_list.dart
import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../models/dashboard_models.dart';
import '../../../../core/services/api_service.dart';

class AssignmentsList extends StatefulWidget {
  final int studentId;

  const AssignmentsList({Key? key, required this.studentId}) : super(key: key);

  @override
  State<AssignmentsList> createState() => _AssignmentsListState();
}

class _AssignmentsListState extends State<AssignmentsList> {
  late Future<List<AssignmentItem>> _assignmentsFuture;

  @override
  void initState() {
    super.initState();
    _assignmentsFuture = ApiService.getUpcomingAssignments(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssignmentItem>>(
      future: _assignmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'خطا: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
              textDirection: TextDirection.rtl,
            ),
          );
        }

        final assignments = snapshot.data ?? [];

        if (assignments.isEmpty) {
          return const Center(
            child: Text(
              'تمرین یا امتحانی در دو روز آینده نیست',
              style: TextStyle(color: AppColor.lightGray),
              textDirection: TextDirection.rtl,
            ),
          );
        }

        return Column(
          children: assignments.map((item) => AssignmentCard(item: item)).toList(),
        );
      },
    );
  }
}

// AssignmentCard بدون تغییر
class AssignmentCard extends StatelessWidget {
  final AssignmentItem item;

  const AssignmentCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.badgeColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColor.darkText),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  item.subject,
                  style: const TextStyle(fontSize: 13, color: AppColor.lightGray),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: item.badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.badge,
              style: TextStyle(fontSize: 12, color: item.badgeColor, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}