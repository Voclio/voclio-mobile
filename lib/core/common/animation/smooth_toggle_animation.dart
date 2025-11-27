import 'package:flutter/material.dart';

/// أنيميشن مخصص للأيقونات مع حركة دوران سلسة وتأثيرات انتقالية جميلة
class SmoothToggleAnimation extends StatefulWidget {
  const SmoothToggleAnimation({
    super.key,
    required this.child,
    required this.isActive,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.rotationAngle = 0.5,
    this.scaleEffect = true,
    this.colorTransition = true,
  });

  final Widget child;
  final bool isActive;
  final Duration duration;
  final Curve curve;
  final double rotationAngle;
  final bool scaleEffect;
  final bool colorTransition;

  @override
  State<SmoothToggleAnimation> createState() => _SmoothToggleAnimationState();
}

class _SmoothToggleAnimationState extends State<SmoothToggleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.rotationAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SmoothToggleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Transform.scale(
            scale: widget.scaleEffect ? _scaleAnimation.value : 1.0,
            child: Opacity(
              opacity: _opacityAnimation.value.clamp(0.0, 1.0),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// أنيميشن مخصص للنص مع تأثيرات انتقالية جميلة
class SmoothTextTransition extends StatefulWidget {
  const SmoothTextTransition({
    super.key,
    required this.text,
    required this.isActive,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    this.slideEffect = true,
    this.textColor,
  });

  final String text;
  final bool isActive;
  final Duration duration;
  final Curve curve;
  final bool slideEffect;
  final Color? textColor;

  @override
  State<SmoothTextTransition> createState() => _SmoothTextTransitionState();
}

class _SmoothTextTransitionState extends State<SmoothTextTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // النص مرئي دائماً مع تأثيرات بصرية
    _controller.forward();
  }

  @override
  void didUpdateWidget(SmoothTextTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لا نحتاج لتغيير حالة الأنيميشن، النص مرئي دائماً
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: widget.slideEffect ? _slideAnimation : const AlwaysStoppedAnimation(Offset.zero),
            child: FadeTransition(
              opacity: AlwaysStoppedAnimation(_opacityAnimation.value.clamp(0.0, 1.0)),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor ?? Colors.black,
                  ),
                ),
              ),
            ),
        );
      },
    );
  }
}

/// أنيميشن مخصص للحاوية مع تأثيرات انتقالية للون الخلفية
class SmoothContainerTransition extends StatefulWidget {
  const SmoothContainerTransition({
    super.key,
    required this.child,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.borderRadius = 20.0,
  });

  final Widget child;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final Duration duration;
  final Curve curve;
  final double borderRadius;

  @override
  State<SmoothContainerTransition> createState() => _SmoothContainerTransitionState();
}

class _SmoothContainerTransitionState extends State<SmoothContainerTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SmoothContainerTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value.clamp(0.5, 2.0),
          child: Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value ?? Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: (_colorAnimation.value ?? Colors.transparent).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
