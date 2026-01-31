import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/app_cubit.dart';
import '../../../../core/common/inputs/text_app.dart';
import '../../../../core/styles/fonts/font_weight_helper.dart';

class AuthTopControls extends StatelessWidget {
  const AuthTopControls({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.isDarkMode,
      builder: (context, isDarkMode, child) {
        return BlocBuilder<AppCubit, AppState>(
          buildWhen: (previous, current) => previous.locale != current.locale,
          builder: (context, appState) {
            return _buildTopControls(context, appState);
          },
        );
      },
    );
  }

  Widget _buildTopControls(BuildContext context, AppState appState) {
    final colors = context.colors;
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 20.w,),
          SizedBox(
            width: isSmall ? 70.w :70.w,
            height: isSmall ? 70.h : 70.h,
            child: Image.asset(
              'assets/images/12.png',
              fit: BoxFit.contain,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),


        ],
      ),
    );
  }
}

/// 🎬 Widget مخصص بيعمل أنيميشن ناعم في الاتجاه المطلوب
enum AnimationDirection { left, right }

class _AnimatedButtonWrapper extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final AnimationDirection direction;

  const _AnimatedButtonWrapper({
    required this.child,
    required this.isActive,
    required this.duration,
    required this.direction,
  });

  @override
  State<_AnimatedButtonWrapper> createState() => _AnimatedButtonWrapperState();
}

class _AnimatedButtonWrapperState extends State<_AnimatedButtonWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    final beginOffset =
        widget.direction == AnimationDirection.right
            ? const Offset(0.3, 0)
            : const Offset(-0.3, 0);

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotateAnimation = Tween<double>(
      begin: widget.direction == AnimationDirection.right ? 0.05 : -0.05,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _AnimatedButtonWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: RotationTransition(turns: _rotateAnimation, child: widget.child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
