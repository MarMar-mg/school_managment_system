import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';

class AdminClassScoreDashboard extends StatefulWidget {
  final Role role;
  final String userName;
  final int userId;

  const AdminClassScoreDashboard({
    super.key,
    required this.role,
    required this.userName,
    required this.userId,
  });

  @override
  State<AdminClassScoreDashboard> createState() =>
      _AdminClassScoreDashboardState();
}

class _AdminClassScoreDashboardState extends State<AdminClassScoreDashboard> {
  late Future<List<dynamic>> _classesFuture;
  late Future<List<dynamic>> _overviewFuture;

  int? _selectedClassId;
  Map<int, Map<String, dynamic>> _classDetailsCache = {};
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _classesFuture = _fetchClasses();
    _overviewFuture = _fetchOverview();
  }

  Future<List<dynamic>> _fetchClasses() async {
    try {
      final data = await ApiService.getAdminClasses();

      if (data.isNotEmpty) {
        _selectedClassId = data[0]['id'];
        _loadClassDetails(_selectedClassId!);
      }
      return data;
    } catch (e) {
      print('Error fetching classes: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> _fetchOverview() async {
    try {
      final data = await ApiService.getAdminOverview();
      return data;
    } catch (e) {
      print('Error fetching overview: $e');
      return [];
    }
  }

  Future<void> _loadClassDetails(int classId) async {
    if (_classDetailsCache.containsKey(classId)) {
      setState(() => _selectedClassId = classId);
      return;
    }

    setState(() => _isLoadingDetails = true);

    try {
      final data = await ApiService.getClassStatistics(classId);

      if (mounted) {
        setState(() {
          _classDetailsCache[classId] = data;
          _selectedClassId = classId;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      print('Error loading class details: $e');

      if (mounted) {
        setState(() => _isLoadingDetails = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در بارگذاری اطلاعات کلاس: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onRefresh() {
    setState(() {
      _classDetailsCache.clear();
      _selectedClassId = null;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async => _onRefresh(),
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
                  _buildHeader(),
                  const SizedBox(height: 24),
                  FutureBuilder<List<dynamic>>(
                    future: _classesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.purple,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildError(snapshot.error.toString());
                      }

                      final classes = snapshot.data ?? [];

                      if (classes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 80,
                                color: AppColor.lightGray,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'هیچ کلاسی یافت نشد',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.darkText,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          _buildTopStats(),
                          const SizedBox(height: 24),
                          _buildClassCards(classes),
                          const SizedBox(height: 24),
                          if (_selectedClassId != null)
                            _buildClassDetails(),
                          const SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'آمار عملکرد کلاس‌ها',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Text(
          'بررسی جامع عملکرد تحصیلی و نمرات هر کلاس',
          style: TextStyle(
            fontSize: 14,
            color: AppColor.lightGray,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildTopStats() {
    return FutureBuilder<List<dynamic>>(
      future: _overviewFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final overview = snapshot.data as List<dynamic>;
        double totalAvg = overview.isNotEmpty
            ? overview.fold<double>(
            0, (sum, c) => sum + ((c['avgScore'] as num?)?.toDouble() ?? 0)) /
            overview.length
            : 0;
        int totalStudents = overview.fold<int>(
            0, (sum, c) => sum + ((c['studentCount'] as num?)?.toInt() ?? 0));
        int totalClasses = overview.length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'میانگین کل',
                value: totalAvg.toStringAsFixed(1),
                icon: Icons.trending_up_rounded,
                color: AppColor.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'تعداد دانش‌آموز',
                value: '$totalStudents',
                icon: Icons.group_rounded,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'تعداد کلاس',
                value: '$totalClasses',
                icon: Icons.school_rounded,
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColor.lightGray,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildClassCards(List<dynamic> classes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'آمار پایه‌های تحصیلی',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.darkText,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        ...classes.map((cls) => _buildClassCard(cls)).toList(),
      ],
    );
  }

  Widget _buildClassCard(dynamic classData) {
    final isSelected = _selectedClassId == classData['id'];
    final studentCount = (classData['studentCount'] as num?)?.toInt() ?? 0;
    final avgScore = (classData['avgScore'] as num?)?.toDouble() ?? 0;
    final passPercentage = (classData['passPercentage'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: () => _loadClassDetails(classData['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.purple.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColor.purple : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColor.purple.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  classData['name'] ?? 'نام کلاس',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColor.purple : AppColor.darkText,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColor.purple.withOpacity(0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    classData['grade'] ?? 'نامشخص',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColor.purple
                          : AppColor.lightGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'میانگین',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.lightGray,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      avgScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.purple,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'درصد قبولی',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.lightGray,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$passPercentage%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعداد دانش‌آموز',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.lightGray,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$studentCount',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDetails() {
    if (_selectedClassId == null ||
        !_classDetailsCache.containsKey(_selectedClassId)) {
      if (_isLoadingDetails) {
        return const Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: AppColor.purple,
          ),
        );
      }
      return const SizedBox();
    }

    final data = _classDetailsCache[_selectedClassId]!;

    return Column(
      children: [
        // Score Distribution
        Container(
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'توزیع تفصیلی نمرات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              ...((data['scoreRanges'] as List<dynamic>?) ?? [])
                  .map((range) => _buildScoreRangeRow(range)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Subject Scores
        Container(
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'میانگین نمرات درسی',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              ...((data['subjectScores'] as List<dynamic>?) ?? [])
                  .map((subject) => _buildSubjectScoreRow(subject)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Top Performers
        Container(
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'برترین عملکردها',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.darkText,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              ...((data['topPerformers'] as List<dynamic>?) ?? [])
                  .map((performer) => _buildPerformerCard(performer)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRangeRow(dynamic range) {
    final count = (range['count'] as num?)?.toInt() ?? 0;
    final percentage = (range['percentage'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              range['range'] ?? 'نامشخص',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.darkText,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: percentage > 0 ? (percentage / 100.0) : 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$count نفر ($percentage%)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkText,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectScoreRow(dynamic subject) {
    final avgScore = (subject['avgScore'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            subject['name'] ?? 'نامشخص',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.darkText,
            ),
            textDirection: TextDirection.rtl,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.purple.withOpacity(0.3)),
            ),
            child: Text(
              avgScore.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColor.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformerCard(dynamic performer) {
    final avgScore = (performer['avgScore'] as num?)?.toDouble() ?? 0;
    final rank = (performer['rank'] as num?)?.toInt() ?? 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColor.purple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    performer['name'] ?? 'نامشخص',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkText,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    'نمره: ${avgScore.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.lightGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'خطا در بارگذاری اطلاعات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.lightGray),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.purple,
            ),
          ),
        ],
      ),
    );
  }
}