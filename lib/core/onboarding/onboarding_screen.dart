import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  final Color _primary = AppColors.primary;
  final Color _accent = AppColors.accent;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      image: 'assets/images/raw.png',
      title: 'Speak Your Tasks',
      subtitle:
          'Simply speak and watch your voice transform into organized tasks and notes instantly.',
    ),
    _OnboardData(
      image: 'assets/images/hi.png',
      title: 'Smart Organization',
      subtitle:
          'AI-powered categorization automatically sorts your voice notes into tasks, reminders, and ideas.',
    ),
    _OnboardData(
      image: 'assets/images/hi1.png',
      title: 'Stay Productive',
      subtitle:
          'Access your voice-converted tasks anywhere and boost your productivity with hands-free note-taking.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSkip() {
    Navigator.of(context).maybePop();
  }

  void _onNext() {
    if (_current < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  void _onGetStarted() {
    Navigator.of(context).maybePop();
  }

  bool _shouldShowSkipAndMaybeLater() {
    return _current >= 2; // Show after user has swiped to the 3rd screen (index 2)
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _accent.withOpacity(0.15),
              _primary.withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBrand(),
                    _shouldShowSkipAndMaybeLater()
                        ? TextButton(
                            onPressed: _onSkip,
                            child: Text('Skip', style: TextStyle(color: _primary, fontWeight: FontWeight.w700)),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, index) => _OnboardPage(
                    data: _pages[index],
                    primary: _primary,
                    accent: _accent,
                    isSmall: isSmall,
                  ),
                ),
              ),

              // Indicators
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: _DotsIndicator(
                  count: _pages.length,
                  current: _current,
                  activeColor: _primary,
                  inactiveColor: _accent.withOpacity(0.4),
                ),
              ),

              // Bottom actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        onPressed: _current == _pages.length - 1 ? _onGetStarted : _onNext,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_current == _pages.length - 1 ? 'Get Started' : 'Next',
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(width: 8),
                            Icon(_current == _pages.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 20),
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

  Widget _buildBrand() {
    return Image.asset(
      'assets/images/Microphone Icon.png',
      width: 60,
      height: 60,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.mic_rounded,
        size: 60,
        color: AppColors.primary,
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  final Color primary;
  final Color accent;
  final bool isSmall;

  const _OnboardPage({
    required this.data,
    required this.primary,
    required this.accent,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 8),

          // Hero image - natural display
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  data.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: AppColors.grey,
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
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isSmall ? 26 : 30, fontWeight: FontWeight.w900, color: primary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: isSmall ? 14 : 16, color: Colors.black87, height: 1.5, fontWeight: FontWeight.w500),
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

class _OnboardData {
  final String image;
  final String title;
  final String subtitle;
  const _OnboardData({required this.image, required this.title, required this.subtitle});
}

