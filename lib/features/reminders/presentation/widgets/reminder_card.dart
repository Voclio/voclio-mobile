import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/core/icons/app_icons.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import '../../domain/entities/reminder_entity.dart';

class ReminderCard extends StatelessWidget {
  final ReminderEntity reminder;
  final VoidCallback? onSnooze;
  final VoidCallback? onDismiss;
  final VoidCallback? onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onSnooze,
    this.onDismiss,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = reminder.remindAt.isBefore(DateTime.now());
    final accent = !reminder.isActive
        ? HomeSystemTokens.inkMuted
        : isPast
            ? HomeSystemTokens.coral
            : HomeSystemTokens.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: HomeSystemTokens.cardDecoration(
        tint: !reminder.isActive
            ? HomeSystemTokens.canvas
            : HomeSystemTokens.card,
      ).copyWith(
        border: Border.all(
          color: accent.withValues(alpha: reminder.isActive ? 0.18 : 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(HomeSystemTokens.radiusSm.r),
            ),
            child: Icon(
              isPast ? AppIcons.notification_important : AppIcons.notifications_active,
              color: accent,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TypeChip(
                      label: _getTypeLabel(reminder.reminderType),
                      color: _getTypeColor(reminder.reminderType),
                    ),
                    if (isPast && reminder.isActive) ...[
                      SizedBox(width: 6.w),
                      _TypeChip(
                        label: 'Overdue',
                        color: HomeSystemTokens.coral,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  reminder.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: reminder.isActive
                        ? HomeSystemTokens.ink
                        : HomeSystemTokens.inkMuted,
                    decoration:
                        reminder.isActive ? null : TextDecoration.lineThrough,
                  ),
                ),
                if (reminder.description != null &&
                    reminder.description!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    reminder.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: HomeSystemTokens.inkMuted,
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      AppIcons.calendar_today,
                      size: 12.sp,
                      color: HomeSystemTokens.inkMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat('MMM d').format(reminder.remindAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: HomeSystemTokens.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      AppIcons.access_time,
                      size: 12.sp,
                      color: HomeSystemTokens.inkMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat('h:mm a').format(reminder.remindAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: HomeSystemTokens.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              AppIcons.more_vert,
              color: HomeSystemTokens.inkMuted,
              size: 20.sp,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HomeSystemTokens.radiusSm.r),
            ),
            onSelected: (value) {
              switch (value) {
                case 'snooze':
                  onSnooze?.call();
                  break;
                case 'dismiss':
                  onDismiss?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (reminder.isActive) ...[
                PopupMenuItem(
                  value: 'snooze',
                  child: Row(
                    children: [
                      Icon(AppIcons.snooze, color: HomeSystemTokens.orange, size: 20.sp),
                      SizedBox(width: 10.w),
                      const Text('Snooze 15 min'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'dismiss',
                  child: Row(
                    children: [
                      Icon(AppIcons.check_circle, color: HomeSystemTokens.green, size: 20.sp),
                      SizedBox(width: 10.w),
                      const Text('Mark Complete'),
                    ],
                  ),
                ),
              ],
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(AppIcons.delete_outline, color: HomeSystemTokens.coral, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Delete',
                      style: TextStyle(color: HomeSystemTokens.coral),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'one_time':
        return 'One Time';
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'one_time':
        return HomeSystemTokens.blue;
      case 'daily':
        return HomeSystemTokens.purple;
      case 'weekly':
        return HomeSystemTokens.green;
      default:
        return HomeSystemTokens.inkMuted;
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
