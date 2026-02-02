import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:voclio_app/core/di/injection_container.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
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
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Voice Recordings'),
                centerTitle: true,
              ),
              body: BlocConsumer<VoiceBloc, VoiceState>(
                listener: (context, state) {
                  if (state is VoiceOperationSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic_off,
                              size: 64.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No voice recordings yet',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.recordings.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final recording = state.recordings[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.mic,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(
                              recording.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                            subtitle: Text(
                              recording.createdAt.toString().split(
                                ' ',
                              )[0], // Simple date
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.note_add_outlined),
                                  onPressed: () {
                                    context.read<VoiceBloc>().add(
                                      CreateNoteFromVoice(recording.id),
                                    );
                                  },
                                  tooltip: 'Create Note',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.task_alt_outlined),
                                  onPressed: () {
                                    context.read<VoiceBloc>().add(
                                      CreateTasksFromVoice(recording.id),
                                    );
                                  },
                                  tooltip: 'Create Tasks',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    // Show confirmation
                                    showDialog(
                                      context: context,
                                      builder:
                                          (ctx) => AlertDialog(
                                            title: const Text(
                                              'Delete Recording?',
                                            ),
                                            content: const Text(
                                              'This action cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(ctx),
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
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is VoiceError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed:
                                () => context.read<VoiceBloc>().add(
                                  LoadVoiceRecordings(),
                                ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await context.push(AppRouter.voiceRecorder);
                  // Refresh on return
                  if (context.mounted) {
                    context.read<VoiceBloc>().add(LoadVoiceRecordings());
                  }
                },
                child: const Icon(Icons.mic),
              ),
            ),
      ),
    );
  }
}
