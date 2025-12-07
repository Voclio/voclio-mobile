import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/app_cubit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../common/inputs/text_app.dart';
import '../styles/fonts/font_weight_helper.dart';
import 'package:video_player/video_player.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;
  bool _showButtons = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_current < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _onGetStarted() => context.goRoute(AppRouter.login);
  void _onSignIn() => context.goRoute(AppRouter.login);
  void _onSignUp() => context.goRoute(AppRouter.register);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.isDarkMode,
      builder: (context, isDarkMode, child) {
        return BlocBuilder<AppCubit, AppState>(
          builder: (context, appState) {
            return _buildOnboardingContent(context);
          },
        );
      },
    );
  }

  Widget _buildOnboardingContent(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 45.w,
                    height: 45.h,
                    child: Image.asset(
                      'assets/images/Microphone Icon.png',
                      fit: BoxFit.contain,
                      color: colors.primary,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextApp(
                    text: 'Voclio',
                    textAlign: TextAlign.center,
                    theme: context.textStyle.copyWith(
                      fontSize: 27.sp,
                      fontWeight: FontWeightHelper.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) {
                  setState(() {
                    _current = i;
                    if (i == 2) {
                      Future.delayed(const Duration(milliseconds: 400), () {
                        if (mounted) {
                          setState(() {
                            _showButtons = true;
                          });
                        }
                      });
                    } else {
                      _showButtons = false;
                    }
                  });
                },
                children: [
                  const _VideoPage(
                    description:
                        'Simply speak and watch your voice transform into organized tasks and notes instantly',
                  ),
                  const _VideoPage(
                    videoPath: 'assets/videos/tasks.mp4',
                    description:
                        "Access your voice-converted tasks anywhere and boost your productivity with hands-free note-taking.",
                  ),
                  _VideoPage(
                    videoPath: 'assets/videos/calender.mp4',
                    description:
                        "Convert notes into actionable tasks and stay on top of everything.",
                    isLastPage: true,
                    showButtons: _showButtons,
                  ),
                ],
              ),
            ),

            // Indicators
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: _DotsIndicator(
                count: 3,
                current: _current,
                activeColor: colors.primary!,
                inactiveColor: colors.accent!.withOpacity(0.4),
              ),
            ),

            // Bottom actions
            if (_current != 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _onGetStarted,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 32.w,
                        ),
                        backgroundColor: colors.primary!,
                        foregroundColor: colors.primary!,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _onNext,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextApp(
                            text: context.translate('next'),
                            theme: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: context.colors.white,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (_current == 2 && _showButtons)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                child: Column(
                  children: [
                    SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              backgroundColor: colors.primary!,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _onGetStarted,
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                    SizedBox(height: 10.h),
                    Text(
                      'or sign in with',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                    SizedBox(height: 10.h),
                    Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                onPressed: _onSignUp,
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                onPressed: _onSignIn,
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoPage extends StatefulWidget {
  final String videoPath;
  final String description;
  final bool loop;
  final bool isLastPage;
  final bool showButtons;

  const _VideoPage({
    Key? key,
    this.videoPath = 'assets/videos/welcome.mp4',
    this.description = '',
    this.loop = true,
    this.isLastPage = false,
    this.showButtons = false,
  }) : super(key: key);

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _videoController.play();
        _videoController.setLooping(widget.loop);
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedPadding(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: widget.isLastPage && widget.showButtons ? 10.h : 40.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          ),
          SizedBox(
            height: widget.isLastPage && widget.showButtons ? 8.h : 16.h,
          ),
          if (widget.description.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: widget.isLastPage && widget.showButtons ? 4.h : 20.h,
              ),
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:
                      widget.isLastPage && widget.showButtons ? 15.sp : 18.sp,
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;
  final Color inactiveColor;

  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: active ? 26 : 8,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
