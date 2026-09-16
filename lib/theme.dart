import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  // ═══════════════════════════════════════════════════════════════
  // PROFESSIONAL COLOR PALETTES
  // ═══════════════════════════════════════════════════════════════

  // --- 1. Deep Corporate Blue ---
  static const Color deepBluePrimary = Color(0xFF1565C0);
  static const Color deepBlueOnPrimary = Color(0xFFFFFFFF);
  static const Color deepBluePrimaryContainer = Color(0xFFD1E4FF);
  static const Color deepBlueSecondary = Color(0xFF546E7A);
  static const Color deepBlueSurface = Color(0xFFF8FAFF);
  static const Color deepBlueBackground = Color(0xFFEEF2F8);

  // --- 2. Elegant Emerald Teal ---
  static const Color emeraldPrimary = Color(0xFF00897B);
  static const Color emeraldOnPrimary = Color(0xFFFFFFFF);
  static const Color emeraldPrimaryContainer = Color(0xFFB2DFDB);
  static const Color emeraldSecondary = Color(0xFF5C6BC0);
  static const Color emeraldSurface = Color(0xFFF1FAF8);
  static const Color emeraldBackground = Color(0xFFE8F5F3);

  // --- 3. Royal Indigo ---
  static const Color royalPrimary = Color(0xFF3949AB);
  static const Color royalOnPrimary = Color(0xFFFFFFFF);
  static const Color royalPrimaryContainer = Color(0xFFC5CAE9);
  static const Color royalSecondary = Color(0xFF5C6BC0);
  static const Color royalSurface = Color(0xFFF5F6FC);
  static const Color royalBackground = Color(0xFFECEEF8);

  // --- 4. Charcoal Executive ---
  static const Color charcoalPrimary = Color(0xFF37474F);
  static const Color charcoalOnPrimary = Color(0xFFFFFFFF);
  static const Color charcoalPrimaryContainer = Color(0xFFCFD8DC);
  static const Color charcoalSecondary = Color(0xFF546E7A);
  static const Color charcoalSurface = Color(0xFFF7F9FA);
  static const Color charcoalBackground = Color(0xFFECF0F2);

  // --- 5. Burgundy Prestige ---
  static const Color burgundyPrimary = Color(0xFF6D1A36);
  static const Color burgundyOnPrimary = Color(0xFFFFFFFF);
  static const Color burgundyPrimaryContainer = Color(0xFFFADADD);
  static const Color burgundySecondary = Color(0xFF8D6E63);
  static const Color burgundySurface = Color(0xFFFBF5F6);
  static const Color burgundyBackground = Color(0xFFF3E8EA);

  // --- 6. Slate Professional ---
  static const Color slatePrimary = Color(0xFF455A64);
  static const Color slateOnPrimary = Color(0xFFFFFFFF);
  static const Color slatePrimaryContainer = Color(0xFFCFD8DC);
  static const Color slateSecondary = Color(0xFF78909C);
  static const Color slateSurface = Color(0xFFF8F9FA);
  static const Color slateBackground = Color(0xFFECEEF0);

  // --- 7. Navy Elite ---
  static const Color navyPrimary = Color(0xFF1A237E);
  static const Color navyOnPrimary = Color(0xFFFFFFFF);
  static const Color navyPrimaryContainer = Color(0xFFC5CAE9);
  static const Color navySecondary = Color(0xFF5C6BC0);
  static const Color navySurface = Color(0xFFF4F5FC);
  static const Color navyBackground = Color(0xFFEBEDF8);

  // ═══════════════════════════════════════════════════════════════
  // DARK VARIANTS
  // ═══════════════════════════════════════════════════════════════

  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkBackground = Color(0xFF121218);
  static const Color darkCard = Color(0xFF252536);

  // ═══════════════════════════════════════════════════════════════
  // STATUS COLORS (Consistent across all themes)
  // ═══════════════════════════════════════════════════════════════

  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusResolved = Color(0xFF4CAF50);
  static const Color statusRejected = Color(0xFFF44336);

  // ═══════════════════════════════════════════════════════════════
  // ANIMATION ACCENT COLORS (Glow / Blink highlights)
  // ═══════════════════════════════════════════════════════════════

  static const Color glowBlue = Color(0xFF42A5F5);
  static const Color glowTeal = Color(0xFF26A69A);
  static const Color glowAmber = Color(0xFFFFCA28);
  static const Color glowPurple = Color(0xFFAB47BC);
  static const Color glowGreen = Color(0xFF66BB6A);

  // ═══════════════════════════════════════════════════════════════
  // COMPLETE THEME BUILDER
  // ═══════════════════════════════════════════════════════════════

  static ThemeData deepCorporateBlue() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: deepBluePrimary,
        onPrimary: deepBlueOnPrimary,
        primaryContainer: deepBluePrimaryContainer,
        onPrimaryContainer: const Color(0xFF001D36),
        secondary: deepBlueSecondary,
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFD7E3EB),
        onSecondaryContainer: const Color(0xFF0E1D24),
        surface: deepBlueSurface,
        onSurface: const Color(0xFF1A1C1E),
        surfaceContainerHighest: const Color(0xFFE0E3E7),
        outline: const Color(0xFF73777F),
        outlineVariant: const Color(0xFFC3C7CF),
      ),
      scaffoldBackgroundColor: deepBlueBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: deepBluePrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: deepBluePrimary,
        foregroundColor: deepBlueOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepBluePrimary,
          foregroundColor: deepBlueOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: deepBluePrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: deepBluePrimary, width: 2),
        ),
      ),
    );
  }

  static ThemeData elegantEmerald() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: emeraldPrimary,
        onPrimary: emeraldOnPrimary,
        primaryContainer: emeraldPrimaryContainer,
        onPrimaryContainer: const Color(0xFF00201D),
        secondary: emeraldSecondary,
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFD9DFFF),
        onSecondaryContainer: const Color(0xFF121C36),
        surface: emeraldSurface,
        onSurface: const Color(0xFF1A1C1E),
        outline: const Color(0xFF73777F),
      ),
      scaffoldBackgroundColor: emeraldBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: emeraldPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: emeraldPrimary,
        foregroundColor: emeraldOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldPrimary,
          foregroundColor: emeraldOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: emeraldPrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: emeraldPrimary, width: 2),
        ),
      ),
    );
  }

  static ThemeData royalIndigo() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: royalPrimary,
        onPrimary: royalOnPrimary,
        primaryContainer: royalPrimaryContainer,
        onPrimaryContainer: const Color(0xFF000F5E),
        secondary: royalSecondary,
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFD9DFFF),
        onSecondaryContainer: const Color(0xFF121C36),
        surface: royalSurface,
        onSurface: const Color(0xFF1A1C1E),
        outline: const Color(0xFF73777F),
      ),
      scaffoldBackgroundColor: royalBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: royalPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: royalPrimary,
        foregroundColor: royalOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalPrimary,
          foregroundColor: royalOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: royalPrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: royalPrimary, width: 2),
        ),
      ),
    );
  }

  static ThemeData charcoalExecutive() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: charcoalPrimary,
        onPrimary: charcoalOnPrimary,
        primaryContainer: charcoalPrimaryContainer,
        onPrimaryContainer: const Color(0xFF0E1D24),
        secondary: charcoalSecondary,
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFD7E3EB),
        onSecondaryContainer: const Color(0xFF0E1D24),
        surface: charcoalSurface,
        onSurface: const Color(0xFF1A1C1E),
        outline: const Color(0xFF73777F),
      ),
      scaffoldBackgroundColor: charcoalBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: charcoalPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: charcoalPrimary,
        foregroundColor: charcoalOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoalPrimary,
          foregroundColor: charcoalOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: charcoalPrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: charcoalPrimary, width: 2),
        ),
      ),
    );
  }

  static ThemeData burgundyPrestige() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: burgundyPrimary,
        onPrimary: burgundyOnPrimary,
        primaryContainer: burgundyPrimaryContainer,
        onPrimaryContainer: const Color(0xFF3E001B),
        secondary: burgundySecondary,
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFEFDBD9),
        onSecondaryContainer: const Color(0xFF231210),
        surface: burgundySurface,
        onSurface: const Color(0xFF1A1C1E),
        outline: const Color(0xFF73777F),
      ),
      scaffoldBackgroundColor: burgundyBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: burgundyPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: burgundyPrimary,
        foregroundColor: burgundyOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: burgundyPrimary,
          foregroundColor: burgundyOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: burgundyPrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: burgundyPrimary, width: 2),
        ),
      ),
    );
  }

  static ThemeData slateProfessional() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: slatePrimary,
        onPrimary: slateOnPrimary,
        primaryContainer: slatePrimaryContainer,
        onPrimaryContainer: const Color(0xFF0E1D24),
        secondary: slateSecondary,
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFD9E2E8),
        onSecondaryContainer: const Color(0xFF1C2E36),
        surface: slateSurface,
        onSurface: const Color(0xFF1A1C1E),
        outline: const Color(0xFF73777F),
      ),
      scaffoldBackgroundColor: slateBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: slatePrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: slatePrimary,
        foregroundColor: slateOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: slatePrimary,
          foregroundColor: slateOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: slatePrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: slatePrimary, width: 2),
        ),
      ),
    );
  }

  static ThemeData navyElite() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: navyPrimary,
        onPrimary: navyOnPrimary,
        primaryContainer: navyPrimaryContainer,
        onPrimaryContainer: const Color(0xFF000F5E),
        secondary: navySecondary,
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFD9DFFF),
        onSecondaryContainer: const Color(0xFF121C36),
        surface: navySurface,
        onSurface: const Color(0xFF1A1C1E),
        outline: const Color(0xFF73777F),
      ),
      scaffoldBackgroundColor: navyBackground,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: navyPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: navyPrimary,
        foregroundColor: navyOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyPrimary,
          foregroundColor: navyOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: navyPrimary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: navyPrimary, width: 2),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DARK THEMES
  // ═══════════════════════════════════════════════════════════════

  static ThemeData darkThemeFor(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: seedColor,
      scaffoldBackgroundColor: darkBackground,
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // THEME MAP FOR EASY LOOKUP
  // ═══════════════════════════════════════════════════════════════

  static final Map<String, ThemeData> lightThemes = {
    'Deep Corporate Blue': deepCorporateBlue(),
    'Elegant Emerald': elegantEmerald(),
    'Royal Indigo': royalIndigo(),
    'Charcoal Executive': charcoalExecutive(),
    'Burgundy Prestige': burgundyPrestige(),
    'Slate Professional': slateProfessional(),
    'Navy Elite': navyElite(),
  };

  static final Map<String, Color> themeSeedColors = {
    'Deep Corporate Blue': deepBluePrimary,
    'Elegant Emerald': emeraldPrimary,
    'Royal Indigo': royalPrimary,
    'Charcoal Executive': charcoalPrimary,
    'Burgundy Prestige': burgundyPrimary,
    'Slate Professional': slatePrimary,
    'Navy Elite': navyPrimary,
  };

  static final List<String> themeNames = lightThemes.keys.toList();
}
