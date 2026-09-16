import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'theme.dart';
import 'background_animation.dart';

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

      home: Stack(
        children: [
          const Positioned.fill(
            child: BackgroundAnimation(),
          ),

          const Positioned.fill(
            child: AppShell(),
          ),
        ],
      ),
    );
  }
}