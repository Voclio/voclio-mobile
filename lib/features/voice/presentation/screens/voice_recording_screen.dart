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
import 'package:voclio_app/core/layout/main_layout.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/features/calendar/presentation/bloc/calendar_cubit.dart';
import 'package:voclio_app/features/calendar/presentation/screens/monthly_calendar_screen.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import '../bloc/voice_bloc.dart';
import '../bloc/voice_state.dart';
import '../bloc/voice_event.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

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

  _RecordingPhase _phase(VoiceState state) {
    if (state is VoiceLoading && _isProcessingLoading(state)) {
      return _RecordingPhase.processing;
    }
    if (isRecording) return _RecordingPhase.recording;
    if (transcription.isNotEmpty) return _RecordingPhase.done;
    return _RecordingPhase.idle;
  }

  bool _isProcessingLoading(VoiceState state) {
    if (state is! VoiceLoading) return false;
    final message = state.message.toLowerCase();
    return message.contains('upload') ||
        message.contains('transcrib') ||
        message.contains('processing');
  }

  _VoiceSaveAction? _pendingSaveAction(VoiceState state) {
    if (state is! VoiceLoading) return null;
    final message = state.message.toLowerCase();
    if (message.contains('creating note')) return _VoiceSaveAction.note;
    if (message.contains('creating task')) return _VoiceSaveAction.task;
    return null;
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
      context.read<VoiceBloc>().add(
            CreateTasksFromVoice(
              recordingId!,
              transcription: _transcriptController.text.trim(),
            ),
          );
    }
  }

  void _createNote() {
    if (recordingId != null) {
      context.read<VoiceBloc>().add(
            CreateNoteFromVoice(
              recordingId!,
              transcription: _transcriptController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceBloc, VoiceState>(
      listener: (context, state) {
        if (state is VoiceOperationSuccess) {
          if (state.destination != null) {
            final tabIndex = switch (state.destination!) {
              VoiceSuccessDestination.tasks => 1,
              VoiceSuccessDestination.calendar => 2,
              VoiceSuccessDestination.notes => 3,
            };
            final focusDate = state.calendarFocusDate ?? DateTime.now();
            if (state.destination == VoiceSuccessDestination.calendar) {
              MonthlyCalendarScreen.jumpTo(focusDate);
              context.read<CalendarCubit>().loadMonth(
                focusDate.year,
                focusDate.month,
                force: true,
              );
            }
            Navigator.of(context).pop();
            MainLayout.goToTab(tabIndex, calendarDate: focusDate);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
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
            icon: AppIcons.history_rounded,
            color: HomeSystemTokens.inkSoft,
            onTap: () => context.push(AppRouter.voice),
          ),
        ],
        body: BlocBuilder<VoiceBloc, VoiceState>(
          builder: (context, state) {
            final isProcessing =
                state is VoiceLoading && _isProcessingLoading(state);
            final pendingSave = _pendingSaveAction(state);
            final phase = _phase(state);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStudioCard(phase, isProcessing),
                        if (transcription.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          _buildTranscriptionCard(pendingSave),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildBottomControls(phase, isProcessing),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStudioCard(_RecordingPhase phase, bool isProcessing) {
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
          SizedBox(height: phase == _RecordingPhase.idle ? 20.h : 12.h),
          SizedBox(
            height: phase == _RecordingPhase.idle
                ? 120.h
                : phase == _RecordingPhase.done
                    ? 100.h
                    : 150.h,
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
                        width: 140.r + (ring * 20),
                        height: 140.r + (ring * 20),
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
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
            child: isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Flexible(
                        child: Text(
                          _bannerMessage(phase),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: HomeSystemTokens.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
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
        'Speak in Arabic or English — we\'ll show natural English text.',
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

  Widget _buildTranscriptionCard(_VoiceSaveAction? pendingSave) {
    final isSavingTask = pendingSave == _VoiceSaveAction.task;
    final isSavingNote = pendingSave == _VoiceSaveAction.note;
    final isBusy = pendingSave != null;

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
                  AppIcons.transcribe_rounded,
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
                      'Shown in English — edit before saving',
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
                  label: isSavingTask ? 'Saving…' : 'Make Task',
                  icon: AppIcons.check_circle_outline_rounded,
                  color: HomeSystemTokens.purple,
                  onTap: isBusy ? null : _createTask,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionChip(
                  label: isSavingNote ? 'Saving…' : 'Make Note',
                  icon: AppIcons.sticky_note_2_outlined,
                  color: HomeSystemTokens.green,
                  onTap: isBusy ? null : _createNote,
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

  Widget _buildBottomControls(_RecordingPhase phase, bool isProcessing) {
    final isRecording = phase == _RecordingPhase.recording;
    final isCompact = phase == _RecordingPhase.done;
    final accent =
        isRecording ? HomeSystemTokens.coral : HomeSystemTokens.purple;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isCompact ? 118.h : 190.h),
      padding: EdgeInsets.fromLTRB(
        24.w,
        isCompact ? 12.h : 24.h,
        24.w,
        isCompact ? 8.h : 12.h,
      ),
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
              onTap: isProcessing ? null : _toggleRecording,
              child: AnimatedBuilder(
                animation: _pulseController ?? const AlwaysStoppedAnimation(0),
                builder: (_, child) {
                  final pulse = _pulseController?.value ?? 0;
                  final scale =
                      isRecording ? 1.0 + (pulse * 0.05) : 1.0;
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: isCompact ? 72.r : 96.r,
                  height: isCompact ? 72.r : 96.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: isCompact ? 0.25 : 0.4),
                        blurRadius: isCompact ? 16 : 24,
                        offset: Offset(0, isCompact ? 6 : 10),
                      ),
                    ],
                  ),
                  child: isProcessing
                      ? Padding(
                          padding: EdgeInsets.all(isCompact ? 20.r : 28.r),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          isRecording
                              ? AppIcons.stop_rounded
                              : AppIcons.mic_rounded,
                          color: Colors.white,
                          size: isCompact ? 32.sp : 40.sp,
                        ),
                ),
              ),
            ),
            SizedBox(height: isCompact ? 8.h : 12.h),
            Text(
              isProcessing
                  ? 'Processing…'
                  : isRecording
                      ? 'Tap to stop'
                      : isCompact
                          ? 'Record again'
                          : 'Tap to record',
              style: TextStyle(
                fontSize: isCompact ? 13.sp : 15.sp,
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

enum _VoiceSaveAction { task, note }

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

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
        child: Opacity(
          opacity: onTap == null ? 0.55 : 1,
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
      ),
    );
  }
}
