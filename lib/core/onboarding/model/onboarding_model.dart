import 'package:flutter/material.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingModel({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
const List<OnboardingModel> onboardingData = [
  OnboardingModel(
    image: 'assets/images/raw.png',
    title: 'Speak Your Tasks',
    subtitle:
    'Simply speak and watch your voice transform into organized tasks and notes instantly.',
  ),
  OnboardingModel(
    image: 'assets/images/hi.png',
    title: 'Smart Organization',
    subtitle:
    'AI-powered categorization automatically sorts your voice notes into tasks, reminders, and ideas.',
  ),
  OnboardingModel(
    image: 'assets/images/hi1.png',
    title: 'Stay Productive',
    subtitle:
    'Access your voice-converted tasks anywhere and boost your productivity with hands-free note-taking.',
  ),
];
