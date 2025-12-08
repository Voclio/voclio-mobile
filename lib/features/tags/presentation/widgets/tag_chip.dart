import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/tag_entity.dart';

class TagChipWidget extends StatelessWidget {
  final TagEntity tag;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TagChipWidget({
    super.key,
    required this.tag,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(tag.name),
        backgroundColor: Color(
          int.parse(tag.color.replaceFirst('#', '0xFF')),
        ).withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: Color(
            int.parse(tag.color.replaceFirst('#', '0xFF')),
          ),
          fontSize: 12.sp,
        ),
        deleteIcon: onDelete != null ? const Icon(Icons.close, size: 16) : null,
        onDeleted: onDelete,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      ),
    );
  }
}
