import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens for Ridivo.
///
/// Primary face: Space Grotesk (all UI — body, headings, labels, stats).
/// Display face: Red Hat Display (hero/onboarding headline, big numbers).
///
/// Fonts are loaded via the google_fonts package. Both families are pre-cached
/// in main() before runApp() so the first frame already has the correct glyphs.
///
/// All sizes in logical pixels (sp in Flutter). Source: designSystem.md §3.
abstract final class AppTextStyles {
  // ─────────────────────────────────────────────────────────────────────────
  // DARK VARIANTS
  // ─────────────────────────────────────────────────────────────────────────

  /// 32sp / 800 ExtraBold — onboarding hero headline
  static TextStyle get darkDisplay => GoogleFonts.redHatDisplay(
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    color: AppColors.darkTextPrimary,
  );

  /// 32sp / 800 ExtraBold — accented hero word (primary blue)
  static TextStyle get darkDisplayAccent => GoogleFonts.redHatDisplay(
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    color: AppColors.primary,
  );

  /// 24sp / 700 Bold — screen-level headings
  static TextStyle get darkH1 => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.darkTextPrimary,
  );

  /// 20sp / 700 Bold — section headings
  static TextStyle get darkH2 => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.darkTextPrimary,
  );

  /// 18sp / 600 SemiBold — card titles, ride names
  static TextStyle get darkH3 => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );

  /// 16sp / 600 SemiBold — list item titles, setting rows
  static TextStyle get darkH4 => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );

  /// 14sp / 400 Regular — descriptions, body paragraphs
  static TextStyle get darkBody => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkTextSecondary,
  );

  /// 14sp / 600 SemiBold — emphasized body (notification titles, expense names)
  static TextStyle get darkBodyStrong => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );

  /// 12sp / 500 Medium — ALL-CAPS section tags (BATTERY, STEP 1 OF 4)
  static TextStyle get darkLabel => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: AppColors.darkTextMuted,
  );

  /// 11sp / 600 SemiBold — ALL-CAPS micro-labels (letter-spacing 1.2)
  static TextStyle get darkLabelUpper => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.darkTextMuted,
  );

  /// 11sp / 600 SemiBold — step label "STEP N OF 4: LABEL" (primary color)
  static TextStyle get darkStepLabel => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.primary,
  );

  /// 12sp / 400 Regular — timestamps, subtitles, secondary metadata
  static TextStyle get darkCaption => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.darkTextMuted,
  );

  /// 28sp / 700 Bold — large numeric stat values ("145 mi", "95/100")
  static TextStyle get darkStat => GoogleFonts.spaceGrotesk(
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.darkTextPrimary,
  );

  /// 14sp / 400 Regular — unit suffix next to stat ("mi", "km/h")
  static TextStyle get darkStatUnit => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkTextSecondary,
  );

  /// 16sp / 600 SemiBold — all button labels
  static TextStyle get darkButton => GoogleFonts.redHatDisplay(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
    color: AppColors.darkTextPrimary,
  );

  /// 14sp / 500 Medium — tappable links ("View All", "Edit Route")
  static TextStyle get darkLink => GoogleFonts.redHatDisplay(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.darkTextAccent,
  );

  /// 10sp / 700 Bold ALL-CAPS — status/difficulty badges (EASY, HARD, PAYER)
  static TextStyle get darkBadge => GoogleFonts.spaceGrotesk(
    fontSize: 10,
    height: 12 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.darkTextPrimary,
  );

  /// 18sp / 600 SemiBold — AppBar title, centered
  static TextStyle get darkAppBarTitle => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );

  /// 20sp / 700 Bold — stat chip value (BATTERY 84%, NEXT TRIP value)
  static TextStyle get darkStatChipValue => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.darkTextPrimary,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // LIGHT VARIANTS  (same size/weight — only color differs)
  // ─────────────────────────────────────────────────────────────────────────

  static TextStyle get lightDisplay => GoogleFonts.redHatDisplay(
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightDisplayAccent => GoogleFonts.redHatDisplay(
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    color: AppColors.primary,
  );

  static TextStyle get lightH1 => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightH2 => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightH3 => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightH4 => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightBody => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextSecondary,
  );

  static TextStyle get lightBodyStrong => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightLabel => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: AppColors.lightTextMuted,
  );

  static TextStyle get lightLabelUpper => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.lightTextMuted,
  );

  static TextStyle get lightStepLabel => GoogleFonts.spaceGrotesk(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.primary,
  );

  static TextStyle get lightCaption => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextMuted,
  );

  static TextStyle get lightStat => GoogleFonts.spaceGrotesk(
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightStatUnit => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextSecondary,
  );

  static TextStyle get lightButton => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightLink => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.lightTextAccent,
  );

  static TextStyle get lightBadge => GoogleFonts.spaceGrotesk(
    fontSize: 10,
    height: 12 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightAppBarTitle => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
  );

  static TextStyle get lightStatChipValue => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    color: AppColors.lightTextPrimary,
  );
}

/// Extension that exposes theme-resolved text style shortcuts from [BuildContext].
extension AppTextStylesX on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  TextStyle get display =>
      _isDark ? AppTextStyles.darkDisplay : AppTextStyles.lightDisplay;
  TextStyle get displayAccent => _isDark
      ? AppTextStyles.darkDisplayAccent
      : AppTextStyles.lightDisplayAccent;
  TextStyle get h1 => _isDark ? AppTextStyles.darkH1 : AppTextStyles.lightH1;
  TextStyle get h2 => _isDark ? AppTextStyles.darkH2 : AppTextStyles.lightH2;
  TextStyle get h3 => _isDark ? AppTextStyles.darkH3 : AppTextStyles.lightH3;
  TextStyle get h4 => _isDark ? AppTextStyles.darkH4 : AppTextStyles.lightH4;
  TextStyle get bodyText =>
      _isDark ? AppTextStyles.darkBody : AppTextStyles.lightBody;
  TextStyle get bodyStrong =>
      _isDark ? AppTextStyles.darkBodyStrong : AppTextStyles.lightBodyStrong;
  TextStyle get label =>
      _isDark ? AppTextStyles.darkLabel : AppTextStyles.lightLabel;
  TextStyle get labelUpper =>
      _isDark ? AppTextStyles.darkLabelUpper : AppTextStyles.lightLabelUpper;
  TextStyle get stepLabel =>
      _isDark ? AppTextStyles.darkStepLabel : AppTextStyles.lightStepLabel;
  TextStyle get caption =>
      _isDark ? AppTextStyles.darkCaption : AppTextStyles.lightCaption;
  TextStyle get statValue =>
      _isDark ? AppTextStyles.darkStat : AppTextStyles.lightStat;
  TextStyle get statUnit =>
      _isDark ? AppTextStyles.darkStatUnit : AppTextStyles.lightStatUnit;
  TextStyle get buttonLabel =>
      _isDark ? AppTextStyles.darkButton : AppTextStyles.lightButton;
  TextStyle get link =>
      _isDark ? AppTextStyles.darkLink : AppTextStyles.lightLink;
  TextStyle get badge =>
      _isDark ? AppTextStyles.darkBadge : AppTextStyles.lightBadge;
  TextStyle get appBarTitle =>
      _isDark ? AppTextStyles.darkAppBarTitle : AppTextStyles.lightAppBarTitle;
  TextStyle get statChipValue => _isDark
      ? AppTextStyles.darkStatChipValue
      : AppTextStyles.lightStatChipValue;
}
