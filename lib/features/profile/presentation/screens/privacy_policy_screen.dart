import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_tokens.dart';
import 'package:voclio_app/core/widgets/home_system/home_system_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeSecondaryScaffold(
      title: 'Privacy Policy',
      subtitle: 'Last updated: December 7, 2025',
      icon: Icons.privacy_tip_outlined,
      accent: HomeSystemTokens.green,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: HomeSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              color: HomeSystemTokens.ink,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: HomeSystemTokens.inkSoft,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
