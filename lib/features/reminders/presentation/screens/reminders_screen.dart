import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/App_routes.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../cubit/reminders_cubit.dart';
import '../widgets/reminder_card.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _currentTab = _tabController.index);
      _loadReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReminders() {
    final cubit = context.read<RemindersCubit>();
    if (_currentTab == 0) {
      cubit.loadReminders();
    } else {
      cubit.loadUpcomingReminders();
    }
  }

  void _showSnoozeDialog(String reminderId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Snooze Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('5 minutes'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<RemindersCubit>().snoozeReminder(reminderId, 5);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('15 minutes'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<RemindersCubit>().snoozeReminder(reminderId, 15);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('30 minutes'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<RemindersCubit>().snoozeReminder(reminderId, 30);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('1 hour'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<RemindersCubit>().snoozeReminder(reminderId, 60);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String reminderId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RemindersCubit>().deleteReminder(reminderId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RemindersCubit>()..loadReminders(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: context.colors.background,
          appBar: AppBar(
            title: Text(
              'Reminders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, size: 28.sp),
                onPressed: () async {
                  await context.push(AppRouter.addReminder);
                  if (context.mounted) {
                    _loadReminders();
                  }
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: context.colors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: context.colors.primary,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Upcoming'),
              ],
            ),
          ),
          body: BlocBuilder<RemindersCubit, RemindersState>(
            builder: (context, state) {
              if (state is RemindersLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is RemindersError) {
                return _buildErrorState(context, state.message);
              }

              if (state is RemindersLoaded) {
                if (state.reminders.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadReminders(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = state.reminders[index];
                      return ReminderCard(
                        reminder: reminder,
                        onSnooze: () => _showSnoozeDialog(reminder.id),
                        onDismiss: () {
                          context.read<RemindersCubit>().dismissReminder(
                            reminder.id,
                          );
                        },
                        onDelete: () => _showDeleteConfirmation(reminder.id),
                      );
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton.extended(
              onPressed: () async {
                await context.push(AppRouter.addReminder);
                if (context.mounted) {
                  _loadReminders();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: context.colors.primary?.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 64.sp,
                color: context.colors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              _currentTab == 0 ? 'No Reminders Yet' : 'No Upcoming Reminders',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _currentTab == 0
                  ? 'Create your first reminder to stay on track with your tasks'
                  : 'All your reminders have been completed or dismissed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () async {
                await context.push(AppRouter.addReminder);
                if (context.mounted) {
                  _loadReminders();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _loadReminders(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
