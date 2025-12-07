import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.primaryColor,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40.h),

            // App Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.mic_rounded, size: 60.sp, color: Colors.white),
            ),

            SizedBox(height: 24.h),

            Text(
              'Voclio',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),

            SizedBox(height: 32.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Your ultimate productivity companion for managing tasks, notes, and staying organized with voice-powered features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Features List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _buildFeatureItem(
                    Icons.task_alt_rounded,
                    'Task Management',
                    'Organize your tasks efficiently',
                    theme.primaryColor,
                  ),
                  _buildFeatureItem(
                    Icons.note_alt_rounded,
                    'Smart Notes',
                    'Take notes with AI assistance',
                    Colors.blue,
                  ),
                  _buildFeatureItem(
                    Icons.mic_rounded,
                    'Voice Recording',
                    'Record and transcribe quickly',
                    Colors.orange,
                  ),
                  _buildFeatureItem(
                    Icons.emoji_events_rounded,
                    'Achievements',
                    'Track your productivity milestones',
                    Colors.amber,
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Contact & Links
            Container(
              padding: EdgeInsets.all(20.w),
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Get in Touch',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildContactItem(Icons.email_outlined, 'support@voclio.com'),
                  SizedBox(height: 8.h),
                  _buildContactItem(Icons.language_rounded, 'www.voclio.com'),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              '© 2025 Voclio. All rights reserved.',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
      ],
    );
  }
}
