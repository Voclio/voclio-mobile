import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voclio_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:voclio_app/features/auth/presentation/widgets/auth_loading_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetProfileEvent());
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<AuthBloc>().add(const LogoutEvent());
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AuthBloc>().add(const GetProfileEvent());
            },
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) =>
                      const AuthLoadingDialog(message: 'Processing...'),
            );
          } else if (state is AuthInitial) {
            // Dismiss any dialogs and navigate to login
            Navigator.of(context).popUntil((route) => route.isFirst);

            // Show logout success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged out successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to login
            Future.delayed(const Duration(milliseconds: 500), () {
              context.goRoute(AppRouter.login);
            });
          } else if (state is AuthError) {
            // Dismiss loading dialog
            Navigator.of(context).pop();

            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthSuccess) {
            // Dismiss loading dialog if showing
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: AuthLoadingWidget());
          }

          if (state is AuthSuccess) {
            final user = state.response.user;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AuthBloc>().add(const GetProfileEvent());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: context.colors.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 48.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // User Name
                    Text(
                      user.name,
                      style: context.textStyle.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 8.h),

                    // User ID Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.primary?.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'ID: ${user.id}',
                        style: context.textStyle.copyWith(
                          fontSize: 12.sp,
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Profile Information Card
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            context,
                            Icons.email_outlined,
                            'Email',
                            user.email,
                          ),

                          if (user.phoneNumber != null &&
                              user.phoneNumber!.isNotEmpty)
                            _buildProfileItem(
                              context,
                              Icons.phone_outlined,
                              'Phone',
                              user.phoneNumber!,
                            ),

                          _buildProfileItem(
                            context,
                            Icons.calendar_today_outlined,
                            'Member Since',
                            _formatDate(user.createdAt),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Action Buttons
                    AuthButton(
                      text: 'Edit Profile',
                      onPressed: () {
                        context.pushRoute(AppRouter.editProfile, extra: user);
                      },
                    ),

                    SizedBox(height: 12.h),

                    OutlinedButton(
                      onPressed: () {
                        context.pushRoute(AppRouter.changePassword);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50.h),
                        side: BorderSide(
                          color: context.colors.primary ?? Colors.blue,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Logout Button
                    TextButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            );
          }

          if (state is AuthError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load profile',
                    style: context.textStyle.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: context.textStyle.copyWith(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(const GetProfileEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: context.colors.primary),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textStyle.copyWith(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: context.textStyle.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
