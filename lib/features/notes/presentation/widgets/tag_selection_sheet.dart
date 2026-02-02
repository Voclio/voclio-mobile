import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/features/tags/domain/entities/tag_entity.dart';
import 'package:voclio_app/features/tags/presentation/bloc/tags_cubit.dart';
import 'package:voclio_app/features/tags/presentation/bloc/tags_state.dart';

class TagSelectionSheet extends StatefulWidget {
  final List<String> selectedTags;

  const TagSelectionSheet({super.key, required this.selectedTags});

  @override
  State<TagSelectionSheet> createState() => _TagSelectionSheetState();
}

class _TagSelectionSheetState extends State<TagSelectionSheet> {
  late List<String> _tempSelectedTags;
  final TextEditingController _tagController = TextEditingController();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _tempSelectedTags = List.from(widget.selectedTags);
    context.read<TagsCubit>().loadTags();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _toggleTag(String tagName) {
    setState(() {
      if (_tempSelectedTags.contains(tagName)) {
        _tempSelectedTags.remove(tagName);
      } else {
        _tempSelectedTags.add(tagName);
      }
    });
  }

  void _createTag() {
    final name = _tagController.text.trim();
    if (name.isEmpty) return;

    final newTag = TagEntity(
      id: '', // Server generates ID
      name: name,
      color: '#6B46C1', // Default color
      createdAt: DateTime.now(),
    );

    context.read<TagsCubit>().createTag(newTag);
    _tagController.clear();
    setState(() {
      _isCreating = false;
      // Optimistically select the new tag
      if (!_tempSelectedTags.contains(name)) {
        _tempSelectedTags.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24.r,
        24.r,
        24.r,
        MediaQuery.of(context).viewInsets.bottom + 24.r,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Manage Tags",
                style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18.sp),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // 2. Create Tag Input
          if (_isCreating)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Tag name",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onSubmitted: (_) => _createTag(),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: _createTag,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => setState(() => _isCreating = false),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () => setState(() => _isCreating = true),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: theme.colorScheme.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Create New Tag",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 20.h),

          // 3. Tag Cloud
          BlocBuilder<TagsCubit, TagsState>(
            builder: (context, state) {
              if (state is TagsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TagsLoaded) {
                if (state.tags.isEmpty) {
                  return Center(
                    child: Text(
                      "No tags available",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200.h),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children:
                          state.tags.map((tagEntity) {
                            final isSelected = _tempSelectedTags.contains(
                              tagEntity.name,
                            );
                            final tagColor = _parseColor(
                              tagEntity.color,
                              context,
                            );

                            return GestureDetector(
                              onTap: () => _toggleTag(tagEntity.name),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? tagColor
                                          : tagColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? tagColor
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
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                );
              } else if (state is TagsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          SizedBox(height: 32.h),

          // 4. Confirm Button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _tempSelectedTags),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Done",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor, BuildContext context) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
