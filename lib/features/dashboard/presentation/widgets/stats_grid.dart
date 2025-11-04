// features/dashboard/presentation/widgets/stats_grid.dart
import 'package:flutter/material.dart';
import '../../../../applications/role.dart';
import '../models/dashboard_models.dart';
import '../../../../core/services/api_service.dart';

class StatsGrid extends StatefulWidget {
  final Role role;
  final int userId;

  const StatsGrid({
    Key? key,
    required this.role,
    required this.userId,
  }) : super(key: key);

  @override
  State<StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends State<StatsGrid> {
  late Future<List<StatCard>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getStats(widget.role, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    return FutureBuilder<List<StatCard>>(
      future: _statsFuture,
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

        final stats = snapshot.data ?? [];

        if (stats.isEmpty) {
          return const Center(
            child: Text(
              'آماری موجود نیست',
              style: TextStyle(color: Colors.grey),
              textDirection: TextDirection.rtl,
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: screenWidth > 600 ? 1.4 : 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return StatCardWidget(stat: stats[index]);
          },
        );
      },
    );
  }
}

// StatCardWidget بدون تغییر
class StatCardWidget extends StatelessWidget {
  final StatCard stat;

  const StatCardWidget({Key? key, required this.stat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [stat.color, stat.color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: stat.color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  stat.value,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                stat.label,
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const Spacer(),
              Text(
                stat.subtitle,
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}