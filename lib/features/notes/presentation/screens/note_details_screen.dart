import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context), // Triggers PopScope
          ),
          actions: [
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

                // 1. Title Input
                TextField(
                  controller: _titleController,
                  onChanged: (_) => _isModified = true,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: TextStyle(
                      color: theme.colorScheme.secondary.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                ),

                // 2. Meta Data (Time)
                SizedBox(height: 8.h),
                Text(
                  widget.note != null
                      ? "Edited ${_timeAgo(widget.note!.lastEditDate)}"
                      : "New Note",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),

                SizedBox(height: 20.h),

                // 3. Tags List
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ..._selectedTags.map((tag) => _buildTagChip(context, tag)),
                    // ... inside Wrap ...

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
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 14.sp,
                                  color: theme.colorScheme.secondary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "Manage tags",
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // 4. Content Area (Glass-like container for Dark Mode)
                Container(
                  constraints: BoxConstraints(minHeight: 400.h),
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    border:
                        isDark
                            ? Border.all(color: Colors.white.withOpacity(0.05))
                            : null,
                  ),
                  child: TextField(
                    controller: _contentController,
                    onChanged: (_) => _isModified = true,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6, // Better readability
                    ),
                    decoration: InputDecoration(
                      hintText: "Start typing...",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null, // Grows indefinitely
                    keyboardType: TextInputType.multiline,
                  ),
                ),

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

    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: theme.colorScheme.primary.withOpacity(
        isDark ? 0.2 : 0.1,
      ),
      label: Text(
        tagName,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }

  String _timeAgo(DateTime date) {
    // Reusing the logic from Dashboard
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'Just now';
  }
}
