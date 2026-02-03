import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/core/domain/entities/tag_entity.dart';

class TaskTile extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final Function(bool?) onCheckChanged;
  final List<TagEntity> availableTags;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onCheckChanged,
    this.availableTags = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Opacity for completed tasks
    final double opacity = task.isDone ? 0.5 : 1.0;
    final bool isOverdue = !task.isDone && task.date.isBefore(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: task.isDone 
              ? (isDark ? Colors.green.withOpacity(0.1) : Colors.green.withOpacity(0.05))
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: task.isDone 
                ? Colors.green.withOpacity(0.3)
                : isOverdue 
                    ? Colors.red.withOpacity(0.3)
                    : theme.colorScheme.onSurface.withOpacity(0.05),
            width: task.isDone || isOverdue ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: task.isDone 
                  ? Colors.green.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Checkbox (Custom Circle with animation)
            GestureDetector(
              onTap: () => onCheckChanged(!task.isDone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isDone
                        ? Colors.green
                        : isOverdue
                            ? Colors.red.withOpacity(0.5)
                            : theme.colorScheme.primary.withOpacity(0.4),
                    width: 2,
                  ),
                  color: task.isDone ? Colors.green : Colors.transparent,
                  boxShadow: task.isDone
                      ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: task.isDone
                    ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 14.w),

            // 2. Colored Strip (Priority) with gradient
            Container(
              width: 4.w,
              height: 44.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    task.priority.color.withOpacity(opacity),
                    task.priority.color.withOpacity(opacity * 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            SizedBox(width: 14.w),

            // 3. Title, Time, Tags, and Subtask Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title.isEmpty ? "[No Title]" : task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(opacity),
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.green,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      // Time
                      Icon(
                        isOverdue ? Icons.warning_amber_rounded : Icons.access_time_rounded,
                        size: 14.sp,
                        color: isOverdue ? Colors.red : theme.colorScheme.secondary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(task.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue 
                              ? Colors.red.withOpacity(0.8)
                              : theme.colorScheme.secondary.withOpacity(opacity),
                          fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      
                      // Subtasks indicator
                      if (task.subtasks.isNotEmpty) ...[
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.checklist_rounded,
                          size: 14.sp,
                          color: theme.colorScheme.secondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${task.completedSubtasks}/${task.totalSubtasks}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary.withOpacity(opacity),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Tags row
                  if (task.tags.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: task.tags.take(2).map((tagName) {
                        final tagColor = _getTagColor(tagName, theme);
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            tagName,
                            style: TextStyle(
                              color: tagColor.withOpacity(0.9),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow indicator
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.secondary.withOpacity(0.4),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTagColor(String tagName, ThemeData theme) {
    try {
      final tag = availableTags.firstWhere((t) => t.name == tagName);
      final hex = tag.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return theme.colorScheme.primary;
    }
  }

  String _formatDate(DateTime date) {
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
