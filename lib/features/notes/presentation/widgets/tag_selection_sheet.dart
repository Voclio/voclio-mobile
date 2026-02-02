import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/domain/entities/tag_entity.dart';

class TagSelectionSheet extends StatefulWidget {
  final List<String> selectedTags;
  final List<TagEntity> availableTags;

  const TagSelectionSheet({
    super.key,
    required this.selectedTags,
    required this.availableTags,
  });

  @override
  State<TagSelectionSheet> createState() => _TagSelectionSheetState();
}

class _TagSelectionSheetState extends State<TagSelectionSheet> {
  // We create a local copy to modify, so we don't change the parent state until "Done" is clicked
  late List<String> _tempSelectedTags;

  @override
  void initState() {
    super.initState();
    _tempSelectedTags = List.from(widget.selectedTags);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content
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
                onPressed: () => Navigator.pop(context), // Close without saving
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // 2. Tag Cloud
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children:
                widget.availableTags.map((tagEntity) {
                  final isSelected = _tempSelectedTags.contains(tagEntity.name);
                  final tagColor = _parseColor(tagEntity.color, context);

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
                            isSelected ? tagColor : tagColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? tagColor
                                  : theme.colorScheme.secondary.withOpacity(
                                    0.3,
                                  ),
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
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          SizedBox(height: 32.h),

          // 3. Confirm Button
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
                "Apply Tags",
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
