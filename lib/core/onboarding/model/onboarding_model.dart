class OnboardingModel {
  final String image;
  final String titleKey;
  final String subtitleKey;

  const OnboardingModel({
    required this.image,
    required this.titleKey,
    required this.subtitleKey,
  });
}

const List<OnboardingModel> onboardingData = [
  OnboardingModel(
    image: 'assets/images/raw.png',
    titleKey: 'speak_tasks',
    subtitleKey: 'speak_tasks_subtitle',
  ),
  OnboardingModel(
    image: 'assets/images/hi.png',
    titleKey: 'smart_organization',
    subtitleKey: 'smart_organization_subtitle',
  ),
  OnboardingModel(
    image: 'assets/images/hi1.png',
    titleKey: 'stay_productive',
    subtitleKey: 'stay_productive_subtitle',
  ),
];
