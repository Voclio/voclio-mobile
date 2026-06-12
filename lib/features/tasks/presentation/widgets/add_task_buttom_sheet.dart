import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/core/enums/enums.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/tasks_cubit.dart';
import '../bloc/tasks_state.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final TaskEntity? taskToEdit;

  const AddTaskBottomSheet({super.key, this.taskToEdit});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedTagName;
  bool _isLoading = false;

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    if (task == null) return;

    _titleController.text = task.title;
    _descController.text = task.description ?? '';
    _selectedDate = task.date;
    _selectedPriority = task.priority;
    _selectedTagName = task.tags.isNotEmpty ? task.tags.first : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    if (_isLoading) return;

    final state = context.read<TasksCubit>().state;
    final effectiveTag =
        _selectedTagName ??
        (state.availableTags.isNotEmpty
            ? state.availableTags.first.name
            : null);

    setState(() => _isLoading = true);

    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final cubit = context.read<TasksCubit>();
    if (_isEditing) {
      final existing = widget.taskToEdit!;
      await cubit.updateTask(
        existing.copyWith(
          title: title,
          description: _descController.text.trim(),
          date: _selectedDate,
          priority: _selectedPriority,
          tags: effectiveTag != null ? [effectiveTag] : existing.tags,
        ),
      );
    } else {
      final uniqueId =
          '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
      final newTask = TaskEntity(
        id: uniqueId,
        title: title,
        description: _descController.text.trim(),
        date: _selectedDate,
        createdAt: DateTime.now(),
        isDone: false,
        priority: _selectedPriority,
        tags: effectiveTag != null ? [effectiveTag] : [],
        subtasks: const [],
      );
      cubit.addTask(newTask);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDateTime() async {
    // Hide keyboard if open when picking date to avoid layout jumps
    FocusManager.instance.primaryFocus?.unfocus();

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          physics:
              bottomInset > 0
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isEditing ? "Edit Task" : "New Task",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        AppIcons.close,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Title
                  Text(
                    "Title",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _titleController,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 18.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter task title",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Date
                  Text(
                    "Due Date",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _pickDateTime,
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.calendar_today,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            DateFormat(
                              'MMMM d, yyyy - h:mm a',
                            ).format(_selectedDate),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Priority
                  Text(
                    "Priority",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          TaskPriority.values.map((priority) {
                            final isSelected = _selectedPriority == priority;
                            return GestureDetector(
                              onTap:
                                  () => setState(
                                    () => _selectedPriority = priority,
                                  ),
                              child: Container(
                                margin: EdgeInsets.only(right: 12.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? priority.color
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? priority.color
                                            : theme.colorScheme.secondary
                                                .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  priority.displayName,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Category (using dynamic tags)
                  Text(
                    "Tags",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  BlocBuilder<TasksCubit, TasksState>(
                    builder: (context, state) {
                      final effectiveSelection =
                          _selectedTagName ??
                          (state.availableTags.isNotEmpty
                              ? state.availableTags.first.name
                              : null);

                      return Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children:
                            state.availableTags.map((tagEntity) {
                              final isSelected =
                                  effectiveSelection == tagEntity.name;
                              final tagColor = _parseColor(
                                tagEntity.color,
                                context,
                              );

                              return GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _selectedTagName = tagEntity.name,
                                    ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? tagColor
                                            : tagColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? tagColor
                                              : theme.colorScheme.secondary
                                                  .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    tagEntity.name,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Description
                  Text(
                    "Description",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: "Add details...",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h + bottomSafe),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              _isEditing ? "Save Changes" : "Create Task",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor, BuildContext context) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
