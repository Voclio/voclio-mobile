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
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Only fetch profile if we don't already have data
    Future.microtask(() {
      final currentState = context.read<AuthBloc>().state;
      if (currentState is! AuthSuccess) {
        context.read<AuthBloc>().add(const GetProfileEvent());
      }
    });
  }

  void _handleLogout() {
    VoclioDialog.showConfirm(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout from Voclio?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      onConfirm: () {
        Navigator.of(context).pop();
        context.read<AuthBloc>().add(const LogoutEvent());
        context.goRoute(AppRouter.login);
      },
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
          final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
          if (!isCurrentRoute) return;

          if (state is AuthError) {
            // Only show error snackbar, don't redirect to login
            // The auth interceptor handles token refresh automatically
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileUpdateError) {
            // Show error but don't navigate away - profile data is preserved
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          // Don't do anything for AuthSuccess - just let the builder handle it
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: AuthLoadingWidget());
          }

          // Handle ProfileUpdateError - show profile with preserved user data
          if (state is ProfileUpdateError) {
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

                    // Show error banner
                    Container(
                      padding: EdgeInsets.all(12.w),
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              state.message,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Continue showing profile items...
                    _buildProfileItem(
                      context,
                      Icons.email,
                      'Email',
                      user.email,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const GetProfileEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
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
            // Check if it's a token error - show appropriate UI
            final message = state.message.toLowerCase();
            final isTokenError =
                message.contains('token') ||
                message.contains('unauthorized') ||
                message.contains('expired') ||
                message.contains('login again') ||
                message.contains('session') ||
                message.contains('401');

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTokenError ? Icons.lock_outline : Icons.error_outline,
                    size: 64.sp,
                    color: isTokenError ? Colors.orange : Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    isTokenError ? 'Session Expired' : 'Failed to load profile',
                    style: context.textStyle.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isTokenError
                        ? 'Please login again to continue'
                        : state.message,
                    style: context.textStyle.copyWith(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (isTokenError) {
                        context.goRoute(AppRouter.login);
                      } else {
                        context.read<AuthBloc>().add(const GetProfileEvent());
                      }
                    },
                    icon: Icon(isTokenError ? Icons.login : Icons.refresh),
                    label: Text(isTokenError ? 'Go to Login' : 'Retry'),
                  ),
                ],
              ),
            );
          }

          // Handle PasswordChangedSuccess and ProfileUpdateError by re-fetching profile
          if (state is PasswordChangedSuccess || state is ProfileUpdateError) {
            // Trigger a profile fetch to get proper state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<AuthBloc>().add(const GetProfileEvent());
              }
            });
            return const Center(child: AuthLoadingWidget());
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
