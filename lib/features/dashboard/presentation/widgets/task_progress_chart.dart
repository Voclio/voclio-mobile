import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskProgressChart extends StatelessWidget {
  final double completionRate;

  const TaskProgressChart({super.key, required this.completionRate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Completion Rate',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150.h,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 150.h,
                              width: 150.w,
                              child: CircularProgressIndicator(
                                value: completionRate / 100,
                                strokeWidth: 12.w,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getColorForRate(completionRate),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${completionRate.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _getColorForRate(completionRate),
                                  ),
                                ),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
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
              ],
            ),
            SizedBox(height: 16.h),
            LinearProgressIndicator(
              value: completionRate / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForRate(completionRate),
              ),
              minHeight: 8.h,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForRate(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.blue;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}
