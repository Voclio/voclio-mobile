import 'dart:async';
import 'package:flutter/material.dart';
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

class _FocusTimerContentState extends State<_FocusTimerContent> {
  int selectedDuration = 25;
  String? selectedSound;
  int soundVolume = 50;
  bool isRunning = false;
  int remainingSeconds = 0;
  Timer? timer;
  String? currentSessionId;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
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

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = 0;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus Timer')),
      body: BlocListener<ProductivityCubit, ProductivityState>(
        listener: (context, state) {
          if (state is FocusSessionStarted) {
            currentSessionId = state.session.id;
          }
          if (state is ProductivityError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250.w,
                  height: 250.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRunning ? Colors.blue[100] : Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isRunning
                          ? formatTime(remainingSeconds)
                          : '$selectedDuration:00',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: isRunning ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 48.h),
                if (!isRunning) ...[
                  Text(
                    'Duration (minutes)',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          [15, 25, 45, 60].map((duration) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: ChoiceChip(
                                label: Text('$duration min'),
                                selected: selectedDuration == duration,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) selectedDuration = duration;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    'Ambient Sound',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButton<String?>(
                    value: selectedSound,
                    hint: const Text('None'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('None')),
                      DropdownMenuItem(value: 'rain', child: Text('Rain')),
                      DropdownMenuItem(value: 'ocean', child: Text('Ocean')),
                      DropdownMenuItem(value: 'forest', child: Text('Forest')),
                      DropdownMenuItem(value: 'cafe', child: Text('Cafe')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSound = value;
                      });
                    },
                  ),
                  SizedBox(height: 48.h),
                  ElevatedButton(
                    onPressed: startTimer,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 48.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      'Start Focus Session',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Stay focused!',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton(
                    onPressed: stopTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 48.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text('Stop', style: TextStyle(fontSize: 18.sp)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
