import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/core/constants/app_assets.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/styles/fonts/font_family_helper.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/features/auth/presentation/bloc/auth_bloc.dart';

class VoclioSplashScreen extends StatefulWidget {
  const VoclioSplashScreen({super.key});

  @override
  State<VoclioSplashScreen> createState() => _VoclioSplashScreenState();
}

class _VoclioSplashScreenState extends State<VoclioSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _nameFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFAFAFE),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    final curve = CurvedAnimation(parent: _reveal, curve: Curves.easeOutCubic);

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _reveal, curve: const Interval(0, 0.65, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.94, end: 1).animate(curve);
    _nameFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _reveal, curve: const Interval(0.4, 1, curve: Curves.easeOut)),
    );

    _reveal.forward();
    Future.delayed(const Duration(milliseconds: 2000), _finishSplash);
  }

  void _finishSplash() {
    if (!mounted) return;
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final primary = context.colors.primary ?? HomeSystemTokens.purple;
    final logoSize = size.width * 0.38;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.goRoute(AppRouter.home);
        } else if (state is AuthInitial) {
          context.goRoute(AppRouter.onboarding);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFE),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _LuxuryBackdrop(primary: primary),
            Center(
              child: AnimatedBuilder(
                animation: _reveal,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _logoFade.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: _LuxuryLogoMark(
                            logoSize: logoSize,
                            primary: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Opacity(
                        opacity: _nameFade.value,
                        child: _LuxuryWordmark(primary: primary),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryBackdrop extends StatelessWidget {
  const _LuxuryBackdrop({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(primary, Colors.white, 0.92)!,
            const Color(0xFFFAFAFE),
            Colors.white,
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
      child: CustomPaint(
        painter: _LuxuryBackdropPainter(primary: primary),
      ),
    );
  }
}

class _LuxuryBackdropPainter extends CustomPainter {
  _LuxuryBackdropPainter({required this.primary});

  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withValues(alpha: 0.1),
          primary.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.65));
    canvas.drawCircle(center, size.width * 0.65, halo);
  }

  @override
  bool shouldRepaint(covariant _LuxuryBackdropPainter oldDelegate) =>
      oldDelegate.primary != primary;
}

class _LuxuryLogoMark extends StatelessWidget {
  const _LuxuryLogoMark({
    required this.logoSize,
    required this.primary,
  });

  final double logoSize;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final frame = logoSize * 1.18;

    return SizedBox(
      width: frame,
      height: frame,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.85),
          border: Border.all(
            color: primary.withValues(alpha: 0.12),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.1),
              blurRadius: 56,
              spreadRadius: -8,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: AppLogo(
            width: logoSize * 0.76,
            height: logoSize * 0.76,
          ),
        ),
      ),
    );
  }
}

class _LuxuryWordmark extends StatelessWidget {
  const _LuxuryWordmark({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LuxuryRule(color: primary, alignEnd: false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'VOCLIO',
            style: TextStyle(
              fontFamily: FontFamilyHelper.poppinsEnglish,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 6,
              color: primary,
              height: 1,
            ),
          ),
        ),
        _LuxuryRule(color: primary, alignEnd: true),
      ],
    );
  }
}

class _LuxuryRule extends StatelessWidget {
  const _LuxuryRule({
    required this.color,
    required this.alignEnd,
  });

  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final solid = color.withValues(alpha: 0.45);
    final clear = color.withValues(alpha: 0);

    return Container(
      width: 32,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: alignEnd ? [solid, clear] : [clear, solid],
        ),
      ),
    );
  }
}
