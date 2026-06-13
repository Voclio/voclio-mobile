import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:voclio_app/core/icons/app_icons.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
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
        return AppIcons.check_circle;
      case 'reminder':
        return AppIcons.alarm;
      case 'achievement':
        return AppIcons.emoji_events;
      case 'system':
        return AppIcons.settings;
      default:
        return AppIcons.info;
    }
  }

  Color _getColor() {
    if (notification.priority.toLowerCase() == 'urgent') {
      return HomeSystemTokens.coral;
    }
    if (notification.priority.toLowerCase() == 'high') {
      return HomeSystemTokens.orange;
    }
    switch (notification.type.toLowerCase()) {
      case 'task':
        return HomeSystemTokens.blue;
      case 'reminder':
        return HomeSystemTokens.orange;
      case 'achievement':
        return Colors.amber.shade700;
      case 'system':
        return HomeSystemTokens.inkMuted;
      default:
        return HomeSystemTokens.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: HomeSystemTokens.coral,
          borderRadius: BorderRadius.circular(HomeSystemTokens.radiusLg.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(AppIcons.delete_rounded, color: Colors.white, size: 22.sp),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: HomeSystemTokens.cardDecoration(
            tint: isUnread
                ? HomeSystemTokens.blue.withValues(alpha: 0.03)
                : HomeSystemTokens.card,
          ).copyWith(
            border: isUnread
                ? Border.all(
                    color: HomeSystemTokens.blue.withValues(alpha: 0.2),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(HomeSystemTokens.radiusSm.r),
                ),
                child: Icon(_getIcon(), color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            textDirection: TextDirection.ltr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: HomeSystemTokens.ink,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          SizedBox(width: 8.w),
                          Container(
                            width: 7.r,
                            height: 7.r,
                            decoration: const BoxDecoration(
                              color: HomeSystemTokens.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.message,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: HomeSystemTokens.inkSoft,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          AppIcons.access_time_rounded,
                          size: 12.sp,
                          color: HomeSystemTokens.inkMuted,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: HomeSystemTokens.inkMuted,
                            fontWeight: FontWeight.w500,
                          ),
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
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideX(begin: 0.05, end: 0, delay: (index * 50).ms);
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
