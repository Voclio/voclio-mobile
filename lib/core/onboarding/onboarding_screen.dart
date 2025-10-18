import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';
import 'package:voclio_app/core/routes/App_routes.dart';
import 'package:voclio_app/core/app/theme_controller.dart';
import 'package:voclio_app/core/app/language_controller.dart';
import '../common/animation/animate_do.dart';
import '../common/animation/smooth_toggle_animation.dart';
import '../common/inputs/text_app.dart';
import 'model/onboarding_model.dart'; // ✅ استيراد الموديل الجديد

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_current < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _onGetStarted() => context.goRoute(AppRouter.login);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance.isDarkMode,
      builder: (context, isDarkMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageController.instance.currentLocale,
          builder: (context, locale, child) {
            return _buildOnboardingContent(context);
          },
        );
      },
    );
  }

  Widget _buildOnboardingContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final colors = context.colors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.accent!.withOpacity(0.15),
              colors.primary!.withOpacity(0.08),
              colors.background!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start,
                  children: [
                    _buildTopControls(context),
                  ],
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingData.length,
                  onPageChanged:
                      (i) => setState(() => _current = i),
                  itemBuilder:
                      (context, index) => _OnboardPage(
                        data: onboardingData[index],
                        isSmall: isSmall,
                      ),
                ),
              ),

              // Indicators
              Padding(
                padding: const EdgeInsets.only(
                  top: 4,
                  bottom: 16,
                ),
                child: _DotsIndicator(
                  count: onboardingData.length,
                  current: _current,
                  activeColor: colors.primary!,
                  inactiveColor: colors.accent!.withOpacity(
                    0.4,
                  ),
                ),
              ),

              // Bottom actions
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                          backgroundColor: colors.primary!,
                          foregroundColor:
                              colors.textColor!,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        onPressed:
                            _current ==
                                    onboardingData.length -
                                        1
                                ? _onGetStarted
                                : _onNext,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            TextApp(
                              text:
                                  _current ==
                                          onboardingData
                                                  .length -
                                              1
                                      ? context.translate('get_started')
                                      : context.translate('next'),
                              theme: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: Colors.white,

                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _current ==
                                      onboardingData
                                              .length -
                                          1
                                  ? Icons.check_rounded
                                  : Icons
                                      .arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        // Language Toggle Button
        CustomFadeInRight(
          duration: 600,
          child: GestureDetector(
            onTap: () async {
              await LanguageController.instance.toggleLanguage();
            },
            child: SmoothContainerTransition(
              isActive: LanguageController.instance.isArabic,
              activeColor: colors.primary!.withOpacity(0.2),
              inactiveColor: colors.primary!.withOpacity(0.1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SmoothToggleAnimation(
                      isActive: LanguageController.instance.isArabic,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      rotationAngle: 0.25,
                      child: Icon(
                        Icons.language_rounded,
                        color: colors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SmoothTextTransition(
                      text: LanguageController.instance.isArabic ? 'EN' : 'AR',
                      isActive: LanguageController.instance.isArabic,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      textColor: colors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Dark Mode Toggle Button
        CustomFadeInRight(
          duration: 700,
          child: GestureDetector(
            onTap: () async {
              await ThemeController.instance.toggleTheme();
            },
            child: SmoothContainerTransition(
              isActive: ThemeController.instance.isDarkMode.value,
              activeColor: colors.primary!.withOpacity(0.2),
              inactiveColor: colors.primary!.withOpacity(0.1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SmoothToggleAnimation(
                  isActive: ThemeController.instance.isDarkMode.value,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  rotationAngle: 0.5,
                  scaleEffect: true,
                  child: Icon(
                    ThemeController.instance.isDarkMode.value
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final OnboardingModel data; // ✅ النوع الجديد من الموديل
  final bool isSmall;

  const _OnboardPage({
    required this.data,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 8),

          // Hero image
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  data.image,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Container(
                            decoration: BoxDecoration(
                              color: colors.textColor,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 80,
                                color: colors.textColor,
                              ),
                            ),
                          ),
                ),
              ),
            ),
          ),

          // Text content
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextApp(
                  text: context.translate(data.titleKey),
                  textAlign: TextAlign.center,
                  theme: TextStyle(
                    fontSize: isSmall ? 26 : 30,
                    fontWeight: FontWeight.w900,
                    color: colors.textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: TextApp(
                    text: context.translate(data.subtitleKey),
                    textAlign: TextAlign.center,
                    theme: TextStyle(
                      fontSize: isSmall ? 14 : 16,
                      color: colors.textSecondary,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;
  final Color inactiveColor;

  const _DotsIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: active ? 26 : 8,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
