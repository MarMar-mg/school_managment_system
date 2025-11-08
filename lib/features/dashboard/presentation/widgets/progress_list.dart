import 'package:flutter/material.dart';
import '../../../../applications/colors.dart';
import '../../../../applications/role.dart';
import '../../../../core/services/api_service.dart';
import '../models/dashboard_models.dart';

class ProgressList extends StatefulWidget {
  final Role role;
  final int userId;

  const ProgressList({super.key, required this.role, required this.userId});

  @override
  State<ProgressList> createState() => _ProgressListState();
}

class _ProgressListState extends State<ProgressList> {
  late Future<List<ProgressItem>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = ApiService.getProgress(
      role: widget.role,
      userId: widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProgressItem>>(
      future: _progressFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Text('هیچ داده‌ای موجود نیست');
          }
          return Column(
            children: items.map((item) => ProgressCard(item: item)).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('خطا: ${snapshot.error}');
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class ProgressCard extends StatelessWidget {
  final ProgressItem item;

  const ProgressCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Grade Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.grade,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Progress Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),

                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: item.percentage / 100,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Percentage
          Text(
            '${item.percentage.toInt()}٪',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
