import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../domain/entities/voice_extraction.dart';
import '../bloc/voice_bloc.dart';
import '../bloc/voice_event.dart';
import '../bloc/voice_state.dart';
import 'edit_extracted_task_sheet.dart';
import 'edit_extracted_note_sheet.dart';

class ExtractionPreviewSheet extends StatefulWidget {
  final VoiceExtraction extraction;
  final String transcription;

  const ExtractionPreviewSheet({
    super.key,
    required this.extraction,
    required this.transcription,
  });

  @override
  State<ExtractionPreviewSheet> createState() => _ExtractionPreviewSheetState();
}

class _ExtractionPreviewSheetState extends State<ExtractionPreviewSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<VoiceBloc, VoiceState>(
      listener: (context, state) {
        if (state is VoiceOperationSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final extraction = state is VoiceExtractionLoaded 
            ? state.extraction 
            : widget.extraction;
        final isCreating = state is VoiceCreatingFromPreview;

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Header
              _buildHeader(context, extraction, colors),
              
              // Tab Bar
              _buildTabBar(colors),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTasksList(context, extraction.tasks, colors),
                    _buildNotesList(context, extraction.notes, colors),
                  ],
                ),
              ),
              
              // Bottom Action
              _buildBottomAction(context, extraction, isCreating, colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, VoiceExtraction extraction, dynamic colors) {
    final taskCount = extraction.tasks.where((t) => t.isSelected).length;
    final noteCount = extraction.notes.where((n) => n.isSelected).length;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary!, const Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Extraction Preview',
                      style: context.textStyle.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$taskCount tasks • $noteCount notes selected',
                      style: context.textStyle.copyWith(
                        fontSize: 14.sp,
                        color: colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: colors.grey,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(dynamic colors) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(4.r),
        labelColor: Colors.white,
        unselectedLabelColor: colors.grey,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt_rounded, size: 18.sp),
                SizedBox(width: 8.w),
                const Text('Tasks'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_rounded, size: 18.sp),
                SizedBox(width: 8.w),
                const Text('Notes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List<ExtractedTask> tasks, dynamic colors) {
    if (tasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.task_alt_rounded,
        title: 'No Tasks Found',
        subtitle: 'AI couldn\'t extract any tasks from your voice',
        colors: colors,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(context, task, index, colors);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, ExtractedTask task, int index, dynamic colors) {
    final priorityColor = _getPriorityColor(task.priority);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: task.isSelected 
            ? colors.primary.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: task.isSelected 
              ? colors.primary.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: task.isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditTaskSheet(context, task),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Selection Checkbox
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<VoiceBloc>().add(ToggleTaskSelection(task.id));
                  },
                  child: Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isSelected ? colors.primary : Colors.transparent,
                      border: task.isSelected
                          ? null
                          : Border.all(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                    ),
                    child: task.isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : null,
                  ),
                ),
                SizedBox(width: 16.w),
                
                // Task Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: context.textStyle.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: task.isSelected 
                              ? colors.textPrimary 
                              : colors.grey,
                          decoration: task.isSelected 
                              ? null 
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyle.copyWith(
                            fontSize: 13.sp,
                            color: colors.grey,
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          // Priority Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              task.priority.toUpperCase(),
                              style: TextStyle(
                                color: priorityColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (task.dueDate != null) ...[
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14.sp,
                              color: colors.grey,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatDate(task.dueDate!),
                              style: TextStyle(
                                color: colors.grey,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Edit Button
                IconButton(
                  onPressed: () => _showEditTaskSheet(context, task),
                  icon: Icon(
                    Icons.edit_rounded,
                    color: colors.grey,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<ExtractedNote> notes, dynamic colors) {
    if (notes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.note_rounded,
        title: 'No Notes Found',
        subtitle: 'AI couldn\'t extract any notes from your voice',
        colors: colors,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(24.w),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(context, note, index, colors);
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, ExtractedNote note, int index, dynamic colors) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: note.isSelected 
            ? const Color(0xFF10B981).withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: note.isSelected 
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: note.isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditNoteSheet(context, note),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Selection Checkbox
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<VoiceBloc>().add(ToggleNoteSelection(note.id));
                  },
                  child: Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: note.isSelected 
                          ? const Color(0xFF10B981) 
                          : Colors.transparent,
                      border: note.isSelected
                          ? null
                          : Border.all(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                    ),
                    child: note.isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : null,
                  ),
                ),
                SizedBox(width: 16.w),
                
                // Note Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: context.textStyle.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: note.isSelected 
                              ? colors.textPrimary 
                              : colors.grey,
                          decoration: note.isSelected 
                              ? null 
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        note.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyle.copyWith(
                          fontSize: 13.sp,
                          color: colors.grey,
                          height: 1.4,
                        ),
                      ),
                      if (note.tags.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: note.tags.map((tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                color: const Color(0xFF10B981),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Edit Button
                IconButton(
                  onPressed: () => _showEditNoteSheet(context, note),
                  icon: Icon(
                    Icons.edit_rounded,
                    color: colors.grey,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required dynamic colors,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48.sp,
              color: colors.grey,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.grey,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    VoiceExtraction extraction,
    bool isCreating,
    dynamic colors,
  ) {
    final selectedTasks = extraction.tasks.where((t) => t.isSelected).toList();
    final selectedNotes = extraction.notes.where((n) => n.isSelected).toList();
    final hasSelection = selectedTasks.isNotEmpty || selectedNotes.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: hasSelection && !isCreating
              ? () {
                  HapticFeedback.mediumImpact();
                  context.read<VoiceBloc>().add(CreateFromPreviewEvent(
                    tasks: extraction.tasks,
                    notes: extraction.notes,
                  ));
                }
              : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              gradient: hasSelection
                  ? LinearGradient(
                      colors: [colors.primary!, const Color(0xFF8B5CF6)],
                    )
                  : null,
              color: hasSelection ? null : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: hasSelection
                  ? [
                      BoxShadow(
                        color: colors.primary!.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCreating) ...[
                  SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Icon(
                  hasSelection ? Icons.check_circle_rounded : Icons.block,
                  color: hasSelection 
                      ? Colors.white 
                      : colors.grey,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  isCreating
                      ? 'Creating...'
                      : hasSelection
                          ? 'Create ${selectedTasks.length} Tasks & ${selectedNotes.length} Notes'
                          : 'Select items to create',
                  style: TextStyle(
                    color: hasSelection 
                        ? Colors.white 
                        : colors.grey,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditTaskSheet(BuildContext context, ExtractedTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<VoiceBloc>(),
        child: EditExtractedTaskSheet(task: task),
      ),
    );
  }

  void _showEditNoteSheet(BuildContext context, ExtractedNote note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<VoiceBloc>(),
        child: EditExtractedNoteSheet(note: note),
      ),
    );
  }
}
