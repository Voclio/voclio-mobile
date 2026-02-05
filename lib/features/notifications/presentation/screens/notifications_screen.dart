import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(context, theme),
            
            // Notifications List
            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Loading notifications...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms);
                  }

                  if (state is NotificationsError || 
                      (state is NotificationsLoaded && state.notifications.isEmpty)) {
                    return _buildEmptyState(theme);
                  }

                  if (state is NotificationsLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<NotificationsCubit>().loadNotifications();
                      },
                      color: theme.primaryColor,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = state.notifications[index];
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Back button + Title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Bottom row: Subtitle + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  final cubit = context.read<NotificationsCubit>();
                  final unreadCount = cubit.unreadCount;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: unreadCount > 0 
                        ? theme.primaryColor.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          unreadCount > 0 ? Icons.mark_email_unread_rounded : Icons.check_circle_rounded,
                          size: 14.sp,
                          color: unreadCount > 0 ? theme.primaryColor : Colors.green,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          unreadCount > 0 
                            ? '$unreadCount unread'
                            : 'All caught up!',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: unreadCount > 0 ? theme.primaryColor : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  final cubit = context.read<NotificationsCubit>();
                  final unreadCount = cubit.unreadCount;
                  final hasNotifications =
                      state is NotificationsLoaded &&
                      state.notifications.isNotEmpty;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (unreadCount > 0)
                        _buildActionButton(
                          icon: Icons.done_all_rounded,
                          color: theme.primaryColor,
                          onTap: () => cubit.markAllAsRead(),
                        ),
                      if (hasNotifications) ...[                        
                        SizedBox(width: 8.w),
                        _buildActionButton(
                          icon: Icons.delete_sweep_rounded,
                          color: Colors.red.shade400,
                          onTap: () => _showDeleteConfirmation(context, cubit),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 20.sp, color: color),
      ),
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
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade400, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            const Text('Clear All'),
          ],
        ),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.deleteAllNotifications();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64.sp,
              color: theme.primaryColor.withOpacity(0.5),
            ),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2000.ms),
          SizedBox(height: 24.h),
          Text(
            'All Caught Up! 🎉',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No new notifications at the moment.\nWe\'ll let you know when something arrives!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
