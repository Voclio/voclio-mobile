import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

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

  final Color primaryOrange = const Color(0xFFF98006);
  final Color lightOrange = const Color(0xFFFFB347);

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
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _waveController,
    );

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
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

  void _navigateToNextScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    print("Navigate to main app");
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(title: 'title')));
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

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: Stack(
          children: [
            // Animated sound waves
            _buildSoundWaves(size),

            // Floating geometric shapes
            _buildFloatingShapes(size),

            // Main content
            SafeArea(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top spacing
                    SizedBox(height: isSmallScreen ? size.height * 0.1 : size.height * 0.15),

                    // Logo and text section
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAnimatedLogo(size, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 20 : 30),
                          _buildAnimatedText(size, isSmallScreen),
                        ],
                      ),
                    ),

                    // Loading section
                    Padding(
                      padding: EdgeInsets.only(bottom: isSmallScreen ? 40 : 60),
                      child: _buildLoadingSection(size, isSmallScreen),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundWaves(Size size) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Top sound wave bars
            Positioned(
              left: 0,
              right: 0,
              top: size.height * 0.15,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(15, (index) {
                    final wave = math.sin((_waveAnimation.value * 2 * math.pi * 2) + (index * 0.5));
                    final height = 15.0 + (wave * 25).abs();
                    final opacity = 0.15 + (wave.abs() * 0.15);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 3,
                      height: height,
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Bottom sound waves
            Positioned(
              left: 0,
              right: 0,
              bottom: size.height * 0.22,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(12, (index) {
                    final wave = math.sin((_waveAnimation.value * 2 * math.pi * 1.5) - (index * 0.6));
                    final height = 12.0 + (wave * 20).abs();
                    final opacity = 0.1 + (wave.abs() * 0.15);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 4,
                      height: height,
                      decoration: BoxDecoration(
                        color: lightOrange.withOpacity(opacity),
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

  Widget _buildFloatingShapes(Size size) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating triangles
            Positioned(
              top: size.height * 0.12 + (math.sin(_waveAnimation.value * 2 * math.pi) * 20),
              left: size.width * 0.1,
              child: Transform.rotate(
                angle: _waveAnimation.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(size.width * 0.08, size.width * 0.08),
                  painter: TrianglePainter(primaryOrange.withOpacity(0.15)),
                ),
              ),
            ),

            Positioned(
              bottom: size.height * 0.2 + (math.sin(_waveAnimation.value * 2 * math.pi + 1) * 15),
              right: size.width * 0.12,
              child: Transform.rotate(
                angle: -_waveAnimation.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(size.width * 0.07, size.width * 0.07),
                  painter: TrianglePainter(lightOrange.withOpacity(0.2)),
                ),
              ),
            ),

            // Floating squares
            Positioned(
              top: size.height * 0.28 + (math.sin(_waveAnimation.value * 2 * math.pi + 2) * 25),
              right: size.width * 0.15,
              child: Transform.rotate(
                angle: _waveAnimation.value * 2 * math.pi * 0.5,
                child: Container(
                  width: size.width * 0.065,
                  height: size.width * 0.065,
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: size.height * 0.3 + (math.sin(_waveAnimation.value * 2 * math.pi + 3) * 20),
              left: size.width * 0.12,
              child: Transform.rotate(
                angle: -_waveAnimation.value * 2 * math.pi * 0.7,
                child: Container(
                  width: size.width * 0.06,
                  height: size.width * 0.06,
                  decoration: BoxDecoration(
                    color: lightOrange.withOpacity(0.18),
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

  Widget _buildAnimatedLogo(Size size, bool isSmallScreen) {
    final logoSize = isSmallScreen ? size.width * 0.3 : size.width * 0.35;

    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _floatController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _logoScale.value,
            child: Opacity(
              opacity: _logoOpacity.value,
              child: SizedBox(
                width: logoSize * 1.5,
                height: logoSize * 1.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer hexagon
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _waveAnimation.value * 2 * math.pi,
                          child: CustomPaint(
                            size: Size(logoSize * 1.4, logoSize * 1.4),
                            painter: HexagonPainter(lightOrange.withOpacity(0.3), 2.5),
                          ),
                        );
                      },
                    ),

                    // Inner hexagon
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_waveAnimation.value * 2 * math.pi * 0.7,
                          child: CustomPaint(
                            size: Size(logoSize, logoSize),
                            painter: HexagonPainter(primaryOrange.withOpacity(0.25), 2),
                          ),
                        );
                      },
                    ),

                    // Logo
                    Image.asset(
                      'assets/images/Microphone Icon.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.mic_rounded,
                          size: logoSize,
                          color: primaryOrange,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText(Size size, bool isSmallScreen) {
    final titleSize = isSmallScreen ? 40.0 : 48.0;
    final subtitleSize = isSmallScreen ? 14.0 : 16.0;

    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: Opacity(
            opacity: _textOpacity.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated letter for "Voclio"
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 'Voclio  '.split('').asMap().entries.map((entry) {
                    return AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final offset = math.sin((_waveAnimation.value * 2 * math.pi) + (entry.key * 0.4)) * 3;
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                              color: primaryOrange,
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),

                // Subtitle
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.7 + (_floatAnimation.value.abs() / 10) * 0.3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 150),
                          child: Text(
                            'Your Voice, Your Story',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: subtitleSize,
                              fontWeight: FontWeight.w600,
                              color: primaryOrange,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection(Size size, bool isSmallScreen) {
    final barWidth = size.width * 0.5;
    final segmentCount = 20;
    final segmentWidth = (barWidth - (segmentCount * 4)) / segmentCount;

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar with segments
            SizedBox(
              width: barWidth,
              height: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(segmentCount, (index) {
                  final segmentProgress = (_progressValue.value * segmentCount) - index;
                  final opacity = segmentProgress.clamp(0.0, 1.0);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: segmentWidth,
                    height: 5,
                    decoration: BoxDecoration(
                      color: index < (_progressValue.value * segmentCount).floor()
                          ? primaryOrange.withOpacity(opacity)
                          : primaryOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Loading text with animated dots
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Loading',
                  style: TextStyle(
                    color: primaryOrange,
                    fontSize: isSmallScreen ? 15 : 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      final delay = index * 0.3;
                      final opacity = (((_progressController.value * 3) + delay) % 1.0);
                      return Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Opacity(
                          opacity: opacity,
                          child: Text(
                            '●',
                            style: TextStyle(
                              color: primaryOrange,
                              fontSize: isSmallScreen ? 15 : 17,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for hexagon
class HexagonPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  HexagonPainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - (math.pi / 6);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for triangle
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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