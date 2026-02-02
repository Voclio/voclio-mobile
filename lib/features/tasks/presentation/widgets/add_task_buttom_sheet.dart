import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/core/enums/enums.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/tasks_cubit.dart';
import '../bloc/tasks_state.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});

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

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _createTask() async {
    if (_titleController.text.trim().isEmpty) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // 1. Unfocus the keyboard immediately
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final uniqueId =
        '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
    final newTask = TaskEntity(
      id: uniqueId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      date: _selectedDate,
      createdAt: DateTime.now(),
      isDone: false,
      priority: _selectedPriority,
      tags: _selectedTagName != null ? [_selectedTagName!] : [],
      subtasks: const [],
    );

    // 2. Capture the Cubit reference before any async gaps
    // final cubit = context.read<TasksCubit>();

    // // 3. SAFER POP LOGIC:
    // // We wait for the "unfocus" layout rebuilding to finish before popping.
    // // This prevents the 'Scaffold.geometryOf' crash by ensuring the
    // // parent Scaffold is stable before the exit animation starts.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     cubit.addTask(newTask);
    //     Navigator.pop(context);
    //   }
    // });
    context.read<TasksCubit>().addTask(newTask);
    Navigator.pop(context);
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

    // We calculate the bottom inset manually to pad the content
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Constrain height to 85% of screen or less if keyboard is open
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // --- HEADER ---
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Task",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),

          // --- SCROLLABLE FORM ---
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                20.r,
                20.r,
                20.r,
                20.r + bottomInset,
              ),
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
                            Icons.calendar_today,
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
                      // Set default tag if none selected and tags are available
                      if (_selectedTagName == null &&
                          state.availableTags.isNotEmpty) {
                        _selectedTagName = state.availableTags.first.name;
                      }

                      return Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children:
                            state.availableTags.map((tagEntity) {
                              final isSelected =
                                  _selectedTagName == tagEntity.name;
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
                    maxLines: 4,
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

                  // CREATE BUTTON (Inside ScrollView to move with keyboard)
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createTask,
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
                                "Create Task",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
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
