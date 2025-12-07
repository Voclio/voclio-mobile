import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceRecorderScreen extends StatefulWidget {
  const VoiceRecorderScreen({super.key});

  @override
  State<VoiceRecorderScreen> createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends State<VoiceRecorderScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _transcription;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      // Simulate transcription
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _isProcessing = false;
        _transcription =
            'This is a sample transcription of your voice recording. You can now create a note or task from this text.';
      });
    } else {
      setState(() {
        _isRecording = true;
        _transcription = null;
      });
    }
  }

  Future<void> _createNote() async {
    // TODO: Implement create note from transcription
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note created successfully')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _createTask() async {
    // TODO: Implement create task from transcription
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Recorder')),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              const CircularProgressIndicator(),
              SizedBox(height: 24.h),
              Text(
                'Transcribing...',
                style: TextStyle(fontSize: 18.sp, color: Colors.grey),
              ),
            ] else if (_transcription != null) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Transcription:',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _transcription!,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: _createNote,
                        icon: const Icon(Icons.note_add),
                        label: const Text('Create Note'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      OutlinedButton.icon(
                        onPressed: _createTask,
                        icon: const Icon(Icons.task_alt),
                        label: const Text('Create Task'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () {
                          setState(() => _transcription = null);
                        },
                        child: const Text('Record Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width:
                        200.w +
                        (_isRecording ? _animationController.value * 40 : 0),
                    height:
                        200.h +
                        (_isRecording ? _animationController.value * 40 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _isRecording
                              ? Colors.red.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Container(
                        width: 160.w,
                        height: 160.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.blue,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 80.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 48.h),
              Text(
                _isRecording
                    ? 'Recording... Tap to stop'
                    : 'Tap to start recording',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              ElevatedButton(
                onPressed: _toggleRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: 48.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  _isRecording ? 'Stop Recording' : 'Start Recording',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
