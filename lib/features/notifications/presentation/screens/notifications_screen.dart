import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificationsCubit>()..loadNotifications(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                final unreadCount =
                    context.read<NotificationsCubit>().unreadCount;
                if (unreadCount > 0) {
                  return TextButton(
                    onPressed: () {
                      // Mark all as read functionality would go here
                    },
                    child: const Text('Mark all read'),
                  );
                }
                return const SizedBox();
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
              return Center(child: Text(state.message));
            }

            if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(child: Text('No notifications'));
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
                        // Delete functionality if needed
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
