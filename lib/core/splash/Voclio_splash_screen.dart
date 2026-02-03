import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'dart:math' as math;

import '../extentions/color_extentions.dart';

class VoclioSplashScreen extends StatefulWidget {
  const VoclioSplashScreen({Key? key}) : super(key: key);

  @override
  State<VoclioSplashScreen> createState() => _VoclioSplashScreenState();
}

class _VoclioSplashScreenState extends State<VoclioSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _waveController;
  late AnimationController _floatController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressValue;
  late Animation<double> _waveAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_waveController);
    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _textController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    _waveController.stop();
    _floatController.stop();
    _logoController.stop();
    _textController.stop();
    _progressController.stop();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _waveController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;
    final colors = context.colors;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.goRoute(AppRouter.home);
        } else if (state is AuthInitial) {
          context.goRoute(AppRouter.onboarding);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: size.width,
          height: size.height,
          color: Colors.white,
          child: Stack(
            children: [
              _buildSoundWaves(size, colors),
              _buildFloatingShapes(size, colors),
              SafeArea(
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height:
                            isSmallScreen
                                ? size.height * 0.1
                                : size.height * 0.15,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAnimatedLogo(size, isSmallScreen, colors),
                            SizedBox(height: isSmallScreen ? 20 : 30),
                            _buildAnimatedText(size, isSmallScreen, colors),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: isSmallScreen ? 40 : 60,
                        ),
                        child: _buildLoadingSection(
                          size,
                          isSmallScreen,
                          colors,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundWaves(Size size, MyColors colors) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.15,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(15, (index) {
                    final wave = math.sin(
                      (_waveAnimation.value * 2 * math.pi * 2) + (index * 0.5),
                    );
                    final height = 15.0 + (wave * 25).abs();
                    final opacity = 0.15 + (wave.abs() * 0.15);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 3,
                      height: height,
                      decoration: BoxDecoration(
                        color: colors.primary!.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.22,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(12, (index) {
                    final wave = math.sin(
                      (_waveAnimation.value * 2 * math.pi * 1.5) -
                          (index * 0.6),
                    );
                    final height = 12.0 + (wave * 20).abs();
                    final opacity = 0.1 + (wave.abs() * 0.15);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 4,
                      height: height,
                      decoration: BoxDecoration(
                        color: colors.primary!.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingShapes(Size size, MyColors colors) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 🔹 مثلث أعلى اليسار
            Positioned(
              top:
                  size.height * 0.12 +
                  (math.sin(_waveAnimation.value * 2 * math.pi) * 20),
              left: size.width * 0.1,
              child: Transform.rotate(
                angle: _waveAnimation.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(size.width * 0.08, size.width * 0.08),
                  painter: TrianglePainter(colors.primary!.withOpacity(0.15)),
                ),
              ),
            ),

            // 🔹 مثلث أسفل اليمين
            Positioned(
              bottom:
                  size.height * 0.2 +
                  (math.sin(_waveAnimation.value * 2 * math.pi + 1) * 15),
              right: size.width * 0.12,
              child: Transform.rotate(
                angle: -_waveAnimation.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(size.width * 0.07, size.width * 0.07),
                  painter: TrianglePainter(colors.primary!.withOpacity(0.2)),
                ),
              ),
            ),

            // 🟦 مكعب أعلى اليمين
            Positioned(
              top:
                  size.height * 0.28 +
                  (math.sin(_waveAnimation.value * 2 * math.pi + 2) * 25),
              right: size.width * 0.15,
              child: Transform.rotate(
                angle: _waveAnimation.value * 2 * math.pi * 0.5,
                child: Container(
                  width: size.width * 0.065,
                  height: size.width * 0.065,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary!.withOpacity(0.25),
                        colors.primary!.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),

            // 🟪 مكعب أسفل اليسار
            Positioned(
              bottom:
                  size.height * 0.3 +
                  (math.sin(_waveAnimation.value * 2 * math.pi + 3) * 20),
              left: size.width * 0.12,
              child: Transform.rotate(
                angle: -_waveAnimation.value * 2 * math.pi * 0.7,
                child: Container(
                  width: size.width * 0.06,
                  height: size.width * 0.06,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                        colors.accent!.withOpacity(0.2),
                        colors.primary!.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedLogo(Size size, bool isSmall, MyColors colors) {
    final logoSize = isSmall ? size.width * 0.3 : size.width * 0.35;
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _floatController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _logoScale.value,
            child: Opacity(
              opacity: _logoOpacity.value,
              child: Image.asset(
                'assets/images/12.png',
                width: logoSize,
                height: logoSize,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText(Size size, bool isSmall, MyColors colors) {
    final titleSize = isSmall ? 40.0 : 48.0;
    final subtitleSize = isSmall ? 14.0 : 16.0;

    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: Opacity(
            opacity: _textOpacity.value,
            child: Column(
              children: [
                Text(
                  'Voclio',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Voice, Your Story',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection(Size size, bool isSmall, MyColors colors) {
    final barWidth = size.width * 0.6;
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: barWidth,
              height: 4,
              decoration: BoxDecoration(
                color: colors.primary!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressValue.value.clamp(0.0, 1.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Initializing Voclio...',
              style: TextStyle(
                color: colors.primary,
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        );
      },
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
