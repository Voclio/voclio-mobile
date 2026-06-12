import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/constants/app_assets.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/app/app_cubit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../common/inputs/text_app.dart';
import '../styles/fonts/font_weight_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) => _buildOnboardingContent(context),
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
                  AppLogo(width: 84.w, height: 84.h),
                  SizedBox(width: 8),
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
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 18.w,
                        ),
                        minimumSize: Size(0, 40.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: colors.primary!,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 1,
                      ),
                      onPressed: _onNext,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextApp(
                            text: context.translate('next'),
                            theme: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            AppIcons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16.sp,
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

