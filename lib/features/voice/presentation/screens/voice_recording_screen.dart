import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VoiceRecordingScreen extends StatefulWidget {
  const VoiceRecordingScreen({super.key});

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen>
    with SingleTickerProviderStateMixin {
  bool isRecording = false;
  bool isListening = false;
  String transcription = '';
  final TextEditingController _transcriptController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
      if (isRecording) {
        isListening = true;
        // Simulate transcription
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && isListening) {
            setState(() {
              transcription =
                  'Meeting notes: Discussed project timeline, assigned tasks to team members';
              _transcriptController.text = transcription;
            });
          }
        });
      } else {
        isListening = false;
      }
    });
  }

  void _createTask() {
    // Navigate to create task with transcription
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Creating task from transcription...'),
        backgroundColor: context.colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _createNote() {
    // Navigate to create note with transcription
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Creating note from transcription...'),
        backgroundColor: context.colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voice Recording',
          style: context.textStyle.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60.h),

              // Recording Button
              GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 200.r,
                  height: 200.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors:
                          isRecording
                              ? [Color(0xFFEF4444), Color(0xFFDC2626)]
                              : [
                                colors.primary!,
                                colors.primary!.withOpacity(0.8),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isRecording
                                ? Color(0xFFEF4444).withOpacity(0.4)
                                : colors.primary!.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: isRecording ? 8 : 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 90.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40.h),

              // Waveform Animation
              if (isListening)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    15,
                    (index) => Container(
                          width: 4.w,
                          height: (20 + (index % 3) * 15).h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        )
                        .animate(
                          onPlay:
                              (controller) => controller.repeat(reverse: true),
                        )
                        .scaleY(
                          duration: (800 + index * 100).ms,
                          begin: 0.3,
                          end: 1.0,
                          curve: Curves.easeInOut,
                        ),
                  ),
                ).animate().fadeIn(duration: 300.ms),

              SizedBox(height: 20.h),

              // Status Text
              Text(
                isListening ? 'Listening...' : 'Tap to start recording',
                style: context.textStyle.copyWith(
                  fontSize: 16.sp,
                  color: colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 300.ms),

              SizedBox(height: 40.h),

              // Transcription Section
              if (transcription.isNotEmpty)
                Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transcription',
                            style: context.textStyle.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          TextField(
                            controller: _transcriptController,
                            maxLines: 6,
                            style: context.textStyle.copyWith(
                              fontSize: 15.sp,
                              color: colors.textPrimary,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Edit transcription...',
                              hintStyle: context.textStyle.copyWith(
                                color: colors.grey?.withOpacity(0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: colors.primary!,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: EdgeInsets.all(16.w),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.task_alt_rounded,
                                  label: 'Make Task',
                                  color: colors.primary!,
                                  onTap: _createTask,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.note_add_rounded,
                                  label: 'Make Note',
                                  color: const Color(0xFF10B981),
                                  onTap: _createNote,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
