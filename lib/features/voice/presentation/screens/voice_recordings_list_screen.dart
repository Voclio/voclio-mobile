import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import '../../domain/entities/voice_recording.dart';
import '../bloc/voice_bloc.dart';
import '../bloc/voice_event.dart';
import '../bloc/voice_state.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class VoiceRecordingsListScreen extends StatelessWidget {
  const VoiceRecordingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VoiceBloc>()..add(LoadVoiceRecordings()),
      child: Builder(
        builder: (context) => HomeSecondaryScaffold(
          title: 'Voice Recordings',
          subtitle: 'Your saved recordings',
          icon: AppIcons.mic_rounded,
          accent: HomeSystemTokens.purple,
          floatingActionButton: Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  HomeSystemTokens.purple,
                  HomeSystemTokens.purple.withValues(alpha: 0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: HomeSystemTokens.purple.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: Colors.white.withValues(alpha: 0.25),
                onTap: () async {
                  await context.push(AppRouter.voiceRecorder);
                  if (context.mounted) {
                    context.read<VoiceBloc>().add(LoadVoiceRecordings());
                  }
                },
                child: Center(
                  child: Icon(
                    AppIcons.mic_filled,
                    size: 26.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          body: BlocConsumer<VoiceBloc, VoiceState>(
            listener: (context, state) {
              if (state is VoiceOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is VoiceError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is VoiceLoading && state is! VoiceLoaded) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is VoiceLoaded) {
                if (state.recordings.isEmpty) {
                  return HomeEmptyState(
                    icon: AppIcons.mic_off_rounded,
                    title: 'No recordings yet',
                    message: 'Tap the mic button to record your first voice note.',
                    accent: HomeSystemTokens.purple,
                  );
                }
                return _VoiceRecordingsList(
                  recordings: state.recordings,
                );
              } else if (state is VoiceError) {
                return HomeEmptyState(
                  icon: AppIcons.error_outline_rounded,
                  title: 'Failed to load',
                  message: state.message,
                  actionLabel: 'Retry',
                  accent: HomeSystemTokens.coral,
                  onAction: () =>
                      context.read<VoiceBloc>().add(LoadVoiceRecordings()),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

class _VoiceRecordingsList extends StatefulWidget {
  final List<VoiceRecording> recordings;

  const _VoiceRecordingsList({required this.recordings});

  @override
  State<_VoiceRecordingsList> createState() => _VoiceRecordingsListState();
}

class _VoiceRecordingsListState extends State<_VoiceRecordingsList> {
  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _playingId = null;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback(VoiceRecording recording) async {
    if (recording.url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio file is not available yet.')),
      );
      return;
    }

    if (_playingId == recording.id && _isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }

    if (_playingId == recording.id && !_isPlaying) {
      await _player.resume();
      setState(() => _isPlaying = true);
      return;
    }

    await _player.stop();
    setState(() {
      _playingId = recording.id;
      _isPlaying = true;
    });

    try {
      await _player.play(UrlSource(recording.url));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playingId = null;
        _isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play recording: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) return '';
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
      itemCount: widget.recordings.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final recording = widget.recordings[index];
        final isActive = _playingId == recording.id;
        final isPlaying = isActive && _isPlaying;
        final durationLabel = _formatDuration(recording.duration);

        return HomeSectionCard(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _togglePlayback(recording),
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: HomeSystemTokens.purple.withValues(
                      alpha: isActive ? 0.18 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : AppIcons.play_arrow_rounded,
                    color: HomeSystemTokens.purple,
                    size: 22.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _togglePlayback(recording),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recording.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: HomeSystemTokens.ink,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        [
                          recording.createdAt.toString().split(' ')[0],
                          if (durationLabel.isNotEmpty) durationLabel,
                          if (isPlaying) 'Playing…',
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isPlaying
                              ? HomeSystemTokens.purple
                              : HomeSystemTokens.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              HomeIconButton(
                icon: AppIcons.note_add_outlined,
                color: HomeSystemTokens.purple,
                onTap: () {
                  context.read<VoiceBloc>().add(
                        CreateNoteFromVoice(recording.id),
                      );
                },
              ),
              SizedBox(width: 4.w),
              HomeIconButton(
                icon: AppIcons.task_alt_outlined,
                color: HomeSystemTokens.purple,
                onTap: () {
                  context.read<VoiceBloc>().add(
                        CreateTasksFromVoice(recording.id),
                      );
                },
              ),
              SizedBox(width: 4.w),
              HomeIconButton(
                icon: AppIcons.delete_outline,
                color: HomeSystemTokens.coral,
                onTap: () {
                  if (_playingId == recording.id) {
                    _player.stop();
                    _playingId = null;
                    _isPlaying = false;
                  }
                  VoclioDialog.showConfirm(
                    context: context,
                    title: 'Delete Recording?',
                    message:
                        'This action cannot be undone. Are you sure you want to delete this recording?',
                    confirmText: 'Delete',
                    cancelText: 'Cancel',
                    onConfirm: () {
                      context.read<VoiceBloc>().add(
                            DeleteVoiceRecording(recording.id),
                          );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
