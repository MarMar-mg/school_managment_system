import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/applications/role.dart';
import 'package:school_management_system/core/services/api_service.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import '../widgets/stats_section.dart';
import '../widgets/classes_list_section.dart';
import '../widgets/score_distribution_section.dart';
import '../widgets/subject_scores_section.dart';
import '../widgets/top_performers_section.dart';

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
      return await ApiService.getAdminOverview();
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
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),
                  // Stats Section
                  FutureBuilder<List<dynamic>>(
                    future: _overviewFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return StatsSection(overviewData: snapshot.data ?? []);
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 24),
                  // Classes List Section
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
                        return _EmptyClassesState();
                      }

                      return Column(
                        children: [
                          ClassesListSection(
                            classes: classes,
                            selectedClassId: _selectedClassId,
                            onClassSelected: _loadClassDetails,
                          ),
                          const SizedBox(height: 24),
                          // Class Details Section
                          if (_selectedClassId != null)
                            _ClassDetailsContainer(
                              classId: _selectedClassId!,
                              classDetailsCache: _classDetailsCache,
                              isLoading: _isLoadingDetails,
                            ),
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
          style: TextStyle(fontSize: 14, color: AppColor.lightGray),
          textDirection: TextDirection.rtl,
        ),
      ],
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

class _ClassDetailsContainer extends StatelessWidget {
  final int classId;
  final Map<int, Map<String, dynamic>> classDetailsCache;
  final bool isLoading;

  const _ClassDetailsContainer({
    required this.classId,
    required this.classDetailsCache,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(color: AppColor.purple),
      );
    }

    if (!classDetailsCache.containsKey(classId)) {
      return const SizedBox();
    }

    final data = classDetailsCache[classId]!;

    return Column(
      children: [
        ScoreDistributionSection(data: data),
        const SizedBox(height: 20),
        SubjectScoresSection(data: data),
        const SizedBox(height: 20),
        TopPerformersSection(data: data),
      ],
    );
  }
}

class _EmptyClassesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}