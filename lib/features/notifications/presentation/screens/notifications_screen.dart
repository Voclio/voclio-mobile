import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final cubit = context.read<NotificationsCubit>();
              final unreadCount = cubit.unreadCount;
              final state = cubit.state;
              final hasNotifications =
                  state is NotificationsLoaded &&
                  state.notifications.isNotEmpty;

              return Row(
                children: [
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: () => cubit.markAllAsRead(),
                      child: const Text('Mark all read'),
                    ),
                  if (hasNotifications)
                    TextButton(
                      onPressed: () => cubit.deleteAllNotifications(),
                      child: const Text(
                        'Delete all',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError) {
            // If we just deleted everything, show "No notification found" instead of an error message
            // Or if the error message is about empty results
            return const Center(child: Text('No notification found'));
          }

          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text('No notification found'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<NotificationsCubit>().loadNotifications();
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context.read<NotificationsCubit>().markAsRead(
                          notification.id,
                        );
                      }
                    },
                    onDelete: () {
                      context.read<NotificationsCubit>().deleteNotification(
                        notification.id,
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
