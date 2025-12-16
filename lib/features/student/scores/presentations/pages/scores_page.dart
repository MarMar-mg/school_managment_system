import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../../../../commons/responsive_container.dart';
import '../../data/models/score_model.dart';
import '../widgets/score_header_card.dart';
import '../widgets/score_card.dart';

class MyScorePage extends StatefulWidget {
  final int studentId;

  const MyScorePage({super.key, required this.studentId});

  @override
  State<MyScorePage> createState() => _MyScorePageState();
}

class _MyScorePageState extends State<MyScorePage> {
  late Future<DashboardData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = ApiService.getMyScore(widget.studentId);
  }

  Future<void> _refresh() async {
    setState(() {
      _dataFuture = ApiService.getMyScore(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColor.purple,
          child: FutureBuilder<DashboardData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildError(snapshot.error.toString());
              }
              if (!snapshot.hasData) return const _ShimmerMyScore();

              final data = snapshot.data!;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // === Header Card ===
                      ScoreHeaderCard(
                        studentName: data.studentName,
                        gpa: data.gpa,
                      ),

                      const SizedBox(height: 24),

                      // === Stat Cards ===
                      _buildStatRow(data.bells, data.courses, data.units),

                      const SizedBox(height: 32),

                      // === نمرات درس ===
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'نمرات درس',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.darkText,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // === Score Cards (One per subject) ===
                      ...data.grades.map((grade) {
                        // Mock sub‑scores (replace with real API later)
                        final subScores = _generateSubScores(
                          grade.avgExam,
                          grade.avgExercise,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ScoreCard(
                            subject: grade.name,
                            percent: grade.percent,

                            letterGrade: grade.letter,
                            subScores: subScores, studentId: widget.studentId,
                          ),
                        );
                      }),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Generate realistic sub‑scores
  List<SubScore> _generateSubScores(int avgexam, int avgexercise) {
    return [
      SubScore(percent: avgexercise, label: 'تکالیف'),
      SubScore(percent: avgexam, label: 'آزمون‌ها'),
    ];
  }

  int _clamp(int value) => value.clamp(0, 100);

  // ──────────────────────────────
  // Stat Row
  // ──────────────────────────────
  Widget _buildStatRow(int bells, int courses, int units) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(icon: Icons.book, label: 'دروس', value: courses),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(icon: Icons.school, label: 'واحد', value: units),
        ),
      ],
    );
  }

  // // ──────────────────────────────
  // // Bottom Nav
  // // ──────────────────────────────
  // Widget _buildBottomNav() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 20,
  //           offset: const Offset(0, -4),
  //         ),
  //       ],
  //     ),
  //     child: BottomNavigationBar(
  //       type: BottomNavigationBarType.fixed,
  //       selectedItemColor: AppColor.purple,
  //       unselectedItemColor: Colors.grey,
  //       items: const [
  //         BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
  //         BottomNavigationBarItem(icon: Icon(Icons.book), label: 'تکالیف'),
  //         BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'امتحانات'),
  //         BottomNavigationBarItem(icon: Icon(Icons.message), label: 'پیام‌ها'),
  //         BottomNavigationBarItem(icon: Icon(Icons.person), label: 'پروفایل'),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildError(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'خطا',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(msg, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refresh, child: const Text('تلاش مجدد')),
        ],
      ),
    );
  }
}

// ──────────────────────────────
// Reusable Stat Box
// ──────────────────────────────
class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColor.purple.withOpacity(0.8)),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// ──────────────────────────────
// Shimmer
// ──────────────────────────────
class _ShimmerMyScore extends StatelessWidget {
  const _ShimmerMyScore();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[300]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 180,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 24),
            ),
            Row(
              children: List.generate(
                3,
                (_) => Expanded(
                  child: Container(
                    height: 100,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(
              2,
              (_) => Container(
                height: 220,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
