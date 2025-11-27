import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../../../core/common/animation/animate_do.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';

class AuthLoadingWidget extends StatefulWidget {
  final String message;
  final double? size;

  const AuthLoadingWidget({
    super.key,
    this.message = 'Loading...',
    this.size,
  });

  @override
  State<AuthLoadingWidget> createState() => _AuthLoadingWidgetState();
}

class _AuthLoadingWidgetState extends State<AuthLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final effectiveSize = widget.size ?? (isSmall ? 20.w : 24.w);

    return CustomFadeInUp(
      duration: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: effectiveSize,
                height: effectiveSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.primary!.withOpacity(0.3 + (_animation.value * 0.4)),
                      colors.accent!.withOpacity(0.2 + (_animation.value * 0.3)),
                    ],
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: effectiveSize * 0.6,
                    height: effectiveSize * 0.6,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.primary!.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.message.isNotEmpty) ...[
            SizedBox(height: isSmall ? 8.h : 12.h),
            Text(
              widget.message,
              style: context.textStyle.copyWith(
                fontSize: isSmall ? 12.sp : 14.sp,
                fontWeight: FontWeightHelper.medium,
                color: colors.primary!.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class AuthShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AuthShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<AuthShimmerWidget> createState() => _AuthShimmerWidgetState();
}

class _AuthShimmerWidgetState extends State<AuthShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
              colors: [
                colors.background!.withOpacity(0.3),
                colors.primary!.withOpacity(0.1),
                colors.background!.withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}
