import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: December 7, 2025',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),

            SizedBox(height: 24.h),

            _buildSection(
              'Introduction',
              'This Privacy Policy describes how Voclio ("we", "us", or "our") collects, uses, and shares your personal information when you use our mobile application.',
            ),

            _buildSection(
              'Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
                  '• Name and email address\n'
                  '• Profile information\n'
                  '• Tasks and notes you create\n'
                  '• Voice recordings (stored locally)\n'
                  '• Usage data and analytics',
            ),

            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n\n'
                  '• Provide, maintain, and improve our services\n'
                  '• Send you technical notices and support messages\n'
                  '• Respond to your comments and questions\n'
                  '• Analyze usage patterns and trends',
            ),

            _buildSection(
              'Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
            ),

            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate data\n'
                  '• Request deletion of your data\n'
                  '• Opt-out of marketing communications',
            ),

            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                  'Email: privacy@voclio.com\n'
                  'Website: www.voclio.com',
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
