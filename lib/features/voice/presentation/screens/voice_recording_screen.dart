import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:voclio_app/core/di/injection_container.dart';
import '../bloc/voice_bloc.dart';
import '../bloc/voice_state.dart';
import '../bloc/voice_event.dart';

class VoiceRecordingScreen extends StatelessWidget {
  const VoiceRecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VoiceBloc>(),
      child: const _VoiceRecordingContent(),
    );
  }
}

class _VoiceRecordingContent extends StatefulWidget {
  const _VoiceRecordingContent();

  @override
  State<_VoiceRecordingContent> createState() => _VoiceRecordingContentState();
}

class _VoiceRecordingContentState extends State<_VoiceRecordingContent>
    with SingleTickerProviderStateMixin {
  bool isRecording = false;
  bool isListening = false;
  String transcription = '';
  String? recordingId;
  final TextEditingController _transcriptController = TextEditingController();
  late AnimationController _pulseController;
  late final AudioRecorder _audioRecorder;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _pulseController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission not granted')),
          );
        }
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        final Directory appDocumentsDir =
            await getApplicationDocumentsDirectory();
        final String filePath = p.join(
          appDocumentsDir.path,
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            numChannels: 1,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        setState(() {
          isRecording = true;
          isListening = true;
          transcription = '';
          recordingId = null;
          _transcriptController.clear();
        });
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
        setState(() {
          isRecording = false;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (!await _audioRecorder.isRecording()) {
        setState(() {
          isRecording = false;
          isListening = false;
        });
        return;
      }

      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
        isListening = false;
      });

      if (path != null && mounted) {
        context.read<VoiceBloc>().add(UploadVoiceFile(File(path)));
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
      if (mounted) {
        setState(() {
          isRecording = false;
          isListening = false;
        });
      }
    }
  }

  void _toggleRecording() {
    if (isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _createTask() {
    if (recordingId != null) {
      context.read<VoiceBloc>().add(CreateTasksFromVoice(recordingId!));
    }
  }

  void _createNote() {
    if (recordingId != null) {
      context.read<VoiceBloc>().add(CreateNoteFromVoice(recordingId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<VoiceBloc, VoiceState>(
      listener: (context, state) {
        if (state is VoiceOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is VoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is VoiceTranscriptionLoaded) {
          setState(() {
            transcription = state.transcription;
            recordingId = state.recordingId;
            _transcriptController.text = transcription;
          });
        }
      },
      child: Scaffold(
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
        body: BlocBuilder<VoiceBloc, VoiceState>(
          builder: (context, state) {
            final isLoading = state is VoiceLoading;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60.h),

                    // Recording Button
                    GestureDetector(
                      onTap: isLoading ? null : _toggleRecording,
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isLoading)
                              SizedBox(
                                width: 200.r,
                                height: 200.r,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            Icon(
                              isRecording
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              size: 90.sp,
                              color: Colors.white,
                            ),
                          ],
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
                                    (controller) =>
                                        controller.repeat(reverse: true),
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
                      isListening
                          ? 'Listening...\n(Transcription available after stopping)'
                          : isLoading
                          ? 'Processing...'
                          : 'Tap to start recording',
                      textAlign: TextAlign.center,
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
            );
          },
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
