import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import '../../domain/entities/voice_extraction.dart';
import '../bloc/voice_bloc.dart';
import '../bloc/voice_event.dart';

class EditExtractedNoteSheet extends StatefulWidget {
  final ExtractedNote note;

  const EditExtractedNoteSheet({super.key, required this.note});

  @override
  State<EditExtractedNoteSheet> createState() => _EditExtractedNoteSheetState();
}

class _EditExtractedNoteSheetState extends State<EditExtractedNoteSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _tagController = TextEditingController();
    _tags = List.from(widget.note.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
      HapticFeedback.selectionClick();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    HapticFeedback.lightImpact();
  }

  void _saveChanges() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Title cannot be empty'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updatedNote = widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      tags: _tags,
    );

    context.read<VoiceBloc>().add(UpdateExtractedNote(updatedNote));
    Navigator.pop(context);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: const Color(0xFF10B981),
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    'Edit Note',
                    style: context.textStyle.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
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
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  _buildLabel('Title', colors),
                  _buildTextField(
                    controller: _titleController,
                    hint: 'Note title',
                    icon: Icons.title_rounded,
                    colors: colors,
                  ),
                  SizedBox(height: 20.h),

                  // Content Field
                  _buildLabel('Content', colors),
                  _buildTextField(
                    controller: _contentController,
                    hint: 'Write your note content...',
                    icon: Icons.notes_rounded,
                    maxLines: 6,
                    colors: colors,
                  ),
                  SizedBox(height: 20.h),

                  // Tags Section
                  _buildLabel('Tags', colors),
                  _buildTagInput(colors),
                  SizedBox(height: 12.h),
                  _buildTagsList(colors),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),

          // Save Button
          Padding(
            padding: EdgeInsets.all(24.w),
            child: SafeArea(
              child: GestureDetector(
                onTap: _saveChanges,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 22.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'Save Changes',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, dynamic colors) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          color: colors.grey,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required dynamic colors,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: context.textStyle.copyWith(
        fontSize: 15.sp,
        color: colors.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: colors.grey?.withValues(alpha: 0.5),
          fontSize: 15.sp,
        ),
        prefixIcon: maxLines == 1
            ? Icon(
                icon,
                color: colors.grey,
                size: 22.sp,
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
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
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildTagInput(dynamic colors) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _tagController,
            style: context.textStyle.copyWith(
              fontSize: 15.sp,
              color: colors.textPrimary,
            ),
            onSubmitted: (_) => _addTag(),
            decoration: InputDecoration(
              hintText: 'Add a tag...',
              hintStyle: TextStyle(
                color: colors.grey?.withValues(alpha: 0.5),
                fontSize: 15.sp,
              ),
              prefixIcon: Icon(
                Icons.tag,
                color: colors.grey,
                size: 22.sp,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
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
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: _addTag,
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsList(dynamic colors) {
    if (_tags.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          'No tags added yet',
          style: TextStyle(
            color: colors.grey?.withValues(alpha: 0.5),
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#$tag',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => _removeTag(tag),
                child: Icon(
                  Icons.close,
                  color: const Color(0xFF10B981),
                  size: 16.sp,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
