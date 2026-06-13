import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';

import '../cubit/notifications_cubit.dart';
import '../utils/notification_action_handler.dart';
import '../widgets/notification_card.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

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
    VoclioDialog.showConfirm(
      context: context,
      title: 'Clear All',
      message:
          'Are you sure you want to delete all notifications? This action cannot be undone.',
      confirmText: 'Delete All',
      cancelText: 'Cancel',
      onConfirm: () => cubit.deleteAllNotifications(),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  final NotificationsState state;

  const _NotificationsBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final currentState = state;

    if (currentState is NotificationsInitial ||
        currentState is NotificationsLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 36.w,
              height: 36.h,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: HomeSystemTokens.blue,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Loading notifications...',
              style: TextStyle(
                color: HomeSystemTokens.inkMuted,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (currentState is NotificationsError) {
      return HomeEmptyState(
        icon: AppIcons.error_outline_rounded,
        title: 'Could not load notifications',
        message: currentState.message,
        actionLabel: 'Try again',
        accent: HomeSystemTokens.coral,
        onAction: () =>
            context.read<NotificationsCubit>().loadNotifications(),
      );
    }

    if (currentState is NotificationsLoaded &&
        currentState.notifications.isEmpty) {
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
          await context
              .read<NotificationsCubit>()
              .loadNotifications(force: true);
        },
        color: HomeSystemTokens.blue,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationCard(
              notification: notification,
              index: index,
              onTap: () => NotificationActionHandler.handleTap(
                context,
                notification,
              ),
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
