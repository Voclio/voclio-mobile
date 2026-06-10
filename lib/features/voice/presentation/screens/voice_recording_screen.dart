import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
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

enum _RecordingPhase { idle, recording, processing, done }

class _VoiceRecordingContent extends StatefulWidget {
  const _VoiceRecordingContent();

  @override
  State<_VoiceRecordingContent> createState() => _VoiceRecordingContentState();
}

class _VoiceRecordingContentState extends State<_VoiceRecordingContent>
    with TickerProviderStateMixin {
  bool isRecording = false;
  String transcription = '';
  String? recordingId;
  Duration _elapsed = Duration.zero;
  Timer? _durationTimer;

  final TextEditingController _transcriptController = TextEditingController();
  AnimationController? _pulseController;
  AnimationController? _ringController;
  AudioRecorder? _audioRecorder;

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
  }

  void _initAnimationControllers() {
    _pulseController ??= AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _ringController ??= AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _audioRecorder?.dispose();
    _pulseController?.dispose();
    _ringController?.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  _RecordingPhase _phase(bool isLoading) {
    if (isLoading) return _RecordingPhase.processing;
    if (isRecording) return _RecordingPhase.recording;
    if (transcription.isNotEmpty) return _RecordingPhase.done;
    return _RecordingPhase.idle;
  }

  void _startDurationTimer() {
    _elapsed = Duration.zero;
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _startRecording() async {
    try {
      _initAnimationControllers();
      _audioRecorder ??= AudioRecorder();

      if (await _audioRecorder!.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = p.join(
          dir.path,
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        await _audioRecorder!.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            numChannels: 1,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        _pulseController!.repeat(reverse: true);
        _ringController!.repeat();
        _startDurationTimer();

        setState(() {
          isRecording = true;
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
        setState(() => isRecording = false);
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_audioRecorder == null || !await _audioRecorder!.isRecording()) {
        _stopAnimations();
        setState(() => isRecording = false);
        return;
      }

      final path = await _audioRecorder!.stop();
      _stopAnimations();
      setState(() => isRecording = false);

      if (path != null && mounted) {
        context.read<VoiceBloc>().add(UploadVoiceFile(File(path)));
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
      if (mounted) {
        _stopAnimations();
        setState(() => isRecording = false);
      }
    }
  }

  void _stopAnimations() {
    _pulseController?.stop();
    _pulseController?.reset();
    _ringController?.stop();
    _ringController?.reset();
    _stopDurationTimer();
  }

  void _toggleRecording() {
    _initAnimationControllers();
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
    return BlocListener<VoiceBloc, VoiceState>(
      listener: (context, state) {
        if (state is VoiceOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is VoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: HomeSystemTokens.coral,
            ),
          );
        } else if (state is VoiceTranscriptionLoaded) {
          setState(() {
            transcription = state.transcription;
            recordingId = state.recordingId;
            _transcriptController.text = transcription;
          });
        }
      },
      child: HomeSecondaryScaffold(
        title: 'Record',
        subtitle: '',
        icon: null,
        accent: HomeSystemTokens.purple,
        actions: [
          HomeIconButton(
            icon: Icons.history_rounded,
            color: HomeSystemTokens.inkSoft,
            onTap: () => context.push(AppRouter.voice),
          ),
        ],
        body: BlocBuilder<VoiceBloc, VoiceState>(
          builder: (context, state) {
            final isLoading = state is VoiceLoading;
            final phase = _phase(isLoading);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStudioCard(phase, isLoading),
                        if (transcription.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          _buildTranscriptionCard(),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildBottomControls(phase, isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStudioCard(_RecordingPhase phase, bool isLoading) {
    final accent = phase == _RecordingPhase.recording
        ? HomeSystemTokens.coral
        : HomeSystemTokens.purple;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HomeSystemTokens.radiusLg.r),
        boxShadow: HomeSystemTokens.cardShadow(),
        border: Border.all(
          color: accent.withValues(
            alpha: phase == _RecordingPhase.recording ? 0.2 : 0.08,
          ),
        ),
      ),
      child: Column(
        children: [
          if (phase == _RecordingPhase.recording ||
              phase == _RecordingPhase.processing) ...[
            SizedBox(height: 20.h),
            Text(
              _formatDuration(_elapsed),
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w300,
                color: HomeSystemTokens.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: 2,
              ),
            ),
          ],
          SizedBox(height: phase == _RecordingPhase.idle ? 24.h : 16.h),
          SizedBox(
            height: phase == _RecordingPhase.idle ? 140.h : 180.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (phase == _RecordingPhase.recording &&
                    _ringController != null)
                  AnimatedBuilder(
                    animation: _ringController!,
                    builder: (_, __) {
                      final ring = _ringController!.value;
                      return Container(
                        width: 160.r + (ring * 24),
                        height: 160.r + (ring * 24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.15 * (1 - ring)),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                _buildVisualizer(phase, accent),
                if (isLoading)
                  SizedBox(
                    width: 36.r,
                    height: 36.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: accent,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            child: Text(
              _bannerMessage(phase),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: phase == _RecordingPhase.idle
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: phase == _RecordingPhase.idle
                    ? HomeSystemTokens.ink
                    : HomeSystemTokens.inkMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0);
  }

  String _bannerMessage(_RecordingPhase phase) {
    return switch (phase) {
      _RecordingPhase.idle =>
        'Speak naturally — turn your voice into tasks & notes in seconds.',
      _RecordingPhase.recording =>
        'We\'re listening… tap stop when you\'re done.',
      _RecordingPhase.processing =>
        'Transcribing your recording… hang tight.',
      _RecordingPhase.done =>
        'Done! Review below and save as a task or note.',
    };
  }

  Widget _buildVisualizer(_RecordingPhase phase, Color accent) {
    final isActive = phase == _RecordingPhase.recording;

    Widget bars(double pulse) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(24, (i) {
          final base = 8.0 + (i % 5) * 6;
          final maxH = isActive ? base + 28 : base + 4;
          final wave = isActive
              ? maxH * (0.35 + (pulse * 0.65) * ((i % 3) + 1) / 3)
              : base;

          return AnimatedContainer(
            duration:
                Duration(milliseconds: isActive ? 120 + (i % 4) * 40 : 300),
            curve: Curves.easeInOut,
            width: 3.w,
            height: wave.h,
            margin: EdgeInsets.symmetric(horizontal: 1.5.w),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isActive ? 0.75 : 0.18),
              borderRadius: BorderRadius.circular(3.r),
            ),
          );
        }),
      );
    }

    if (!isActive || _pulseController == null) return bars(0);

    return AnimatedBuilder(
      animation: _pulseController!,
      builder: (_, __) => bars(_pulseController!.value),
    );
  }

  Widget _buildTranscriptionCard() {
    return HomeSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: HomeSystemTokens.blue.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(HomeSystemTokens.radiusSm.r),
                ),
                child: Icon(
                  Icons.transcribe_rounded,
                  color: HomeSystemTokens.blue,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transcription',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: HomeSystemTokens.ink,
                      ),
                    ),
                    Text(
                      'Edit before saving',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: HomeSystemTokens.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: _transcriptController,
            maxLines: 5,
            style: TextStyle(
              fontSize: 15.sp,
              color: HomeSystemTokens.ink,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Your transcribed text…',
              hintStyle: TextStyle(color: HomeSystemTokens.inkMuted),
              filled: true,
              fillColor: HomeSystemTokens.canvas,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(HomeSystemTokens.radiusMd.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(14.w),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  label: 'Make Task',
                  icon: Icons.check_circle_outline_rounded,
                  color: HomeSystemTokens.purple,
                  onTap: _createTask,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionChip(
                  label: 'Make Note',
                  icon: Icons.sticky_note_2_outlined,
                  color: HomeSystemTokens.green,
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
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildBottomControls(_RecordingPhase phase, bool isLoading) {
    final isRecording = phase == _RecordingPhase.recording;
    final accent =
        isRecording ? HomeSystemTokens.coral : HomeSystemTokens.purple;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 220.h),
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: isLoading ? null : _toggleRecording,
              child: AnimatedBuilder(
                animation: _pulseController ?? const AlwaysStoppedAnimation(0),
                builder: (_, child) {
                  final pulse = _pulseController?.value ?? 0;
                  final scale =
                      isRecording ? 1.0 + (pulse * 0.05) : 1.0;
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 108.r,
                  height: 108.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? Padding(
                          padding: EdgeInsets.all(32.r),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          isRecording
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: Colors.white,
                          size: 48.sp,
                        ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isLoading
                  ? 'Processing…'
                  : isRecording
                      ? 'Tap to stop'
                      : 'Tap to record',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: HomeSystemTokens.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(HomeSystemTokens.radiusMd.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeSystemTokens.radiusMd.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 13.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
