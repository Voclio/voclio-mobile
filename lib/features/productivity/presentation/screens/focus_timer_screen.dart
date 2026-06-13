import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/productivity_cubit.dart';
import '../bloc/productivity_state.dart';
import '../constants/focus_ambient_sounds.dart';
import '../services/focus_ambient_player.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class FocusTimerScreen extends StatelessWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProductivityCubit>(),
      child: const _FocusTimerContent(),
    );
  }
}

class _FocusTimerContent extends StatefulWidget {
  const _FocusTimerContent();

  @override
  State<_FocusTimerContent> createState() => _FocusTimerContentState();
}

class _FocusTimerContentState extends State<_FocusTimerContent>
    with SingleTickerProviderStateMixin {
  static const _presets = [15, 25, 45, 60];
  static const _minDuration = 5;
  static const _maxDuration = 90;

  int selectedDuration = 25;
  String? selectedSound;
  int soundVolume = 50;
  bool isRunning = false;
  int remainingSeconds = 0;
  Timer? timer;
  String? currentSessionId;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final FocusAmbientPlayer _ambientPlayer = FocusAmbientPlayer();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _pulseController.dispose();
    unawaited(_ambientPlayer.dispose());
    super.dispose();
  }

  void _adjustDuration(int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      selectedDuration = (selectedDuration + delta).clamp(
        _minDuration,
        _maxDuration,
      );
    });
  }

  Future<void> _onSoundSelected(String? soundId) async {
    HapticFeedback.selectionClick();
    setState(() => selectedSound = soundId);

    if (!isRunning) {
      await _ambientPlayer.play(soundId, soundVolume);
    }
  }

  Future<void> _onVolumeChanged(double value) async {
    final volume = value.round();
    setState(() => soundVolume = volume);
    await _ambientPlayer.setVolume(volume);
  }

  Future<void> startTimer() async {
    HapticFeedback.mediumImpact();
    context.read<ProductivityCubit>().startFocusSession(
      selectedDuration,
      selectedSound,
      soundVolume,
    );

    setState(() {
      isRunning = true;
      remainingSeconds = selectedDuration * 60;
    });

    await _ambientPlayer.play(selectedSound, soundVolume);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          timer?.cancel();
          isRunning = false;
          HapticFeedback.heavyImpact();
          unawaited(_ambientPlayer.stop());
          _showCompletionDialog();
          if (currentSessionId != null) {
            context.read<ProductivityCubit>().endFocusSession(
              currentSessionId!,
              selectedDuration,
            );
          }
        }
      });
    });
  }

  void _showCompletionDialog() {
    VoclioDialog.showSuccess(
      context: context,
      title: 'Great Job!',
      message:
          'You completed a $selectedDuration minute focus session! Keep up the great work.',
      buttonText: 'Awesome!',
    );
  }

  void stopTimer() {
    HapticFeedback.lightImpact();
    VoclioDialog.showConfirm(
      context: context,
      title: 'Stop Session?',
      message: 'Are you sure you want to end this focus session early?',
      confirmText: 'Stop',
      cancelText: 'Continue',
      onConfirm: () async {
        timer?.cancel();
        await _ambientPlayer.stop();
        if (!mounted) return;
        setState(() {
          isRunning = false;
          remainingSeconds = 0;
        });
      },
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (!isRunning || selectedDuration == 0) return 0;
    final total = selectedDuration * 60;
    return 1 - (remainingSeconds / total);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: HomeSystemTokens.canvas,
      body: HomeCanvas(
        child: BlocListener<ProductivityCubit, ProductivityState>(
          listener: (context, state) {
            if (state is FocusSessionStarted) {
              currentSessionId = state.session.id;
            }
            if (state is ProductivityError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 4.h),
                  HomeScreenHeader(
                    title: 'Focus Timer',
                    subtitle: 'Stay in the zone',
                    icon: AppIcons.timer_rounded,
                    accent: HomeSystemTokens.purple,
                    compact: true,
                    actions: [
                      HomeIconButton(
                        icon: AppIcons.history_rounded,
                        color: HomeSystemTokens.inkSoft,
                        onTap: () {},
                      ),
                    ],
                  ),
                  Expanded(
                    child: isRunning
                        ? _buildRunningLayout(primaryColor)
                        : _buildSetupLayout(primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupLayout(Color primaryColor) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Center(child: _buildTimerCircle(primaryColor, compact: true)),
        ),
        Expanded(
          flex: 4,
          child: HomeSectionCard(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: _buildDurationControls(primaryColor),
          ),
        ),
        SizedBox(height: 10.h),
        Expanded(
          flex: 5,
          child: HomeSectionCard(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: _buildSoundControls(primaryColor),
          ),
        ),
        SizedBox(height: 12.h),
        _buildStartButton(primaryColor),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildRunningLayout(Color primaryColor) {
    return Column(
      children: [
        Expanded(
          child: Center(child: _buildTimerCircle(primaryColor, compact: false)),
        ),
        _buildRunningIndicator(primaryColor),
        SizedBox(height: 16.h),
        _buildStopButton(),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildTimerCircle(Color primaryColor, {required bool compact}) {
    final outer = compact ? 210.w : 250.w;
    final inner = compact ? 170.w : 200.w;
    final ring = compact ? 190.w : 230.w;
    final fontSize = compact ? 44.sp : 52.sp;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isRunning ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: outer,
            height: outer,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: outer,
                  height: outer,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isRunning
                          ? [
                              primaryColor.withValues(alpha: 0.12),
                              primaryColor.withValues(alpha: 0.04),
                            ]
                          : [
                              Colors.grey.withValues(alpha: 0.1),
                              Colors.grey.withValues(alpha: 0.04),
                            ],
                    ),
                  ),
                ),
                if (isRunning)
                  SizedBox(
                    width: ring,
                    height: ring,
                    child: CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: progress,
                        color: primaryColor,
                        strokeWidth: 7.w,
                      ),
                    ),
                  ),
                Container(
                  width: inner,
                  height: inner,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HomeSystemTokens.card,
                    boxShadow: HomeSystemTokens.cardShadow(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isRunning
                            ? formatTime(remainingSeconds)
                            : formatTime(selectedDuration * 60),
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w300,
                          color: isRunning ? primaryColor : Colors.grey[700],
                          letterSpacing: 2,
                        ),
                      ),
                      if (isRunning) ...[
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'FOCUSING',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationControls(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Duration',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: HomeSystemTokens.ink,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _roundControlButton(
              icon: Icons.remove_rounded,
              onTap: () => _adjustDuration(-5),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$selectedDuration',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    'minutes',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: HomeSystemTokens.inkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _roundControlButton(
              icon: AppIcons.add_rounded,
              onTap: () => _adjustDuration(5),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
          ),
          child: Slider(
            value: selectedDuration.toDouble(),
            min: _minDuration.toDouble(),
            max: _maxDuration.toDouble(),
            divisions: (_maxDuration - _minDuration) ~/ 5,
            activeColor: primaryColor,
            inactiveColor: primaryColor.withValues(alpha: 0.15),
            onChanged: (value) {
              setState(() => selectedDuration = value.round());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _presets.map((preset) {
            final isSelected = selectedDuration == preset;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => selectedDuration = preset);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : HomeSystemTokens.canvas,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : HomeSystemTokens.inkMuted.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '${preset}m',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : HomeSystemTokens.inkSoft,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _roundControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: HomeSystemTokens.canvas,
          shape: BoxShape.circle,
          border: Border.all(
            color: HomeSystemTokens.inkMuted.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(icon, size: 22.sp, color: HomeSystemTokens.ink),
      ),
    );
  }

  Widget _buildSoundControls(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ambient Sound',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: HomeSystemTokens.ink,
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 0.92,
            ),
            itemCount: FocusAmbientSounds.all.length,
            itemBuilder: (context, index) {
              final sound = FocusAmbientSounds.all[index];
              final isSelected = selectedSound == sound.id;
              return GestureDetector(
                onTap: () => _onSoundSelected(sound.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.1)
                        : HomeSystemTokens.canvas,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : HomeSystemTokens.inkMuted.withValues(alpha: 0.12),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sound.icon,
                        size: 18.sp,
                        color: isSelected ? primaryColor : HomeSystemTokens.inkSoft,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        sound.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? primaryColor : HomeSystemTokens.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedSound != null) ...[
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.volume_down_rounded, size: 16.sp, color: HomeSystemTokens.inkMuted),
              Expanded(
                child: Slider(
                  value: soundVolume.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: primaryColor,
                  inactiveColor: primaryColor.withValues(alpha: 0.15),
                  onChanged: _onVolumeChanged,
                ),
              ),
              Icon(Icons.volume_up_rounded, size: 16.sp, color: HomeSystemTokens.inkMuted),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStartButton(Color primaryColor) {
    return GestureDetector(
      onTap: startTimer,
      child: Container(
        width: double.infinity,
        height: 54.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withValues(alpha: 0.82)],
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.play_arrow_rounded, color: Colors.white, size: 26.sp),
            SizedBox(width: 8.w),
            Text(
              'Start Focus Session',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunningIndicator(Color primaryColor) {
    final soundLabel = FocusAmbientSounds.labelFor(selectedSound);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  soundLabel != null
                      ? 'Stay focused · $soundLabel playing'
                      : 'Stay focused! You\'re doing great.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStopButton() {
    return GestureDetector(
      onTap: stopTimer,
      child: Container(
        width: 150.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.stop_rounded, color: Colors.red, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'Stop',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
