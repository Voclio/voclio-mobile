import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
    final isUpcoming = reminder.remindAt.isAfter(DateTime.now());
    final isPast = reminder.remindAt.isBefore(DateTime.now());
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: !reminder.isActive
              ? Colors.grey[300]!
              : isPast
                  ? Colors.red[200]!
                  : primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: !reminder.isActive
                          ? [Colors.grey[400]!, Colors.grey[500]!]
                          : isPast
                              ? [Colors.red[300]!, Colors.red[400]!]
                              : [primaryColor.withOpacity(0.8), primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: (!reminder.isActive
                                ? Colors.grey
                                : isPast
                                    ? Colors.red
                                    : primaryColor)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPast ? Icons.notification_important : Icons.notifications_active,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(reminder.reminderType)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              _getTypeLabel(reminder.reminderType),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(reminder.reminderType),
                              ),
                            ),
                          ),
                          if (isPast && reminder.isActive) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'Overdue',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        reminder.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: !reminder.isActive ? Colors.grey : Colors.black87,
                          decoration: !reminder.isActive
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          reminder.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            DateFormat('MMM d').format(reminder.remindAt),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            DateFormat('h:mm a').format(reminder.remindAt),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
                            Icon(Icons.snooze, color: Colors.orange[700]),
                            SizedBox(width: 12.w),
                            const Text('Snooze 15 min'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'dismiss',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            SizedBox(width: 12.w),
                            const Text('Mark Complete'),
                          ],
                        ),
                      ),
                    ],
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 12.w),
                          const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
        return Colors.blue;
      case 'daily':
        return Colors.purple;
      case 'weekly':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
