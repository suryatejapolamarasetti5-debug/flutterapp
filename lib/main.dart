import 'package:flutter/material.dart';
import 'animations.dart';
import 'app_shell.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'theme.dart';
import 'background_animation.dart';
import 'intro_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StreetLightApp());
}

class StreetLightApp extends StatelessWidget {
  const StreetLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StreetLight Complaint System',

      theme: AppThemes.deepCorporateBlue().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: SubtlePageTransitionsBuilder(),
            TargetPlatform.iOS: SubtlePageTransitionsBuilder(),
            TargetPlatform.linux: SubtlePageTransitionsBuilder(),
            TargetPlatform.macOS: SubtlePageTransitionsBuilder(),
            TargetPlatform.windows: SubtlePageTransitionsBuilder(),
          },
        ),
      ),

      darkTheme: AppThemes.darkThemeFor(
        AppThemes.themeSeedColors['Deep Corporate Blue']!,
      ).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: SubtlePageTransitionsBuilder(),
            TargetPlatform.iOS: SubtlePageTransitionsBuilder(),
            TargetPlatform.linux: SubtlePageTransitionsBuilder(),
            TargetPlatform.macOS: SubtlePageTransitionsBuilder(),
            TargetPlatform.windows: SubtlePageTransitionsBuilder(),
          },
        ),
      ),

      themeMode: ThemeMode.system,

      home: const AppRoot(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// APP ROOT
// A simple stage machine: flashcards first, then the login page, and
// only after a successful login is the app shell (with navigation)
// shown. At every stage the login/register pages are NOT built
// underneath the flash cards, so nothing overlaps.
// ═══════════════════════════════════════════════════════════════

enum _AppStage { intro, login, register, app }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  _AppStage _stage = _AppStage.intro;

  void _setStage(_AppStage stage) {
    setState(() {
      _stage = stage;
    });
  }

  Widget _buildStage() {
    switch (_stage) {
      case _AppStage.intro:
        return AppIntroPage(
          onFinished: () => _setStage(_AppStage.login),
        );

      case _AppStage.login:
        return LoginPage(
          onLoginSuccess: () => _setStage(_AppStage.app),
          onRegisterTap: () => _setStage(_AppStage.register),
        );

      case _AppStage.register:
        return RegisterPage(
          onRegistered: () => _setStage(_AppStage.login),
          onLoginTap: () => _setStage(_AppStage.login),
        );

      case _AppStage.app:
        return AppShell(
          onLoggedOut: () => _setStage(_AppStage.login),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: BackgroundAnimation(),
        ),

        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              // Calm cross-fade with a hint of upward motion between the
              // intro, the auth screens and the app shell.
              final Animation<double> curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );

              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_stage),
              child: _buildStage(),
            ),
          ),
        ),
      ],
    );
  }
}