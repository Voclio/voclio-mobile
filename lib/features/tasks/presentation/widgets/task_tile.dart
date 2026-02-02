import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';

class AppColors {
  // --- Common ---
  static const Color primary = Color(0xFF9575CD); // Light Purple
  static const Color accent = Color(0xFF64B5F6); // Soft Blue

  // --- Dark Theme ---
  static const Color darkBackground = Color(0xFF1E1E2C);
  static const Color darkCard = Color(0xFF2D2D44);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white54;

  // --- Light Theme ---
  static const Color lightBackground = Color(0xFFF5F5F7); // Off-white gray
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1E1E2C); // Dark Navy for text
  static const Color lightTextSecondary = Color(0xFF8A8A8A); // Medium Grey
}

class TaskTile extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final Function(bool?) onCheckChanged;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Opacity for completed tasks
    final double opacity = task.isDone ? 0.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.lightBackground.withOpacity(opacity),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // 2. Checkbox (Custom Circle)
            InkWell(
              onTap: () => onCheckChanged(!task.isDone),
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isDone ? AppColors.primary : Colors.black26,
                    width: 2,
                  ),
                  color: task.isDone ? AppColors.primary : Colors.transparent,
                ),
                child:
                    task.isDone
                        ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                        : null,
              ),
            ),
            SizedBox(width: 12.w),

            // 1. Colored Strip (based on category or priority)
            Container(
              width: 3.w,
              height: 45.h,
              decoration: BoxDecoration(
                color: task.priority.color, // Uses the Enum extension we made
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            SizedBox(width: 16.w),

            // 3. Title and Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: AppColors.lightTextPrimary.withOpacity(opacity),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      decoration:
                          task.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                      decorationColor: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(task.date),
                        style: TextStyle(
                          color: AppColors.lightTextSecondary.withOpacity(
                            opacity,
                          ),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Tag Pill
            if (task.tags.isNotEmpty)
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      task.tags.first,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: task.priority.color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      task.priority.name, // Uses Enum extension
                      style: TextStyle(color: Colors.black, fontSize: 10.sp),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple logic for "Today", otherwise date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (checkDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${DateFormat.jm().format(date)}';
    }
    return DateFormat('MMM d, h:mm a').format(date);
  }
}
