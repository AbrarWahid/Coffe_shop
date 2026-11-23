import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette: deep espresso, warm cream and a copper accent.
abstract final class AppColors {
  static const espresso = Color(0xFF1E1410);
  static const roast = Color(0xFF3A2A22);
  static const cream = Color(0xFFF7F2EB);
  static const sand = Color(0xFFEFE6DA);
  static const surface = Color(0xFFFFFFFF);
  static const copper = Color(0xFFB8693D);
  static const copperSoft = Color(0xFFF4E4D6);

  /// Darker copper for small text on light backgrounds (meets WCAG AA).
  static const copperDeep = Color(0xFF8F4E2A);
  static const ink = Color(0xFF2A1E18);
  static const muted = Color(0xFF76665B);
  static const line = Color(0xFFE7DDD1);
  static const success = Color(0xFF3E7D5A);
  static const danger = Color(0xFFB3453A);
}

abstract final class AppRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);
  static const curve = Curves.easeOutCubic;
}

abstract final class AppShadows {
  static final soft = [
    BoxShadow(
      color: AppColors.espresso.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
  static final lifted = [
    BoxShadow(
      color: AppColors.espresso.withValues(alpha: 0.16),
      blurRadius: 30,
      offset: const Offset(0, 14),
    ),
  ];
}

/// Display text uses Fraunces (an elegant serif); UI text uses Plus Jakarta Sans.
abstract final class AppText {
  static TextStyle display(double size, {Color color = AppColors.ink}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double height = 1.45,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle overline({Color color = AppColors.copper}) => body(
    11,
    weight: FontWeight.w700,
    color: color,
  ).copyWith(letterSpacing: 1.6);
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.copper,
        primary: AppColors.espresso,
        onPrimary: AppColors.cream,
        secondary: AppColors.copper,
        surface: AppColors.cream,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      splashFactory: InkSparkle.splashFactory,
    );
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.line),
    );

    return base.copyWith(
      textTheme: textTheme,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppText.body(14, color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.copper, width: 1.6),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
        errorStyle: AppText.body(12, color: AppColors.danger),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.espresso,
        contentTextStyle: AppText.body(14, color: AppColors.cream),
        actionTextColor: AppColors.copperSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cream,
        showDragHandle: true,
        dragHandleColor: AppColors.line,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.copper,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.copper,
        selectionColor: AppColors.copperSoft,
        selectionHandleColor: AppColors.copper,
      ),
    );
  }
}
