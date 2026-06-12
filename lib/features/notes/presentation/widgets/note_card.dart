import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import '../../domain/entities/note_entity.dart';
import 'package:voclio_app/core/icons/app_icons.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final bool compact;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.compact = false,
  });

  static const _accents = [
    HomeSystemTokens.purple,
    HomeSystemTokens.blue,
    HomeSystemTokens.orange,
    HomeSystemTokens.green,
  ];

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildListCard(BuildContext context) {
    final wordCount = _wordCount;
    final isNew = _isNew;
    final accent = _accent;

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
                          _title,
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
                      if (isNew) _newBadge(accent),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.45,
                      color: note.content.isEmpty
                          ? HomeSystemTokens.inkMuted
                          : HomeSystemTokens.inkSoft,
                      fontStyle: note.content.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(child: _tagsRow(accent)),
                      Icon(
                        AppIcons.notes_rounded,
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

  Widget _buildCompactCard(BuildContext context) {
    final wordCount = _wordCount;
    final accent = _accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: HomeSystemTokens.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: HomeSystemTokens.ink,
                    ),
                  ),
                ),
                if (_isNew) _newBadge(accent),
              ],
            ),
            SizedBox(height: 6.h),
            Expanded(
              child: Text(
                _preview,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  color: note.content.isEmpty
                      ? HomeSystemTokens.inkMuted
                      : HomeSystemTokens.inkSoft,
                  fontStyle:
                      note.content.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            if (note.tags.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _tagsRow(accent, maxTags: 1),
            ],
            SizedBox(height: 8.h),
            Text(
              '$wordCount words · ${_timeAgo(note.lastEditDate)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                color: HomeSystemTokens.inkMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newBadge(Color accent) {
    return Container(
      margin: EdgeInsets.only(left: 6.w),
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: HomeSystemTokens.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w800,
          color: HomeSystemTokens.green,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _tagsRow(Color accent, {int maxTags = 2}) {
    if (note.tags.isEmpty) {
      return Text(
        'No tags',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.sp,
          color: HomeSystemTokens.inkMuted,
        ),
      );
    }

    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: note.tags.take(maxTags).map((tag) {
        return _TagPill(label: tag, color: accent);
      }).toList(),
    );
  }

  String get _title => note.title.isEmpty ? 'Untitled Note' : note.title;

  String get _preview =>
      note.content.isEmpty ? 'No content yet' : note.content;

  int get _wordCount =>
      note.content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  bool get _isNew => DateTime.now().difference(note.creationDate).inHours < 24;

  Color get _accent => _accents[note.title.hashCode.abs() % _accents.length];

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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
