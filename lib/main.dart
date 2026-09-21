import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      ),

      darkTheme: AppThemes.darkThemeFor(
        AppThemes.themeSeedColors['Deep Corporate Blue']!,
      ).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
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
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
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