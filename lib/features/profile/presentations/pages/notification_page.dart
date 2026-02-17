import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../../../applications/bottom_nav_bar.dart';
import '../../../../applications/role.dart';
import '../../data/models/notification_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_error_state.dart';
import '../widgets/notification_shimmer_list.dart';

class NotificationsPage extends StatefulWidget {
  final int userId;
  final Role role;
  final String userName;

  const NotificationsPage({
    super.key,
    required this.userId,
    required this.role,
    required this.userName,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchNotifications();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final fetched = await ApiService().getNotifications(widget.userId);

      setState(() {
        _notifications = fetched;
        _isLoading = false;
      });

      if (_controller.isDismissed) {
        _controller.forward();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _deleteNotification(int index) async {
    final notification = _notifications[index];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف اعلان'),
        content: const Text('آیا از حذف این اعلان مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('خیر'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('بله', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService().deleteNotification(notification.id);

      setState(() {
        _notifications.removeAt(index);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اعلان حذف شد'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showDeleteAllConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف همه اعلان‌ها'),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید تمام اعلان‌ها را حذف کنید؟\nاین عملیات قابل بازگشت نیست.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('خیر'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('بله، حذف همه', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Call API to delete all (you need to implement this in ApiService)
      await ApiService().deleteAllNotifications(widget.userId);

      setState(() {
        _notifications.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('همه اعلان‌ها با موفقیت حذف شدند'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در حذف همه اعلان‌ها: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'اعلان‌ها',
        bottomRadius: 5.0,           // smaller curve
        gradientColors: [
          AppColor.purple,
          AppColor.purple.withOpacity(0.85),
          AppColor.purple.withOpacity(0.7),
        ],
      ),
      floatingActionButton: _notifications.isNotEmpty && !_isLoading && !_hasError
          ? FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _showDeleteAllConfirmation,
        tooltip: 'حذف همه اعلان‌ها',
        child: const Icon(Icons.delete_sweep),
      )
          : null,
      body: ResponsiveContainer(
        child: _isLoading
            ? const NotificationShimmerList()
            : _hasError
            ? NotificationErrorState(
                errorMessage: _errorMessage,
                onRetry: _fetchNotifications,
              )
            : _notifications.isEmpty
            ? NotificationEmptyState(
                onRetry: _fetchNotifications, // pass if needed
              )
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: RefreshIndicator(
                        onRefresh: _fetchNotifications,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            return NotificationTile(
                              notification: _notifications[index],
                              delay: index * 80,
                              onMarkRead: () {
                                // optimistic update
                                setState(() {
                                  final updated = List<NotificationModel>.from(
                                    _notifications,
                                  );
                                  updated[index] = updated[index].copyWith(
                                    isRead: true,
                                  );
                                  _notifications = updated;
                                });
                              },
                              onDelete: () => _deleteNotification(index),
                              onTap: () {
                                if (!(_notifications[index].type ==
                                        "student_welcome" ||
                                    _notifications[index].type ==
                                        "teacher_welcome")) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BottomNavBar(
                                        role: widget.role,
                                        userName: widget.userName,
                                        userId: widget.userId.toString(),
                                        userIdi: widget.userId,
                                        selectedIndex:
                                            _notifications[index].type ==
                                                    "course_teacher_changed" ||
                                                _notifications[index].type ==
                                                    "course_teacher_removed" ||
                                                _notifications[index].type ==
                                                "teacher_course_assigned" ||
                                                _notifications[index].type ==
                                                "teacher_course_unassigned"
                                            ? 1
                                            : _notifications[index].type ==
                                                  "grade"
                                            ? 4
                                            : _notifications[index].type ==
                                                      "exam_updated" ||
                                                  _notifications[index].type ==
                                                      "exam" ||
                                                _notifications[index].type ==
                                                    "exam_teacher_update" ||
                                                _notifications[index].type ==
                                                    "exam_created"
                                            ? 3
                                            : _notifications[index].type ==
                                                      "exercise_updated" ||
                                                  _notifications[index].type ==
                                                      "exercise" ||
                                                  _notifications[index].type ==
                                                      "exercise_teacher_update" ||
                                                  _notifications[index].type ==
                                                      "exercise_created"
                                            ? 2
                                            : 0,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
