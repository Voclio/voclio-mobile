import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';

class HomeListTile extends StatelessWidget {
  const HomeListTile({super.key});

  /// Returns dynamic greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  void _showProfileMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(
      Offset(0, button.size.height),
      ancestor: overlay,
    );

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        20.w,
        position.dy + 10.h,
        overlay.size.width - 200.w,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 8,
      items: [
        _buildMenuItem(
          context,
          icon: Icons.person_outline,
          title: 'Profile',
          value: 'profile',
        ),
        _buildMenuItem(
          context,
          icon: Icons.dashboard_outlined,
          title: 'Dashboard',
          value: 'dashboard',
        ),
        _buildMenuItem(
          context,
          icon: Icons.calendar_month_outlined,
          title: 'Calendar',
          value: 'calendar',
        ),
        _buildMenuItem(
          context,
          icon: Icons.notifications_active_outlined,
          title: 'Reminders',
          value: 'reminders',
        ),
        _buildMenuItem(
          context,
          icon: Icons.timer_outlined,
          title: 'Focus Timer',
          value: 'focusTimer',
        ),
        _buildMenuItem(
          context,
          icon: Icons.emoji_events_outlined,
          title: 'Achievements',
          value: 'achievements',
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          value: 'settings',
        ),
        _buildMenuItem(
          context,
          icon: Icons.logout,
          title: 'Logout',
          value: 'logout',
          isDestructive: true,
        ),
      ],
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'profile':
          context.push(AppRouter.profile);
          break;
        case 'dashboard':
          context.push(AppRouter.dashboard);
          break;
        case 'calendar':
          context.push(AppRouter.calendar);
          break;
        case 'reminders':
          context.push(AppRouter.reminders);
          break;
        case 'focusTimer':
          context.push(AppRouter.focusTimer);
          break;
        case 'achievements':
          context.push(AppRouter.achievements);
          break;
        case 'settings':
          context.push(AppRouter.settings);
          break;
        case 'logout':
          _handleLogout(context);
          break;
      }
    });
  }

  PopupMenuItem<String> _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : context.colors.primary;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: color),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: isDestructive ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    VoclioDialog.showConfirm(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout from Voclio?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      onConfirm: () {
        Navigator.of(context).pop();
        context.read<AuthBloc>().add(const LogoutEvent());
        context.go(AppRouter.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.response.user : null;
        final userName = user?.name.isNotEmpty == true ? user!.name : 'User';
        final avatarUrl = user?.avatar;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                context.colors.primary!.withOpacity(0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary!.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile section with menu indicator
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showProfileMenu(context),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: context.colors.primary!.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar
                        Container(
                          width: 50.r,
                          height: 50.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                context.colors.primary!.withOpacity(0.1),
                                context.colors.primary!.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: context.colors.primary!.withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.primary!.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child:
                                avatarUrl != null && avatarUrl.isNotEmpty
                                    ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: context.colors.primary!.withOpacity(
                                            0.1,
                                          ),
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 26.sp,
                                            color: context.colors.primary,
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      color: context.colors.primary!.withOpacity(0.05),
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 26.sp,
                                        color: context.colors.primary,
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // Dropdown indicator
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: context.colors.primary!.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: context.colors.primary,
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getGreeting(),
                          style: context.textStyle.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '👋',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userName,
                      style: context.textStyle.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const NotificationBadge(),
            ],
          ),
        );
      },
    );
  }
}
