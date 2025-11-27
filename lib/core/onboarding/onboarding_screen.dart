import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/app_cubit.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_current < 2) { // انتقل لكل الفيديوهات ما عدا الأخير
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _onGetStarted() => context.goRoute(AppRouter.login);

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
                onPageChanged: (i) => setState(() => _current = i),
                children: const [
                  _VideoPage(
                    description: 'Simply speak and watch your voice transform into organized tasks and notes instantly',
                  ),
                  _VideoPage(
                    videoPath: 'assets/videos/tasks.mp4',
                    description: "Access your voice-converted tasks anywhere and boost your productivity with hands-free note-taking.",
                  ),
                  _VideoPage(
                    videoPath: 'assets/videos/calender.mp4',
                    description: "AI-powered categorization automatically sorts your voice notes into tasks, reminders, and ideas.",
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colors.primary!,
                        foregroundColor: colors.primary!,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _current == 2 ? _onGetStarted : _onNext,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextApp(
                            text: _current == 2
                                ? context.translate('get_started')
                                : context.translate('next'),
                            theme: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _current == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                            color: context.colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
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

  const _VideoPage({
    Key? key,
    this.videoPath = 'assets/videos/welcome.mp4',
    this.description = '',
    this.loop = true,
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
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
