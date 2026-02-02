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
    // Opacity for completed tasks
    final double opacity = task.isDone ? 0.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Checkbox (Custom Circle)
            InkWell(
              onTap: () => onCheckChanged(!task.isDone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        task.isDone
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary.withOpacity(0.3),
                    width: 2,
                  ),
                  color:
                      task.isDone
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                ),
                child:
                    task.isDone
                        ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                        : null,
              ),
            ),
            SizedBox(width: 12.w),

            // 2. Colored Strip (Priority)
            Container(
              width: 3.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: task.priority.color.withOpacity(opacity),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            SizedBox(width: 16.w),

            // 3. Title, Time, and Tags
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title.isEmpty ? "[No Title]" : task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(opacity),
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14.sp,
                              color: theme.colorScheme.secondary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatDate(task.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary.withOpacity(
                                  opacity,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (task.tags.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Wrap(
                          spacing: 4.w,
                          children:
                              task.tags.take(2).map((tagName) {
                                final tagColor = _getTagColor(tagName, theme);
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tagColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    tagName,
                                    style: TextStyle(
                                      color: tagColor,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
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
