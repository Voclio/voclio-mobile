import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/core/domain/entities/tag_entity.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/features/tasks/domain/entities/task_entity.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

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
    final isOverdue = !task.isDone && task.date.isBefore(DateTime.now());
    final accent = isOverdue
        ? HomeSystemTokens.coral
        : task.isDone
            ? HomeSystemTokens.green
            : task.priority.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: task.isDone ? 0.62 : 1,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: HomeSystemTokens.cardDecoration(
            tint: task.isDone
                ? HomeSystemTokens.green.withValues(alpha: 0.04)
                : HomeSystemTokens.card,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onCheckChanged(!task.isDone),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isDone
                          ? HomeSystemTokens.green
                          : accent.withValues(alpha: 0.45),
                      width: 2,
                    ),
                    color: task.isDone ? HomeSystemTokens.green : Colors.transparent,
                  ),
                  child: task.isDone
                      ? Icon(AppIcons.check_rounded, size: 15.sp, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 3.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title.isEmpty ? 'Untitled task' : task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: HomeSystemTokens.ink,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: HomeSystemTokens.inkMuted,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(
                          isOverdue
                              ? AppIcons.schedule_rounded
                              : AppIcons.access_time_rounded,
                          size: 13.sp,
                          color: isOverdue
                              ? HomeSystemTokens.coral
                              : HomeSystemTokens.inkMuted,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatDate(task.date),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isOverdue
                                ? HomeSystemTokens.coral
                                : HomeSystemTokens.inkMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (task.subtasks.isNotEmpty) ...[
                          SizedBox(width: 10.w),
                          Icon(
                            AppIcons.checklist_rounded,
                            size: 13.sp,
                            color: HomeSystemTokens.inkMuted,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '${task.completedSubtasks}/${task.totalSubtasks}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: HomeSystemTokens.inkMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (task.tags.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        children: task.tags.take(2).map((tagName) {
                          final tagColor = _getTagColor(tagName);
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              tagName,
                              style: TextStyle(
                                color: tagColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                AppIcons.chevron_right_rounded,
                color: HomeSystemTokens.inkMuted.withValues(alpha: 0.6),
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTagColor(String tagName) {
    try {
      final tag = availableTags.firstWhere((t) => t.name == tagName);
      final hex = tag.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return HomeSystemTokens.purple;
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
