import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'auth_loading_widget.dart';

class AuthLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;

  const AuthLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24.w),
                margin: EdgeInsets.symmetric(horizontal: 32.w),
                decoration: BoxDecoration(
                  color: context.colors.background!,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AuthLoadingWidget(
                  message: loadingMessage ?? 'Processing...',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AuthRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;

  const AuthRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? context.colors.primary,
      backgroundColor: context.colors.background,
      strokeWidth: 2.5,
      child: child,
    );
  }
}
