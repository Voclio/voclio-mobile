import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/notes_cubit.dart';
import 'tag_selection_sheet.dart';
import 'package:voclio_app/features/tags/presentation/bloc/tags_cubit.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class AddNoteBottomSheet extends StatefulWidget {
  const AddNoteBottomSheet({super.key});

  @override
  State<AddNoteBottomSheet> createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends State<AddNoteBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  // Selected tag names (strings)
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    context.read<NotesCubit>().fetchTags();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _createNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Basic validation: Don't create empty notes
    if (title.isEmpty && content.isEmpty) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    //
    // 1. Unfocus keyboard safely
    FocusManager.instance.primaryFocus?.unfocus();

    final newNote = NoteEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Untitled Note' : title,
      content: content,
      lastEditDate: DateTime.now(),
      creationDate: DateTime.now(),
      tags: _selectedTags,
      categoryId: 1, // Default category as per API requirements
    );

    // 2. Capture Cubit
    final cubit = context.read<NotesCubit>();

    // 3. Robust Pop Logic (Wait for layout to settle)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cubit.addNote(newNote);
        Navigator.pop(context);
      }
    });
  }

  Future<void> _openTagSelector() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider(
        create: (_) => GetIt.I<TagsCubit>(),
        child: TagSelectionSheet(selectedTags: _selectedTags),
      ),
    );

    if (result != null && mounted) {
      setState(() => _selectedTags = result);
      context.read<NotesCubit>().fetchTags();
    }
  }

  void _toggleTag(String tagName) {
    setState(() {
      if (_selectedTags.contains(tagName)) {
        _selectedTags.remove(tagName);
      } else {
        _selectedTags.add(tagName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          physics:
              bottomInset > 0
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "New Note",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        AppIcons.close,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // 1. Title
                  Text(
                    "Title",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _titleController,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter note title",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 2. Tags Selector
                  Text(
                    "Tags",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      ..._selectedTags.map(
                        (tag) => _buildSelectedTagChip(context, tag),
                      ),
                      GestureDetector(
                        onTap: _openTagSelector,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.35),
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            color: theme.colorScheme.primary.withOpacity(0.06),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedTags.isEmpty
                                    ? AppIcons.add
                                    : AppIcons.edit,
                                size: 14.sp,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                _selectedTags.isEmpty
                                    ? 'Add tags'
                                    : 'Manage tags',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedTags.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'No tags yet. Tap "Add tags" to create or select categories.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          height: 1.4,
                        ),
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // 3. Content
                  Text(
                    "Content",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    decoration: InputDecoration(
                      hintText: "Write your thoughts...",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h + bottomSafe),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _createNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isSubmitting
                            ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              "Create Note",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTagChip(BuildContext context, String tagName) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _toggleTag(tagName),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tagName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(AppIcons.close, size: 12.sp, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
