import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/bloc/tasks_cubit.dart';
import '../../../tasks/presentation/bloc/tasks_state.dart';
import '../../domain/entities/reminder_entity.dart';
import '../cubit/reminders_cubit.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _reminderType = 'one_time';
  bool _isLoading = false;
  List<TaskEntity> _tasks = [];
  TaskEntity? _selectedTask;
  bool _isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(hours: 1));
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasksCubit = getIt<TasksCubit>();
      await tasksCubit.getTasks();
      final state = tasksCubit.state;
      if (state.status == TasksStatus.success) {
        setState(() {
          _tasks = state.tasks;
          _isLoadingTasks = false;
        });
      } else {
        setState(() => _isLoadingTasks = false);
      }
    } catch (e) {
      setState(() => _isLoadingTasks = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary ?? Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary ?? Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedTask == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a task for this reminder'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final reminder = ReminderEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      remindAt: _selectedDate,
      taskId: int.tryParse(_selectedTask!.id),
      reminderType: _reminderType,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await context.read<RemindersCubit>().createReminder(reminder);
    
    if (mounted) {
      final state = context.read<RemindersCubit>().state;
      if (state is RemindersError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create reminder: ${state.message}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reminder created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        context.pop(true); // Return true to indicate success
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          'Add Reminder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            // Header illustration
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: context.colors.primary?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 48.sp,
                    color: context.colors.primary,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Set a Reminder',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Never miss an important moment',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Title field
            Text(
              'Title',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter reminder title',
                prefixIcon: Icon(Icons.title, color: context.colors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: context.colors.primary ?? Colors.blue,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),

            // Description field (optional)
            Text(
              'Description (Optional)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a description...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48.h),
                  child: Icon(Icons.description, color: context.colors.primary),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: context.colors.primary ?? Colors.blue,
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Task picker (Required)
            Text(
              'Task *',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            _isLoadingTasks
                ? Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.primary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Loading tasks...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _tasks.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange[300]!),
                          borderRadius: BorderRadius.circular(12.r),
                          color: Colors.orange[50],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange[700]),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'No tasks found. Create a task first.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<TaskEntity>(
                        value: _selectedTask,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.task_alt, color: context.colors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: context.colors.primary ?? Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        hint: const Text('Select a task'),
                        isExpanded: true,
                        items: _tasks.map((task) {
                          return DropdownMenuItem<TaskEntity>(
                            value: task,
                            child: Text(
                              task.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (task) {
                          setState(() => _selectedTask = task);
                        },
                      ),
            SizedBox(height: 20.h),

            // Date picker
            Text(
              'Date',
              style: TextStyle(
                fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: context.colors.primary,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Time picker
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: context.colors.primary,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Reminder type
                  Text(
                    'Repeat',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        _buildReminderTypeOption(
                          'one_time',
                          'One Time',
                          Icons.looks_one,
                          'Remind me just once',
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _buildReminderTypeOption(
                          'daily',
                          'Daily',
                          Icons.repeat,
                          'Remind me every day',
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _buildReminderTypeOption(
                          'weekly',
                          'Weekly',
                          Icons.calendar_view_week,
                          'Remind me every week',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Preview
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'You will be reminded on ${DateFormat('MMM d, yyyy').format(_selectedDate)} at ${_selectedTime.format(context)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check),
                                SizedBox(width: 8.w),
                                Text(
                                  'Create Reminder',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
    );
  }

  Widget _buildReminderTypeOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _reminderType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _reminderType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary?.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? context.colors.primary : Colors.grey[600],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? context.colors.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.colors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
