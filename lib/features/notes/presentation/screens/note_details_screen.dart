import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:voclio_app/features/notes/domain/entities/note_entity.dart';
import 'package:voclio_app/features/notes/presentation/bloc/notes_cubit.dart';
import 'package:voclio_app/features/notes/presentation/bloc/note_state.dart';
import 'package:voclio_app/features/tags/presentation/bloc/tags_cubit.dart';
import 'package:voclio_app/core/common/dialogs/voclio_dialog.dart';
import '../widgets/tag_selection_sheet.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteEntity? note; // Null implies "Create New Note"

  const NoteDetailScreen({super.key, this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<String> _selectedTags;
  late NotesCubit cubit;

  bool _isModified = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _selectedTags = List.from(widget.note?.tags ?? []);
    cubit = context.read<NotesCubit>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final content = _contentController.text.trim();
    if (content.isEmpty) return 0;
    return content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  int get _charCount => _contentController.text.length;

  void _saveNote() {
    if (!_isModified) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return; // Don't save empty notes

    final cubit = context.read<NotesCubit>();
    final now = DateTime.now();

    if (widget.note == null) {
      // Create New
      final newNote = NoteEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID gen
        title: title.isEmpty ? 'Untitled Note' : title,
        content: content,
        lastEditDate: now,
        creationDate: now,
        tags: _selectedTags,
        categoryId: 1, // Default category
      );
      cubit.addNote(newNote);
    } else {
      // Update Existing
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        lastEditDate: now,
        tags: _selectedTags,
        categoryId: widget.note!.categoryId ?? 1,
      );
      cubit.updateNote(updatedNote);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    VoclioDialog.showConfirm(
      context: context,
      title: 'Delete Note?',
      message: 'This action cannot be undone. Are you sure you want to delete this note?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () {
        // 1. Close the Dialog
        Navigator.pop(context);

        // 2. Prevent Auto-Save from running when we pop the screen
        _isModified = false;

        // 3. Delete logic
        cubit.deleteNote(widget.note!.id);

        // 4. Close the Detail Screen
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNewNote = widget.note == null;

    // PopScope handles the "Back" button press to trigger Auto-Save
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) _saveNote();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface, size: 20.sp),
            ),
            onPressed: () => Navigator.pop(context), // Triggers PopScope
          ),
          actions: [
            // Save indicator
            if (_isModified)
              Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 14.sp, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text(
                      'Unsaved',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.amber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms),
            IconButton(
              icon: Icon(
                Icons.share_outlined,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () {},
            ),
            if (widget.note != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  _showDeleteConfirmation(context);
                },
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),

                // New note badge
                if (isNewNote)
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.15),
                          theme.colorScheme.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 18.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Creating new note',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0),

                // 1. Title Input with enhanced styling
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(0.03) 
                        : theme.colorScheme.primary.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withOpacity(0.05) 
                          : theme.colorScheme.primary.withOpacity(0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _titleController,
                    onChanged: (_) => setState(() => _isModified = true),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "Note title",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Icon(
                          Icons.title,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                          size: 22.sp,
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(minWidth: 0),
                    ),
                    maxLines: null,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.1, end: 0),

                SizedBox(height: 16.h),

                // 2. Meta Data Section
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(0.03) 
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      // Date info
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.access_time,
                                size: 16.sp,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.note != null
                                        ? "Edited ${_timeAgo(widget.note!.lastEditDate)}"
                                        : "New Note",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (widget.note != null)
                                    Text(
                                      "Created ${_formatDate(widget.note!.creationDate)}",
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider
                      Container(
                        width: 1,
                        height: 36.h,
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                      SizedBox(width: 16.w),
                      
                      // Word/Char count
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.text_fields,
                                size: 14.sp,
                                color: theme.colorScheme.secondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$_wordCount words',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '$_charCount characters',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.1, end: 0),

                SizedBox(height: 20.h),

                // 3. Tags Section Header
                Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 18.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Tags',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedTags.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(left: 8.w),
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '${_selectedTags.length}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms),

                SizedBox(height: 12.h),

                // Tags List
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ..._selectedTags.map((tag) => _buildTagChip(context, tag)),
                    
                    // Add Tag Button
                    BlocBuilder<NotesCubit, NotesState>(
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: () async {
                            final List<String>? result =
                                await showModalBottomSheet<List<String>>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder:
                                      (ctx) => BlocProvider(
                                        create: (_) => GetIt.I<TagsCubit>(),
                                        child: TagSelectionSheet(
                                          selectedTags: _selectedTags,
                                        ),
                                      ),
                                );

                            if (result != null) {
                              setState(() {
                                _selectedTags = result;
                                _isModified = true;
                              });
                              // Also refresh NotesCubit tags so the filter list updates
                              context.read<NotesCubit>().fetchTags();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              color: theme.colorScheme.primary.withOpacity(0.05),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _selectedTags.isEmpty ? Icons.add : Icons.edit,
                                  size: 14.sp,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  _selectedTags.isEmpty ? "Add tags" : "Manage",
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 350.ms),

                SizedBox(height: 24.h),

                // 4. Content Section Header
                Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 18.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Content',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms),

                SizedBox(height: 12.h),

                // 5. Content Area (Enhanced glass-like container)
                Container(
                  constraints: BoxConstraints(minHeight: 350.h),
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.shade200,
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: TextField(
                    controller: _contentController,
                    onChanged: (_) => setState(() => _isModified = true),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      letterSpacing: 0.2,
                    ),
                    decoration: InputDecoration(
                      hintText: "Start writing your note...\n\nTip: Your changes are saved automatically when you leave this screen.",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.secondary.withOpacity(0.4),
                        height: 1.7,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null, // Grows indefinitely
                    keyboardType: TextInputType.multiline,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 450.ms)
                    .slideY(begin: 0.05, end: 0),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String tagName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.12),
            theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.tag,
            size: 12.sp,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 4.w),
          Text(
            tagName,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'Just now';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
