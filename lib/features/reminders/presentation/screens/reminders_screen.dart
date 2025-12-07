import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/reminders_cubit.dart';
import '../widgets/reminder_card.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RemindersCubit>()..loadReminders(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reminders'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navigate to create reminder screen
              },
            ),
          ],
        ),
        body: BlocBuilder<RemindersCubit, RemindersState>(
          builder: (context, state) {
            if (state is RemindersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RemindersError) {
              return Center(child: Text(state.message));
            }

            if (state is RemindersLoaded) {
              if (state.reminders.isEmpty) {
                return const Center(child: Text('No reminders yet'));
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.reminders.length,
                itemBuilder: (context, index) {
                  final reminder = state.reminders[index];
                  return ReminderCard(
                    reminder: reminder,
                    onSnooze: () {
                      context.read<RemindersCubit>().snoozeReminder(
                        reminder.id,
                        15,
                      );
                    },
                    onDismiss: () {
                      context.read<RemindersCubit>().deleteReminder(
                        reminder.id,
                      );
                    },
                    onDelete: () {
                      context.read<RemindersCubit>().deleteReminder(
                        reminder.id,
                      );
                    },
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
