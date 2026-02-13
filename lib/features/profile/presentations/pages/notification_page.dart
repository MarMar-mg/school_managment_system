// features/profile/presentations/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:school_management_system/applications/colors.dart';
import 'package:school_management_system/commons/responsive_container.dart';
import 'package:school_management_system/core/services/api_service.dart';
import '../../data/models/notification_model.dart'; // ← your new model

class NotificationsPage extends StatefulWidget {
  final int userId;

  const NotificationsPage({super.key, required this.userId});

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اعلان‌ها'),
        centerTitle: true,
        backgroundColor: AppColor.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: ResponsiveContainer(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerList();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
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
                  return _AnimatedNotificationTile(
                    notification: _notifications[index],
                    delay: index * 80,
                    onMarkRead: () => _markAsRead(index),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 26,
            ),
            title: Container(width: 180, height: 16, color: Colors.white),
            subtitle: Container(
              width: 240,
              height: 12,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 90,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'هیچ اعلانی در حال حاضر وجود ندارد',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _fetchNotifications,
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 80, color: Colors.red[400]),
          const SizedBox(height: 24),
          Text(
            'خطا در بارگذاری اعلان‌ها',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.red[700]),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.purple),
          ),
        ],
      ),
    );
  }

  void _markAsRead(int index) {
    setState(() {
      // optimistic update
      final updated = List<NotificationModel>.from(_notifications);
      updated[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        createdAt: _notifications[index].createdAt,
        isRead: true,
        type: _notifications[index].type,
      );
      _notifications = updated;
    });
  }
}

// ──────────────────────────────────────────────
// Keep your beautiful _AnimatedNotificationTile
// (just add onMarkRead callback if you want to call API)
// ──────────────────────────────────────────────

class _AnimatedNotificationTile extends StatefulWidget {
  final NotificationModel notification;
  final int delay;
  final VoidCallback? onMarkRead;

  const _AnimatedNotificationTile({
    required this.notification,
    required this.delay,
    this.onMarkRead,
  });

  @override
  State<_AnimatedNotificationTile> createState() =>
      __AnimatedNotificationTileState();
}

class __AnimatedNotificationTileState extends State<_AnimatedNotificationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _tapController.forward().then((_) => _tapController.reverse());
      }
    });
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final unread = !n.isRead;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) async {
          _tapController.reverse();
          if (unread) {
            try {
              await ApiService().markNotificationAsRead(widget.notification.id);
              if (widget.onMarkRead != null) widget.onMarkRead!();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('خطا: $e')));
              }
            }
          }
        },
        onTapCancel: () => _tapController.reverse(),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: unread ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: unread
                      ? AppColor.purple.withOpacity(0.15)
                      : Colors.grey[200],
                  child: Icon(
                    _getIcon(n.type),
                    color: unread ? AppColor.purple : Colors.grey[700],
                  ),
                ),
                if (unread) _buildPulseDot(),
              ],
            ),
            title: Text(
              n.title,
              style: TextStyle(
                fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                fontSize: 15.5,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                n.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], height: 1.3),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  n.relativeTime, // ← improve with real timeago later
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (unread) const SizedBox(height: 6),
                if (unread)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulseDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.4),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: 1.5 - value, child: child),
        );
      },
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'grade':
        return Icons.grade_rounded;
      case 'assignment':
        return Icons.assignment_turned_in_rounded;
      case 'announcement':
      case 'event':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
