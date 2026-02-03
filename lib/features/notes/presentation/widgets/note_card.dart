import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/note_entity.dart'; // Adjust path

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Calculate word count for preview
    final wordCount = note.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final isNew = DateTime.now().difference(note.creationDate).inHours < 24;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: isDark
              ? Border.all(color: Colors.white.withOpacity(0.08))
              : Border.all(color: Colors.grey.shade200),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Icon + Title + New Badge
            Row(
              children: [
                // Note Icon with gradient background
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.15),
                        theme.colorScheme.primary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    size: 18.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title.isEmpty ? 'Untitled Note' : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Word count indicator
                      Text(
                        '$wordCount words',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // New badge
                if (isNew)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // 2. Content Preview with styled container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : theme.colorScheme.primary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                note.content.isEmpty ? 'No content' : note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: 13.sp,
                    color: note.content.isEmpty
                        ? theme.colorScheme.onSurface.withOpacity(0.4)
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: note.content.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
            ),

            SizedBox(height: 12.h),

            // 3. Footer: Tags + Time with improved layout
            Row(
              children: [
                // Tags section
                Expanded(
                  child: note.tags.isEmpty
                      ? Text(
                          'No tags',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...note.tags.take(2).map(
                                (tag) => Padding(
                                  padding: EdgeInsets.only(right: 6.w),
                                  child: _buildMiniTag(context, tag),
                                ),
                              ),
                              if (note.tags.length > 2)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    '+${note.tags.length - 2}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
                
                SizedBox(width: 8.w),
                
                // Timestamp with icon
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12.sp,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _timeAgo(note.lastEditDate),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTag(BuildContext context, String tagName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.12),
            theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        tagName,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
