import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:voclio_app/core/icons/app_icons.dart';
import 'package:voclio_app/core/layout/main_layout.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/features/notes/domain/usecases/ai_usecases.dart';

enum _AiPhase { choose, loading, result, error }

enum _AiActionKind { summarize, extract }

class AiActionsDialog extends StatefulWidget {
  final String noteId;
  final String noteContent;

  const AiActionsDialog({
    super.key,
    required this.noteId,
    required this.noteContent,
  });

  static Future<void> show(
    BuildContext context, {
    required String noteId,
    required String noteContent,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => AiActionsDialog(
        noteId: noteId,
        noteContent: noteContent,
      ),
    );
  }

  @override
  State<AiActionsDialog> createState() => _AiActionsDialogState();
}

class _AiActionsDialogState extends State<AiActionsDialog> {
  _AiPhase _phase = _AiPhase.choose;
  _AiActionKind? _activeAction;
  String? _resultTitle;
  String? _resultBody;
  String? _error;
  int _extractedTaskCount = 0;

  bool get _isBusy => _phase == _AiPhase.loading;

  Future<void> _performAction(_AiActionKind action) async {
    if (_isBusy) return;

    setState(() {
      _phase = _AiPhase.loading;
      _activeAction = action;
      _error = null;
      _resultTitle = null;
      _resultBody = null;
      _extractedTaskCount = 0;
    });

    try {
      if (action == _AiActionKind.summarize) {
        final result = await GetIt.I<SummarizeNoteUseCase>()(widget.noteId);
        if (!mounted) return;
        result.fold(
          (failure) => _showError(failure.message),
          (summary) => _showResult(
            title: 'Summary',
            body: summary.trim().isEmpty
                ? 'No summary could be generated for this note.'
                : summary.trim(),
          ),
        );
      } else {
        final result = await GetIt.I<ExtractTasksFromNoteUseCase>()(
          widget.noteId,
          autoCreate: true,
        );
        if (!mounted) return;
        result.fold(
          (failure) => _showError(failure.message),
          (tasks) {
            if (tasks.isEmpty) {
              _showResult(
                title: 'No tasks found',
                body:
                    'We could not find actionable items in this note. Try adding clearer action lines.',
              );
              return;
            }
            _extractedTaskCount = tasks.length;
            _showResult(
              title: '${tasks.length} task${tasks.length == 1 ? '' : 's'} created',
              body: tasks.map((t) => '• $t').join('\n'),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Something went wrong. Please try again.');
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _phase = _AiPhase.error;
      _error = message;
    });
  }

  void _showResult({required String title, required String body}) {
    setState(() {
      _phase = _AiPhase.result;
      _resultTitle = title;
      _resultBody = body;
    });
  }

  void _resetToChoose() {
    setState(() {
      _phase = _AiPhase.choose;
      _activeAction = null;
      _error = null;
      _resultTitle = null;
      _resultBody = null;
      _extractedTaskCount = 0;
    });
  }

  void _copyResult() {
    final text = _resultBody;
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: !_isBusy,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h + bottomSafe),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          ),
          decoration: HomeSystemTokens.cardDecoration().copyWith(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: HomeSystemTokens.inkMuted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: HomeSystemTokens.purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        AppIcons.auto_awesome,
                        color: HomeSystemTokens.purple,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Actions',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: HomeSystemTokens.ink,
                            ),
                          ),
                          Text(
                            'Powered by your note content',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: HomeSystemTokens.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _isBusy ? null : () => Navigator.pop(context),
                      icon: Icon(
                        AppIcons.close,
                        color: HomeSystemTokens.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _buildPhaseBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseBody() {
    return switch (_phase) {
      _AiPhase.choose => _buildChooseView(key: const ValueKey('choose')),
      _AiPhase.loading => _buildLoadingView(key: const ValueKey('loading')),
      _AiPhase.result => _buildResultView(key: const ValueKey('result')),
      _AiPhase.error => _buildErrorView(key: const ValueKey('error')),
    };
  }

  Widget _buildChooseView({required Key key}) {
    return SingleChildScrollView(
      key: key,
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        children: [
          _ActionTile(
            icon: AppIcons.summarize,
            title: 'Summarize Note',
            description: 'Get a short, readable summary',
            accent: HomeSystemTokens.purple,
            onTap: () => _performAction(_AiActionKind.summarize),
          ),
          SizedBox(height: 12.h),
          _ActionTile(
            icon: AppIcons.task_alt,
            title: 'Extract Tasks',
            description: 'Find action items and add them as tasks',
            accent: HomeSystemTokens.blue,
            onTap: () => _performAction(_AiActionKind.extract),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView({required Key key}) {
    final label = _activeAction == _AiActionKind.extract
        ? 'Extracting tasks...'
        : 'Summarizing your note...';

    return Padding(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44.w,
            height: 44.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: HomeSystemTokens.purple,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: HomeSystemTokens.ink,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This usually takes a few seconds',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: HomeSystemTokens.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView({required Key key}) {
    return SingleChildScrollView(
      key: key,
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: (_extractedTaskCount > 0
                      ? HomeSystemTokens.green
                      : HomeSystemTokens.purple)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: (_extractedTaskCount > 0
                        ? HomeSystemTokens.green
                        : HomeSystemTokens.purple)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _extractedTaskCount > 0
                          ? AppIcons.check_circle
                          : AppIcons.auto_awesome,
                      color: _extractedTaskCount > 0
                          ? HomeSystemTokens.green
                          : HomeSystemTokens.purple,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _resultTitle ?? 'Result',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: HomeSystemTokens.ink,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _copyResult,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 20.sp,
                        color: HomeSystemTokens.inkSoft,
                      ),
                      tooltip: 'Copy',
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  _resultBody ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: HomeSystemTokens.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (_extractedTaskCount > 0)
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  MainLayout.goToTab(1);
                },
                icon: Icon(AppIcons.task_alt, size: 18.sp),
                label: const Text('View Tasks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeSystemTokens.purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          if (_extractedTaskCount > 0) SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetToChoose,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(46.h),
                    foregroundColor: HomeSystemTokens.inkSoft,
                    side: BorderSide(
                      color: HomeSystemTokens.inkMuted.withValues(alpha: 0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('Another action'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(46.h),
                    backgroundColor: HomeSystemTokens.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView({required Key key}) {
    return Padding(
      key: key,
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: HomeSystemTokens.coral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  AppIcons.error_outline_rounded,
                  color: HomeSystemTokens.coral,
                  size: 22.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _error ?? 'Request failed',
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: HomeSystemTokens.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _resetToChoose,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeSystemTokens.purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: const Text('Try again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          decoration: BoxDecoration(
            color: HomeSystemTokens.canvas,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: accent.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, color: accent, size: 24.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: HomeSystemTokens.ink,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: HomeSystemTokens.inkSoft,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.chevron_right,
                  color: HomeSystemTokens.inkMuted,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
