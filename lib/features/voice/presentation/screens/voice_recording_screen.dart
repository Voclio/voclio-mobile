import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:voclio_app/core/di/injection_container.dart';
import '../bloc/voice_bloc.dart';
import '../bloc/voice_state.dart';
import '../bloc/voice_event.dart';
import '../widgets/extraction_preview_sheet.dart';

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

class _VoiceRecordingContentState extends State<_VoiceRecordingContent> {
  bool isRecording = false;
  String transcription = '';
  String? recordingId;
  final TextEditingController _transcriptController = TextEditingController();
  
  AudioRecorder? _audioRecorder;
  int _recordingDuration = 0;

  @override
  void dispose() {
    _audioRecorder?.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      HapticFeedback.mediumImpact();
      _audioRecorder ??= AudioRecorder();

      if (await _audioRecorder!.hasPermission()) {
        final Directory appDocumentsDir =
            await getApplicationDocumentsDirectory();
        final String filePath = p.join(
          appDocumentsDir.path,
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

        setState(() {
          isRecording = true;
          transcription = '';
          recordingId = null;
          _transcriptController.clear();
          _recordingDuration = 0;
        });
        
        _startDurationTimer();
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to start recording: $e');
        setState(() => isRecording = false);
      }
    }
  }

  void _startDurationTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (isRecording && mounted) {
        setState(() => _recordingDuration++);
        return true;
      }
      return false;
    });
  }

  Future<void> _stopRecording() async {
    try {
      HapticFeedback.lightImpact();
      if (_audioRecorder == null || !await _audioRecorder!.isRecording()) {
        setState(() => isRecording = false);
        return;
      }

      final path = await _audioRecorder!.stop();
      setState(() => isRecording = false);

      if (path != null && mounted) {
        context.read<VoiceBloc>().add(UploadVoiceFile(File(path)));
      }
    } catch (e) {
      debugPrint('Error stopping record: $e');
      if (mounted) {
        setState(() => isRecording = false);
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

  void _extractWithAI() {
    if (_transcriptController.text.isNotEmpty) {
      HapticFeedback.mediumImpact();
      context.read<VoiceBloc>().add(
        PreviewExtractionEvent(_transcriptController.text),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<VoiceBloc, VoiceState>(
      listener: (context, state) {
        if (state is VoiceOperationSuccess) {
          _showSuccessSnackBar(state.message);
          Navigator.pop(context);
        } else if (state is VoiceError) {
          _showErrorSnackBar(state.message);
        } else if (state is VoiceTranscriptionLoaded) {
          setState(() {
            transcription = state.transcription;
            recordingId = state.recordingId;
            _transcriptController.text = transcription;
          });
        } else if (state is VoiceExtractionLoaded) {
          _showExtractionPreview(context, state);
        }
      },
      builder: (context, state) {
        final isLoading = state is VoiceLoading;
        final isExtracting = state is VoiceExtractionLoading;
        final isCreating = state is VoiceCreatingFromPreview;
        
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
                  // Recording Duration
                  if (isRecording) _buildRecordingTimer(colors),
                  
                  if (isRecording) SizedBox(height: 30.h),
                  
                  // Main Recording Button
                  _buildRecordingButton(colors, isLoading, isExtracting),
                  
                  SizedBox(height: 30.h),
                  
                  // Status Text
                  _buildStatusText(colors, state),
                  
                  SizedBox(height: 30.h),
                  
                  // Transcription Section
                  if (transcription.isNotEmpty && !isLoading)
                    _buildTranscriptionSection(colors, isExtracting, isCreating),
                ],
              ),
            ),
          ),
          
          // Loading Indicator at bottom
          bottomSheet: (isLoading || isExtracting || isCreating)
              ? _buildLoadingIndicator(colors, state)
              : null,
        );
      },
    );
  }

  Widget _buildRecordingTimer(dynamic colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.r,
            height: 10.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            _formatDuration(_recordingDuration),
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingButton(dynamic colors, bool isLoading, bool isExtracting) {
    return GestureDetector(
      onTap: (isLoading || isExtracting) ? null : _toggleRecording,
      child: Container(
        width: 160.r,
        height: 160.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isRecording
                ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                : [colors.primary!, colors.primary!.withValues(alpha: 0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: (isRecording ? const Color(0xFFEF4444) : colors.primary!)
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 45.r,
                  height: 45.r,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 60.sp,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  Widget _buildStatusText(dynamic colors, VoiceState state) {
    String text;
    if (isRecording) {
      text = 'Recording...';
    } else if (state is VoiceLoading) {
      text = state.message;
    } else if (state is VoiceExtractionLoading) {
      text = state.message;
    } else if (transcription.isNotEmpty) {
      text = 'Tap "Extract with AI" to generate tasks & notes';
    } else {
      text = 'Tap to start recording';
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: context.textStyle.copyWith(
        fontSize: 16.sp,
        color: colors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTranscriptionSection(dynamic colors, bool isExtracting, bool isCreating) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields_rounded,
                color: colors.primary,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'Transcription',
                style: context.textStyle.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Editable Transcription
          TextField(
            controller: _transcriptController,
            maxLines: 5,
            style: context.textStyle.copyWith(
              fontSize: 15.sp,
              color: colors.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Edit your transcription...',
              hintStyle: context.textStyle.copyWith(
                color: colors.grey?.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: colors.primary!, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
          SizedBox(height: 20.h),
          
          // AI Extract Button
          GestureDetector(
            onTap: (isExtracting || isCreating) ? null : _extractWithAI,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.primary!, const Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary!.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Extract with AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(dynamic colors, VoiceState state) {
    String message = 'Processing...';
    if (state is VoiceLoading) {
      message = state.message;
    } else if (state is VoiceExtractionLoading) {
      message = state.message;
    } else if (state is VoiceCreatingFromPreview) {
      message = state.message;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.r,
              height: 20.r,
              child: CircularProgressIndicator(
                color: colors.primary,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              message,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExtractionPreview(BuildContext context, VoiceExtractionLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<VoiceBloc>(),
        child: ExtractionPreviewSheet(
          extraction: state.extraction,
          transcription: state.transcription,
        ),
      ),
    );
  }
}
