import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiActionsDialog extends StatefulWidget {
  final String noteId;
  final String noteContent;

  const AiActionsDialog({
    super.key,
    required this.noteId,
    required this.noteContent,
  });

  @override
  State<AiActionsDialog> createState() => _AiActionsDialogState();
}

class _AiActionsDialogState extends State<AiActionsDialog> {
  bool _isLoading = false;
  String? _result;
  String _selectedAction = '';

  Future<void> _performAction(String action) async {
    setState(() {
      _isLoading = true;
      _selectedAction = action;
      _result = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (action == 'summarize') {
      setState(() {
        _result =
            'AI Summary:\n\nThis note discusses the key aspects of productivity and time management. The main points include setting clear goals, prioritizing tasks, and maintaining focus through dedicated work sessions.';
        _isLoading = false;
      });
    } else if (action == 'extract') {
      setState(() {
        _result =
            'Extracted Tasks:\n\n• Complete project report by Friday\n• Schedule team meeting for next week\n• Review and update documentation\n• Follow up with client emails';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        constraints: BoxConstraints(maxHeight: 500.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'AI Actions',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            if (_result == null) ...[
              _buildActionButton(
                icon: Icons.summarize,
                title: 'Summarize Note',
                description: 'Get a concise summary of your note',
                onTap: () => _performAction('summarize'),
              ),
              SizedBox(height: 12.h),
              _buildActionButton(
                icon: Icons.task_alt,
                title: 'Extract Tasks',
                description: 'Find actionable items in your note',
                onTap: () => _performAction('extract'),
              ),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(_result!, style: TextStyle(fontSize: 14.sp)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _result = null;
                          _selectedAction = '';
                        });
                      },
                      child: const Text('Back'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Copy to clipboard or save
                        Navigator.pop(context);
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
            if (_isLoading) ...[
              SizedBox(height: 20.h),
              const Center(child: CircularProgressIndicator()),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  'Processing with Gemini AI...',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: Colors.purple, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
