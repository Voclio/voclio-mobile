import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class HomeListTile extends StatelessWidget {
  const HomeListTile({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  void _showProfileMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height + 8.h,
        overlay.size.width - position.dx - renderBox.size.width,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 8,
      items: [
        _buildMenuItem(context, icon: AppIcons.person_outline, title: 'Profile', value: 'profile'),
        _buildMenuItem(context, icon: AppIcons.dashboard_outlined, title: 'Dashboard', value: 'dashboard'),
        _buildMenuItem(context, icon: AppIcons.calendar_month_outlined, title: 'Calendar', value: 'calendar'),
        _buildMenuItem(context, icon: AppIcons.notifications_active_outlined, title: 'Reminders', value: 'reminders'),
        _buildMenuItem(context, icon: AppIcons.timer_outlined, title: 'Focus Timer', value: 'focusTimer'),
        _buildMenuItem(context, icon: AppIcons.emoji_events_outlined, title: 'Achievements', value: 'achievements'),
        const PopupMenuDivider(),
        _buildMenuItem(context, icon: AppIcons.settings_outlined, title: 'Settings', value: 'settings'),
        _buildMenuItem(context, icon: AppIcons.logout, title: 'Logout', value: 'logout', isDestructive: true),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'profile':
          context.push(AppRouter.profile);
        case 'dashboard':
          context.push(AppRouter.dashboard);
        case 'calendar':
          context.push(AppRouter.calendar);
        case 'reminders':
          context.push(AppRouter.reminders);
        case 'focusTimer':
          context.push(AppRouter.focusTimer);
        case 'achievements':
          context.push(AppRouter.achievements);
        case 'settings':
          context.push(AppRouter.settings);
        case 'logout':
          _handleLogout(context);
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

  Widget _buildAvatar(String? avatarUrl) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF9B8AFB), Color(0xFF7C5CFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: HomeSystemTokens.purple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  AppIcons.person_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              )
            : Icon(AppIcons.person_rounded, color: Colors.white, size: 20.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.response.user : null;
        final userName =
            user?.name.isNotEmpty == true ? user!.name.split(' ').first : 'User';
        final avatarUrl = user?.avatar;

        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Builder(
                  builder: (profileContext) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showProfileMenu(profileContext),
                        borderRadius: BorderRadius.circular(14.r),
                        splashColor: HomeSystemTokens.purple.withOpacity(0.08),
                        highlightColor: HomeSystemTokens.purple.withOpacity(0.04),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 6.h,
                            horizontal: 4.w,
                          ),
                          child: Row(
                            children: [
                              _buildAvatar(avatarUrl),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_getGreeting()} 👋',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            userName,
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF111827),
                                              letterSpacing: -0.3,
                                              height: 1.1,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Container(
                                          padding: EdgeInsets.all(2.w),
                                          decoration: BoxDecoration(
                                            color: HomeSystemTokens.purple.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Icon(
                                            AppIcons.keyboard_arrow_down_rounded,
                                            size: 18.sp,
                                            color: HomeSystemTokens.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      "You're making great progress today.",
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: const Color(0xFFB0B7C3),
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 8.w),
              const NotificationBadge(),
            ],
          ),
        );
      },
    );
  }
}
