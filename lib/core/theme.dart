import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────────────────────────
//  AppColors — adaptive palette that switches with system brightness
// ────────────────────────────────────────────────────────────────────────────
//
//  Usage in widgets:
//    final c = AppColors.of(context);
//    c.neonCyan, c.background, c.glassFill, etc.
//
//  Static constants (always‑on neon accents, same in both modes):
//    AppColors.neonCyan, AppColors.neonPink, etc.
// ────────────────────────────────────────────────────────────────────────────

class AppColors {
  // ── Always-on accent colours (same in both modes) ────────────────────────
  static const Color neonCyan   = Color(0xFF00E5FF);
  static const Color neonBlue   = Color(0xFF2979FF);
  static const Color neonViolet = Color(0xFF7B5CF0);
  static const Color neonPink   = Color(0xFFFF2D7E);
  static const Color neonGreen  = Color(0xFF00E676);

  // ── Resolved adaptive colours — call AppColors.of(context) ──────────────
  final Color background;
  final Color surface;
  final Color panelDark;
  final Color glassFill;
  final Color glassBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color deepSpace;       // used in gradients
  final Color cardBg;
  final Color appBarBg;
  final bool  isDark;

  const AppColors._({
    required this.background,
    required this.surface,
    required this.panelDark,
    required this.glassFill,
    required this.glassBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.deepSpace,
    required this.cardBg,
    required this.appBarBg,
    required this.isDark,
  });

  // ── Dark palette (anti‑gravity / space aesthetic) ────────────────────────
  static const AppColors _dark = AppColors._(
    background:    Color(0xFF050A1A),
    surface:       Color(0xFF0A1628),
    panelDark:     Color(0xFF07111F),
    glassFill:     Color(0x1AFFFFFF),   // white 10%
    glassBorder:   Color(0x26FFFFFF),   // white 15%
    textPrimary:   Color(0xFFE8F0FF),
    textSecondary: Color(0xFF6688AA),
    textMuted:     Color(0xFF334455),
    deepSpace:     Color(0xFF050A1A),
    cardBg:        Color(0xFF0D1B2E),
    appBarBg:      Color(0xFF0A1628),
    isDark:        true,
  );

  // ── Light palette (clean, airy, still uses neon accents) ─────────────────
  static const AppColors _light = AppColors._(
    background:    Color(0xFFF0F4FF),
    surface:       Color(0xFFFFFFFF),
    panelDark:     Color(0xFFE8EDF8),
    glassFill:     Color(0xCCFFFFFF),   // white 80%
    glassBorder:   Color(0x40000000),   // black 25%
    textPrimary:   Color(0xFF0D1B2E),
    textSecondary: Color(0xFF445566),
    textMuted:     Color(0xFF99AABB),
    deepSpace:     Color(0xFFD8E4F8),
    cardBg:        Color(0xFFFFFFFF),
    appBarBg:      Color(0xFFF8FAFF),
    isDark:        false,
  );

  // ── Factory: resolve from current context ────────────────────────────────
  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _dark : _light;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Static fallback constants for widgets that reference AppColors.glassFill
  // etc. without a BuildContext (compile-time const decoration values).
  // These mirror the dark-mode values and are the ONLY statics that share
  // names with the instance fields — Dart disallows that, so we keep them
  // ONLY for the fields not present as instance members above.
  // ─────────────────────────────────────────────────────────────────────────
  static const Color glassFillStatic    = Color(0x1AFFFFFF);
  static const Color glassBorderStatic  = Color(0x26FFFFFF);
}

// ────────────────────────────────────────────────────────────────────────────
//  AppTheme — Material 3 ThemeData for light & dark
// ────────────────────────────────────────────────────────────────────────────
class AppTheme {
  // Dark seed → deep blue-navy
  static const _darkSeed  = Color(0xFF00E5FF);
  // Light seed → sky blue
  static const _lightSeed = Color(0xFF1565C0);

  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: _lightSeed,
      brightness: Brightness.light,
    );
    return _build(cs);
  }

  static ThemeData dark() {
    final cs = ColorScheme.fromSeed(
      seedColor: _darkSeed,
      brightness: Brightness.dark,
      surface:      const Color(0xFF0A1628),
      onSurface:    const Color(0xFFE8F0FF),
    );
    return _build(cs).copyWith(
      scaffoldBackgroundColor: const Color(0xFF050A1A),
    );
  }

  static ThemeData _build(ColorScheme cs) {
    final isDark = cs.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF050A1A)
          : const Color(0xFFF0F4FF),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark
            ? const Color(0xFF0D1B2E)
            : const Color(0xFFFFFFFF),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? const Color(0xFF0D1B2E)
            : const Color(0xFFE8EDF8),
        labelStyle: TextStyle(
          color: isDark
              ? const Color(0xFF6688AA)
              : const Color(0xFF445566),
          fontSize: 12,
        ),
        side: BorderSide(
          color: isDark
              ? const Color(0x26FFFFFF)
              : const Color(0x30000000),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? const Color(0xFF0D1B2E)
            : const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: isDark
              ? const Color(0xFF6688AA)
              : const Color(0xFF445566),
          fontSize: 14,
          height: 1.5,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark
            ? const Color(0xFF0D1B2E)
            : const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF00E5FF);
          }
          return isDark
              ? const Color(0xFF334455)
              : const Color(0xFFBBCCDD);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF00E5FF).withValues(alpha: 0.3);
          }
          return isDark
              ? const Color(0xFF1A2A3A)
              : const Color(0xFFDDEEFF);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF0D1B2E)
            : const Color(0xFF1A2A3A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: const Color(0xFF050A1A),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF00E5FF),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
        ),
      ),
    );
  }
}
