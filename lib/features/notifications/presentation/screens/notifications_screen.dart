import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';

import '../cubit/notifications_cubit.dart';
import '../widgets/notification_card.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();
        final unreadCount = cubit.unreadCount;
        final hasNotifications =
            state is NotificationsLoaded && state.notifications.isNotEmpty;

        final actions = <Widget>[
          if (unreadCount > 0)
            HomeIconButton(
              icon: AppIcons.done_all_rounded,
              color: HomeSystemTokens.purple,
              onTap: () => cubit.markAllAsRead(),
            ),
          if (hasNotifications) ...[
            SizedBox(width: 8.w),
            HomeIconButton(
              icon: AppIcons.delete_sweep_rounded,
              color: HomeSystemTokens.coral,
              onTap: () => _showDeleteConfirmation(context, cubit),
            ),
          ],
        ];

        return HomeSecondaryScaffold(
          title: 'Notifications',
          subtitle: unreadCount > 0
              ? '$unreadCount unread'
              : 'All caught up!',
          icon: AppIcons.notifications_rounded,
          accent: HomeSystemTokens.blue,
          actions: actions,
          body: _NotificationsBody(state: state),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, NotificationsCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: HomeSystemTokens.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                AppIcons.delete_forever_rounded,
                color: HomeSystemTokens.coral,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            const Text('Clear All'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: HomeSystemTokens.inkSoft),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.deleteAllNotifications();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeSystemTokens.coral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  final NotificationsState state;

  const _NotificationsBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final currentState = state;

    if (currentState is NotificationsLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48.w,
              height: 48.h,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: HomeSystemTokens.blue,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading notifications...',
              style: TextStyle(
                color: HomeSystemTokens.inkMuted,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (currentState is NotificationsError ||
        (currentState is NotificationsLoaded &&
            currentState.notifications.isEmpty)) {
      return HomeEmptyState(
        icon: AppIcons.notifications_off_outlined,
        title: 'All Caught Up!',
        message:
            'No new notifications at the moment.\nWe\'ll let you know when something arrives!',
        accent: HomeSystemTokens.blue,
      );
    }

    if (currentState is NotificationsLoaded) {
      final notifications = currentState.notifications;
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<NotificationsCubit>().loadNotifications();
        },
        color: HomeSystemTokens.blue,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationCard(
              notification: notification,
              index: index,
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
  }
}
