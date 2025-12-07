import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/enums.dart';

class TagSelectionSheet extends StatefulWidget {
  final List<AppTag> selectedTags;

  const TagSelectionSheet({super.key, required this.selectedTags});

  @override
  State<TagSelectionSheet> createState() => _TagSelectionSheetState();
}

class _TagSelectionSheetState extends State<TagSelectionSheet> {
  // We create a local copy to modify, so we don't change the parent state until "Done" is clicked
  late List<AppTag> _tempSelectedTags;

  @override
  void initState() {
    super.initState();
    _tempSelectedTags = List.from(widget.selectedTags);
  }

  void _toggleTag(AppTag tag) {
    setState(() {
      if (_tempSelectedTags.contains(tag)) {
        _tempSelectedTags.remove(tag);
      } else {
        _tempSelectedTags.add(tag);
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
                AppTag.values.map((tag) {
                  if (tag == AppTag.all)
                    return const SizedBox.shrink(); // Skip 'All'

                  final isSelected = _tempSelectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => _toggleTag(tag),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark
                                      ? Colors.white10
                                      : Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        tag.label,
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

          SizedBox(height: 30.h),

          // 3. Done Button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                // Return the new list to the previous screen
                Navigator.pop(context, _tempSelectedTags);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                "Done",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
