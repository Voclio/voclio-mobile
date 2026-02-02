import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/notes_cubit.dart';
import '../bloc/note_state.dart';

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

  void _toggleTag(String tagName) {
    setState(() {
      if (_selectedTags.contains(tagName)) {
        _selectedTags.remove(tagName);
      } else {
        _selectedTags.add(tagName);
      }
    });
  }

  // Parse hex color string to Color
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Theme.of(context).colorScheme.primary; // Fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate keyboard height padding
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: 0.85.sh, // 85% screen height
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // --- HEADER ---
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
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
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.colorScheme.onSurface.withOpacity(0.1),
          ),

          // --- FORM CONTENT ---
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              // Pad the bottom so content scrolls up above keyboard
              padding: EdgeInsets.fromLTRB(
                20.r,
                20.r,
                20.r,
                20.r + bottomInset,
              ),
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
                  BlocBuilder<NotesCubit, NotesState>(
                    builder: (context, state) {
                      return Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children:
                            state.availableTags.map((tagEntity) {
                              final isSelected = _selectedTags.contains(
                                tagEntity.name,
                              );
                              return GestureDetector(
                                onTap: () => _toggleTag(tagEntity.name),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? _parseColor(tagEntity.color)
                                            : (isDark
                                                ? Colors.white.withOpacity(0.05)
                                                : Colors.transparent),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? _parseColor(tagEntity.color)
                                              : theme.colorScheme.secondary
                                                  .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    tagEntity.name,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                      fontSize: 12.sp,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
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
                    maxLines: 8, // Taller area for notes
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

                  SizedBox(height: 30.h),

                  // 4. Create Button
                  SizedBox(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
