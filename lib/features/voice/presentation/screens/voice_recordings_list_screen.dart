import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';
import '../bloc/voice_bloc.dart';
import '../bloc/voice_event.dart';
import '../bloc/voice_state.dart';

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
          icon: Icons.mic_rounded,
          accent: HomeSystemTokens.blue,
          floatingActionButton: FloatingActionButton(
            backgroundColor: HomeSystemTokens.purple,
            onPressed: () async {
              await context.push(AppRouter.voiceRecorder);
              if (context.mounted) {
                context.read<VoiceBloc>().add(LoadVoiceRecordings());
              }
            },
            child: const Icon(Icons.mic),
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
                    icon: Icons.mic_off_rounded,
                    title: 'No recordings yet',
                    message: 'Tap the mic button to record your first voice note.',
                    accent: HomeSystemTokens.blue,
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                  itemCount: state.recordings.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final recording = state.recordings[index];
                    return HomeSectionCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44.r,
                            height: 44.r,
                            decoration: BoxDecoration(
                              color: HomeSystemTokens.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.mic_rounded,
                              color: HomeSystemTokens.blue,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
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
                                  recording.createdAt.toString().split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: HomeSystemTokens.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          HomeIconButton(
                            icon: Icons.note_add_outlined,
                            color: HomeSystemTokens.purple,
                            onTap: () {
                              context.read<VoiceBloc>().add(
                                    CreateNoteFromVoice(recording.id),
                                  );
                            },
                          ),
                          SizedBox(width: 4.w),
                          HomeIconButton(
                            icon: Icons.task_alt_outlined,
                            color: HomeSystemTokens.green,
                            onTap: () {
                              context.read<VoiceBloc>().add(
                                    CreateTasksFromVoice(recording.id),
                                  );
                            },
                          ),
                          SizedBox(width: 4.w),
                          HomeIconButton(
                            icon: Icons.delete_outline,
                            color: HomeSystemTokens.coral,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Recording?'),
                                  content: const Text(
                                    'This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        context.read<VoiceBloc>().add(
                                              DeleteVoiceRecording(
                                                recording.id,
                                              ),
                                            );
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (state is VoiceError) {
                return HomeEmptyState(
                  icon: Icons.error_outline_rounded,
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
