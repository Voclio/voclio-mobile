import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/App_routes.dart';
import '../cubit/reminders_cubit.dart';
import '../widgets/reminder_card.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  int _currentTab = 0;
  int _allRemindersCount = 0;
  int _upcomingRemindersCount = 0;

  void _loadReminders() {
    final cubit = context.read<RemindersCubit>();
    if (_currentTab == 0) {
      cubit.loadReminders();
    } else {
      cubit.loadUpcomingReminders();
    }
  }

  Future<void> _openAddReminder() async {
    await context.push(AppRouter.addReminder);
    if (context.mounted) {
      _loadReminders();
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
            style: TextButton.styleFrom(foregroundColor: HomeSystemTokens.coral),
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
        builder: (context) => BlocListener<RemindersCubit, RemindersState>(
          listener: (context, state) {
            if (state is RemindersLoaded) {
              setState(() {
                if (_currentTab == 0) {
                  _allRemindersCount = state.reminders.length;
                } else {
                  _upcomingRemindersCount = state.reminders.length;
                }
              });
            }
          },
          child: HomeSecondaryScaffold(
          title: 'Reminders',
          subtitle: _currentTab == 0 ? 'All reminders' : 'Upcoming only',
          icon: Icons.alarm_rounded,
          accent: HomeSystemTokens.orange,
          showBack: Navigator.canPop(context),
          actions: [
            HomeIconButton(
              icon: Icons.add_rounded,
              onTap: _openAddReminder,
            ),
          ],
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddReminder,
            icon: const Icon(Icons.add),
            label: const Text('Add Reminder'),
            backgroundColor: HomeSystemTokens.orange,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: SizedBox(
                  height: 32.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      HomeCountedFilterPill(
                        label: 'All',
                        count: _allRemindersCount,
                        selected: _currentTab == 0,
                        onTap: () {
                          if (_currentTab == 0) return;
                          setState(() => _currentTab = 0);
                          _loadReminders();
                        },
                      ),
                      HomeCountedFilterPill(
                        label: 'Upcoming',
                        count: _upcomingRemindersCount,
                        selected: _currentTab == 1,
                        onTap: () {
                          if (_currentTab == 1) return;
                          setState(() => _currentTab = 1);
                          _loadReminders();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: BlocBuilder<RemindersCubit, RemindersState>(
                  builder: (context, state) {
                    if (state is RemindersLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: HomeSystemTokens.orange,
                        ),
                      );
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
                        color: HomeSystemTokens.orange,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
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
                              onDelete: () =>
                                  _showDeleteConfirmation(reminder.id),
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return HomeEmptyState(
      icon: Icons.notifications_off_outlined,
      title: _currentTab == 0
          ? 'No Reminders Yet'
          : 'No Upcoming Reminders',
      message: _currentTab == 0
          ? 'Create your first reminder to stay on track with your tasks'
          : 'All your reminders have been completed or dismissed',
      actionLabel: 'Create Reminder',
      onAction: _openAddReminder,
      accent: HomeSystemTokens.orange,
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return HomeEmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Oops! Something went wrong',
      message: message,
      actionLabel: 'Try Again',
      onAction: _loadReminders,
      accent: HomeSystemTokens.coral,
    );
  }
}
