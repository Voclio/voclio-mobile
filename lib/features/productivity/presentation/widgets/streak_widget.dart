import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/productivity_entities.dart';

class StreakWidget extends StatelessWidget {
  final StreakEntity streak;

  const StreakWidget({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreakColumn(
                  '🔥',
                  'Current Streak',
                  '${streak.currentStreak} days',
                  Colors.orange,
                ),
                Container(width: 1, height: 60.h, color: Colors.grey[300]),
                _buildStreakColumn(
                  '🏆',
                  'Longest Streak',
                  '${streak.longestStreak} days',
                  Colors.amber,
                ),
              ],
            ),
            if (streak.lastActivityDate != null) ...[
              SizedBox(height: 16.h),
              Text(
                'Last activity: ${_formatDate(streak.lastActivityDate!)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakColumn(
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 32.sp)),
        SizedBox(height: 8.h),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
