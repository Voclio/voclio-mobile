import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/tag_entity.dart';

class TagItem extends StatelessWidget {
  final TagEntity tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TagItem({
    super.key,
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(
          int.parse(colorString.substring(1), radix: 16) + 0xFF000000,
        );
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(tag.color);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.label, color: Colors.white, size: 24.sp),
        ),
        title: Text(
          tag.name,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Color: ${tag.color}',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}
