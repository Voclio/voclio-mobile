import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final int index;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
    this.index = 0,
  });

  IconData _getIcon() {
    switch (notification.type.toLowerCase()) {
      case 'task':
        return Icons.check_circle;
      case 'reminder':
        return Icons.alarm;
      case 'achievement':
        return Icons.emoji_events;
      case 'system':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  Color _getColor() {
    if (notification.priority.toLowerCase() == 'urgent') {
      return Colors.red;
    }
    if (notification.priority.toLowerCase() == 'high') {
      return Colors.orange;
    }
    switch (notification.type.toLowerCase()) {
      case 'task':
        return Colors.blue;
      case 'reminder':
        return Colors.orange;
      case 'achievement':
        return Colors.amber;
      case 'system':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor();
    
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade300, Colors.red.shade500],
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: notification.isRead 
            ? null 
            : Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: notification.isRead 
                ? Colors.black.withOpacity(0.04)
                : theme.primaryColor.withOpacity(0.1),
              blurRadius: notification.isRead ? 10 : 20,
              offset: const Offset(0, 4),
              spreadRadius: notification.isRead ? 0 : 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container with gradient
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: color.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getIcon(),
                      color: color,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 10.w,
                                height: 10.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.primaryColor,
                                      theme.primaryColor.withOpacity(0.7),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primaryColor.withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1000.ms),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _formatTime(notification.createdAt),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Swipe hint
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swipe_left_rounded,
                                  size: 14.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Swipe to delete',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms, delay: (index * 80).ms)
    .slideX(begin: 0.1, end: 0, delay: (index * 80).ms);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
