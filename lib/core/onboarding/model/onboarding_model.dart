class OnboardingModel {
  final String image;
  final String titleKey;
  final String subtitleKey;
  final String? video; // جديد: مسار الفيديو اختياري

  const OnboardingModel({
    required this.image,
    required this.titleKey,
    required this.subtitleKey,
    this.video,
  });
}

const List<OnboardingModel> onboardingData = [

  OnboardingModel(
    image: 'assets/images/onboarding2.png',
    titleKey: 'smart_organization',
    subtitleKey: 'smart_organization_subtitle',
  ),

];
