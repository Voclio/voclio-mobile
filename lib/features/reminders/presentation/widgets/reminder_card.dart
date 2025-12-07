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
    final isUpcoming = reminder.reminderTime.isAfter(DateTime.now());
    final isPast = reminder.reminderTime.isBefore(DateTime.now());

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color:
          !reminder.isActive
              ? Colors.grey[200]
              : isPast
              ? Colors.red[50]
              : null,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color:
                !reminder.isActive
                    ? Colors.grey
                    : isPast
                    ? Colors.red
                    : Colors.blue,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        title: Text(
          DateFormat('MMM dd, yyyy - HH:mm').format(reminder.reminderTime),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: !reminder.isActive ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              reminder.reminderType == 'one_time' ? 'One Time' : 'Recurring',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            if (isPast && reminder.isActive)
              Text(
                'Overdue',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing:
            reminder.isActive
                ? PopupMenuButton<String>(
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
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'snooze',
                          child: Row(
                            children: [
                              Icon(Icons.snooze),
                              SizedBox(width: 8),
                              Text('Snooze'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'dismiss',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8),
                              Text('Dismiss'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                )
                : IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: onDelete,
                ),
      ),
    );
  }
}
