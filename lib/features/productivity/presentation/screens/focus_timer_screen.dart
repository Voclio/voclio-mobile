import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/productivity_cubit.dart';
import '../bloc/productivity_state.dart';

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
  int selectedDuration = 25;
  String? selectedSound;
  int soundVolume = 50;
  bool isRunning = false;
  int remainingSeconds = 0;
  Timer? timer;
  String? currentSessionId;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> ambientSounds = [
    {'value': null, 'label': 'None', 'icon': Icons.volume_off},
    {'value': 'rain', 'label': 'Rain', 'icon': Icons.water_drop},
    {'value': 'ocean', 'label': 'Ocean', 'icon': Icons.waves},
    {'value': 'forest', 'label': 'Forest', 'icon': Icons.forest},
    {'value': 'cafe', 'label': 'Cafe', 'icon': Icons.coffee},
    {
      'value': 'fire',
      'label': 'Fireplace',
      'icon': Icons.local_fire_department,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void startTimer() {
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

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          timer?.cancel();
          isRunning = false;
          HapticFeedback.heavyImpact();
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, size: 64.sp, color: Colors.amber),
                SizedBox(height: 16.h),
                Text(
                  '🎉 Great Job!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'You completed a $selectedDuration minute focus session!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Awesome!'),
              ),
            ],
          ),
    );
  }

  void stopTimer() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text('Stop Session?'),
            content: const Text(
              'Are you sure you want to end this focus session early?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  timer?.cancel();
                  setState(() {
                    isRunning = false;
                    remainingSeconds = 0;
                  });
                },
                child: const Text('Stop', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Focus Timer'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show focus history
            },
          ),
        ],
      ),
      body: BlocListener<ProductivityCubit, ProductivityState>(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                // Timer Circle
                _buildTimerCircle(primaryColor),
                SizedBox(height: 40.h),
                // Controls
                if (!isRunning) ...[
                  _buildDurationSelector(primaryColor),
                  SizedBox(height: 32.h),
                  _buildSoundSelector(primaryColor),
                  SizedBox(height: 40.h),
                  _buildStartButton(primaryColor),
                ] else ...[
                  _buildRunningIndicator(primaryColor),
                  SizedBox(height: 32.h),
                  _buildStopButton(),
                ],
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCircle(Color primaryColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isRunning ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 280.w,
            height: 280.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isRunning
                        ? [
                          primaryColor.withOpacity(0.1),
                          primaryColor.withOpacity(0.05),
                        ]
                        : [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.05),
                        ],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isRunning
                          ? primaryColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress Ring
                if (isRunning)
                  SizedBox(
                    width: 260.w,
                    height: 260.w,
                    child: CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: progress,
                        color: primaryColor,
                        strokeWidth: 8.w,
                      ),
                    ),
                  ),
                // Inner Circle
                Container(
                  width: 220.w,
                  height: 220.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isRunning
                            ? formatTime(remainingSeconds)
                            : formatTime(selectedDuration * 60),
                        style: TextStyle(
                          fontSize: 52.sp,
                          fontWeight: FontWeight.w300,
                          color: isRunning ? primaryColor : Colors.grey[700],
                          letterSpacing: 2,
                        ),
                      ),
                      if (isRunning) ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'FOCUSING',
                            style: TextStyle(
                              fontSize: 12.sp,
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

  Widget _buildDurationSelector(Color primaryColor) {
    return Column(
      children: [
        Text(
          'Duration',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              [15, 25, 45, 60].map((duration) {
                final isSelected = selectedDuration == duration;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => selectedDuration = duration);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color:
                            isSelected ? primaryColor : Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$duration',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                          ),
                        ),
                        Text(
                          'min',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                                isSelected
                                    ? Colors.white70
                                    : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSoundSelector(Color primaryColor) {
    return Column(
      children: [
        Text(
          'Ambient Sound',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: selectedSound,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
              hint: Row(
                children: [
                  Icon(Icons.volume_off, size: 20.sp, color: Colors.grey[600]),
                  SizedBox(width: 12.w),
                  Text('None', style: TextStyle(fontSize: 16.sp)),
                ],
              ),
              items:
                  ambientSounds.map((sound) {
                    return DropdownMenuItem<String?>(
                      value: sound['value'],
                      child: Row(
                        children: [
                          Icon(
                            sound['icon'] as IconData,
                            size: 20.sp,
                            color: primaryColor,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            sound['label'] as String,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => selectedSound = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(Color primaryColor) {
    return GestureDetector(
      onTap: startTimer,
      child: Container(
        width: double.infinity,
        height: 60.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28.sp),
            SizedBox(width: 8.w),
            Text(
              'Start Focus Session',
              style: TextStyle(
                fontSize: 18.sp,
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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Stay focused! You\'re doing great.',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        if (selectedSound != null) ...[
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, size: 18.sp, color: Colors.grey[600]),
              SizedBox(width: 8.w),
              Text(
                'Playing: ${selectedSound!.substring(0, 1).toUpperCase()}${selectedSound!.substring(1)}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStopButton() {
    return GestureDetector(
      onTap: stopTimer,
      child: Container(
        width: 160.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop_rounded, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Stop',
              style: TextStyle(
                fontSize: 18.sp,
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

// Custom Painter for circular progress
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

    // Background circle
    final bgPaint =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint =
        Paint()
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
