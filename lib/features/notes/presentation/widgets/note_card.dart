import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import '../../domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  static const _accents = [
    HomeSystemTokens.purple,
    HomeSystemTokens.blue,
    HomeSystemTokens.orange,
    HomeSystemTokens.green,
  ];

  @override
  Widget build(BuildContext context) {
    final wordCount =
        note.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final isNew = DateTime.now().difference(note.creationDate).inHours < 24;
    final accent = _accents[note.title.hashCode.abs() % _accents.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: HomeSystemTokens.cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isEmpty ? 'Untitled Note' : note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: HomeSystemTokens.ink,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: HomeSystemTokens.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: HomeSystemTokens.green,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    note.content.isEmpty ? 'No content yet' : note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.45,
                      color: note.content.isEmpty
                          ? HomeSystemTokens.inkMuted
                          : HomeSystemTokens.inkSoft,
                      fontStyle:
                          note.content.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      if (note.tags.isNotEmpty)
                        ...note.tags.take(2).map(
                              (tag) => Padding(
                                padding: EdgeInsets.only(right: 6.w),
                                child: _TagPill(label: tag, color: accent),
                              ),
                            )
                      else
                        Text(
                          'No tags',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: HomeSystemTokens.inkMuted,
                          ),
                        ),
                      const Spacer(),
                      Icon(
                        Icons.notes_rounded,
                        size: 13.sp,
                        color: HomeSystemTokens.inkMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$wordCount words',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: HomeSystemTokens.inkMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        _timeAgo(note.lastEditDate),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: HomeSystemTokens.inkMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color color;

  const _TagPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
