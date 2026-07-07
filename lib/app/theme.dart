import 'package:flutter/material.dart';

class AppColors {
  // ─── Cores de marca (sempre fixas) ───────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9D5CF5);
  static const Color primaryDark = Color(0xFF5B21B6);

  static const Color hot = Color(0xFFEF4444);
  static const Color hotLight = Color(0xFFFCA5A5);

  static const Color savings = Color(0xFF10B981);
  static const Color savingsLight = Color(0xFF6EE7B7);

  static const Color coupon = Color(0xFFF59E0B);
  static const Color couponLight = Color(0xFFFCD34D);

  static const Color verified = Color(0xFF3B82F6);

  // ─── Cores semânticas escuras (padrão / fallback) ─────────────────────────
  static const Color background = Color(0xFF0A0A14);
  static const Color surface = Color(0xFF13131F);
  static const Color surfaceElevated = Color(0xFF1C1C2E);
  static const Color card = Color(0xFF1A1A2E);
  static const Color cardElevated = Color(0xFF22223A);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);
  static const Color textDisabled = Color(0xFF334155);

  static const Color border = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFF334155);

  static const Color shimmerBase = Color(0xFF1E1E32);
  static const Color shimmerHighlight = Color(0xFF2A2A44);
}

// ─── Cores dinâmicas que respondem ao tema ────────────────────────────────────

/// Acesso via `context.appColors.background`, `context.appColors.surface`, etc.
class AppThemeColors {
  final BuildContext context;
  const AppThemeColors(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // Superfícies
  Color get background =>
      isDark ? const Color(0xFF0A0A14) : const Color(0xFFF8F7FF);
  Color get surface =>
      isDark ? const Color(0xFF13131F) : const Color(0xFFFFFFFF);
  Color get surfaceElevated =>
      isDark ? const Color(0xFF1C1C2E) : const Color(0xFFF1F5F9);
  Color get card =>
      isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF);

  // Bordas
  Color get border =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  Color get borderLight =>
      isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

  // Texto
  Color get textPrimary =>
      isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
  Color get textSecondary =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get textMuted =>
      isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);

  // Shimmer
  Color get shimmerBase =>
      isDark ? const Color(0xFF1E1E32) : const Color(0xFFE2E8F0);
  Color get shimmerHighlight =>
      isDark ? const Color(0xFF2A2A44) : const Color(0xFFF1F5F9);

  // AppBar
  Color get appBarBackground =>
      isDark ? const Color(0xFF0A0A14) : const Color(0xFFFFFFFF);
  Color get navBarBackground =>
      isDark ? const Color(0xFF13131F) : const Color(0xFFFFFFFF);
}

extension AppThemeColorsExtension on BuildContext {
  AppThemeColors get appColors => AppThemeColors(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}


class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hotGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dealCardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient savingsGradient = LinearGradient(
    colors: [AppColors.savings, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0A14), Color(0xFF0D0D1F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

const _fontFamily = 'Roboto'; // Fonte padrão Android — sem dependências externas

ThemeData appTheme() {
  final base = ThemeData.dark();

  return base.copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.hot,
      tertiary: AppColors.savings,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineLarge: TextStyle(fontFamily: _fontFamily, fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );
}

ThemeData appThemeLight() {
  const _lightBg = Color(0xFFF8F7FF);
  const _lightSurface = Color(0xFFFFFFFF);
  const _lightCard = Color(0xFFFFFFFF);
  const _lightBorder = Color(0xFFE2E8F0);
  const _lightTextPrimary = Color(0xFF1E293B);
  const _lightTextSecondary = Color(0xFF64748B);
  const _lightTextMuted = Color(0xFF94A3B8);

  final base = ThemeData.light();
  return base.copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: _lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.hot,
      tertiary: AppColors.savings,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 32, fontWeight: FontWeight.w800, color: _lightTextPrimary, letterSpacing: -0.5),
      displayMedium: TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w700, color: _lightTextPrimary),
      headlineLarge: TextStyle(fontFamily: _fontFamily, fontSize: 24, fontWeight: FontWeight.w700, color: _lightTextPrimary),
      headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: _lightTextPrimary),
      titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: _lightTextPrimary),
      titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w500, color: _lightTextPrimary),
      bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: _lightTextPrimary),
      bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: _lightTextSecondary),
      labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: _lightTextPrimary),
      labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: _lightTextSecondary, letterSpacing: 0.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w800, color: _lightTextPrimary),
      iconTheme: IconThemeData(color: _lightTextPrimary),
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: _lightTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: _lightCard,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _lightBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: const TextStyle(color: _lightTextMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: _lightBorder, thickness: 1),
  );
}
