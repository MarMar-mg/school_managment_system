import 'package:flutter/material.dart';
import 'package:school_management_system/applications/colors.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/notification_model.dart';

class NotificationTile extends StatefulWidget {
  final NotificationModel notification;
  final int delay;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.delay,
    this.onMarkRead,
    this.onDelete,
    this.onTap,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>
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

          if (widget.onTap != null) {
            widget.onTap!();
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], height: 1.3),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  onPressed: widget.onDelete,
                  tooltip: 'حذف',
                ),
                if (unread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
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
      case 'exercise':
        return Icons.assignment_turned_in_rounded;
      case 'announcement':
      case 'event':
        return Icons.campaign_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
