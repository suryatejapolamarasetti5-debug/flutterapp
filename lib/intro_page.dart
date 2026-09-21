import 'package:flutter/material.dart';

import 'theme.dart';
import 'animations.dart';

// ═══════════════════════════════════════════════════════════════
// ONBOARDING FLASHCARDS
// Shown before the main app (and the login page) so new users can
// quickly learn what the app is about.
// ═══════════════════════════════════════════════════════════════

class AppIntroPage extends StatefulWidget {
  final VoidCallback onFinished;

  const AppIntroPage({super.key, required this.onFinished});

  @override
  State<AppIntroPage> createState() => _AppIntroPageState();
}

class _AppIntroPageState extends State<AppIntroPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<_IntroCard> _cards = [
    _IntroCard(
      icon: Icons.lightbulb_outline,
      color: AppThemes.statusPending,
      title: 'StreetLight',
      description:
          'A community complaint system for streetlight issues. '
          'Spot a broken or faulty light? Let us know in seconds.',
    ),
    _IntroCard(
      icon: Icons.report_gmailerrorred_outlined,
      color: AppThemes.statusInProgress,
      title: 'Report Complaints',
      description:
          'Describe the problem, pin the location, and attach a photo. '
          'Your report goes straight to the relevant office.',
    ),
    _IntroCard(
      icon: Icons.map_outlined,
      color: AppThemes.statusResolved,
      title: 'Nearby Issues',
      description:
          'See reported issues around you on the map and check '
          'what is already being handled in your area.',
    ),
    _IntroCard(
      icon: Icons.contact_phone_outlined,
      color: AppThemes.glowPurple,
      title: 'Track Your Progress',
      description:
          'Follow every complaint from Pending, to In Progress, '
          'to Resolved, and reach the right electrical office with '
          'one tap.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void _finish() {
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLast = _currentIndex == _cards.length - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // =========================
              // APP LOGO / NAME
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlowPulse(
                    borderRadius: BorderRadius.circular(50),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primary,
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'StreetLight',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // =========================
              // FLASHCARDS
              // =========================
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _cards.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _FlashCard(card: _cards[index]);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // DOTS INDICATOR
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_cards.length, (index) {
                  final active = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: active
                          ? colorScheme.primary
                          : colorScheme.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // =========================
              // ACTIONS
              // =========================
              Row(
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Skip'),
                  ),

                  const Spacer(),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isLast ? _finish : () {
                        _goToPage(_currentIndex + 1);
                      },
                      icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                      label: Text(
                        isLast ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SINGLE FLASHCARD
// ═══════════════════════════════════════════════════════════════

class _FlashCard extends StatelessWidget {
  final _IntroCard card;

  const _FlashCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: BreathingGlow(
        color: card.color,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppThemes.darkCard
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: card.color.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: card.color.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ---------- ICON ----------
              LightRipple(
                color: card.color,
                maxOpacity: 0.35,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: card.color.withValues(alpha: 0.12),
                    border: Border.all(
                      color: card.color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    card.icon,
                    size: 46,
                    color: card.color,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ---------- TITLE ----------
              Text(
                card.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              // ---------- DESCRIPTION ----------
              Text(
                card.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INTRO CARD DATA
// ═══════════════════════════════════════════════════════════════

class _IntroCard {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _IntroCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}