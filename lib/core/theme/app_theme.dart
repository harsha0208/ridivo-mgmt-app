import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_text_styles.dart';

/// Ridivo ThemeData factory.
///
/// Usage:
///   MaterialApp(
///     theme: AppTheme.light(),
///     darkTheme: AppTheme.dark(),
///     themeMode: ThemeMode.system,   // or .dark / .light
///   )
///
/// Both themes use Material 3. The dark theme is the canonical brand palette;
/// the light theme is an accessible inversion (same primary / semantic hues,
/// inverted surface / text hierarchy).
abstract final class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────
  // DARK
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData dark() {
    const ColorScheme cs = ColorScheme(
      brightness: Brightness.dark,
      // Brand
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDim,
      onPrimaryContainer: Colors.white,
      // Secondary (maps to primaryLight for hover/accent use)
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primaryDim,
      onSecondaryContainer: Colors.white,
      // Tertiary — success green
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.successDim,
      onTertiaryContainer: AppColors.success,
      // Error
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.dangerDim,
      onErrorContainer: AppColors.danger,
      // Surfaces
      surface: AppColors.darkBgSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerLowest: AppColors.darkBgBase,
      surfaceContainerLow: AppColors.darkBgBase,
      surfaceContainer: AppColors.darkBgSurface,
      surfaceContainerHigh: AppColors.darkBgElevated,
      surfaceContainerHighest: AppColors.darkBgElevated,
      surfaceDim: AppColors.darkBgOverlay,
      surfaceBright: AppColors.darkBgElevated,
      onSurfaceVariant: AppColors.darkTextSecondary,
      // Outline
      outline: AppColors.darkBorderDefault,
      outlineVariant: AppColors.darkBorderActive,
      // Scrim
      scrim: Color(0x99000000),
      // Inverse
      inverseSurface: AppColors.lightBgSurface,
      onInverseSurface: AppColors.lightTextPrimary,
      inversePrimary: AppColors.primary,
      // Shadow
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,

      // Scaffold
      scaffoldBackgroundColor: AppColors.darkBgBase,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBgBase,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.darkAppBarTitle,
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppSizes.iconMd,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppSizes.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBgSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextMuted,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // Navigation bar (M3 nav bar)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkBgSurface,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? AppColors.primary : AppColors.darkTextMuted,
            size: AppSizes.iconMd,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppColors.primary : AppColors.darkTextMuted,
          );
        }),
        elevation: 0,
        height: AppSizes.bottomNavHeight,
      ),

      // Cards
      cardTheme: const CardThemeData(
        color: AppColors.darkBgSurface,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bmd,
          side: BorderSide(color: AppColors.darkBorderDefault),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated button — primary (pill, 56 px)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primaryDim,
              disabledForegroundColor: AppColors.darkTextMuted,
              elevation: 0,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              textStyle: AppTextStyles.darkButton,
              animationDuration: AppDurations.instant,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.primaryDim.withAlpha(80);
                }
                return null;
              }),
            ),
      ),

      // Outlined button — ghost / back (pill, 56 px)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.darkBgElevated,
          foregroundColor: AppColors.darkTextPrimary,
          disabledForegroundColor: const Color.fromARGB(255, 58, 69, 85),
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          side: const BorderSide(color: AppColors.darkBorderDefault, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.darkButton,
          animationDuration: AppDurations.instant,
        ),
      ),

      // Text button — "Skip", "View All", inline links
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.darkLink,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          minimumSize: const Size(0, 48),
          animationDuration: AppDurations.instant,
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
        sizeConstraints: BoxConstraints.tightFor(
          width: AppSizes.fabSize,
          height: AppSizes.fabSize,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(color: AppColors.darkBorderDefault),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(color: AppColors.darkBorderDefault),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(color: AppColors.darkBorderActive, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(color: AppColors.darkBorderDanger, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(color: AppColors.darkBorderDanger, width: 1.5),
        ),
        hintStyle: AppTextStyles.darkBody.copyWith(
          color: AppColors.darkTextMuted,
        ),
        labelStyle: AppTextStyles.darkLabel,
        errorStyle: AppTextStyles.darkCaption.copyWith(
          color: AppColors.darkTextDanger,
        ),
        prefixIconColor: AppColors.darkTextMuted,
        suffixIconColor: AppColors.darkTextMuted,
      ),

      // Chip (filter chips, segmented tabs)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkBgElevated,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.darkBgElevated,
        labelStyle: AppTextStyles.darkBody.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        secondaryLabelStyle: AppTextStyles.darkBodyStrong.copyWith(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: const StadiumBorder(),
        elevation: 0,
        pressElevation: 0,
        side: BorderSide.none,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderDefault,
        thickness: 1,
        space: 0,
      ),

      // Switch (toggle row)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.darkBgElevated;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return AppColors.darkBorderDefault;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.darkBgElevated;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.darkBorderDefault, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkBgElevated,
        circularTrackColor: AppColors.darkBgElevated,
        linearMinHeight: 6,
      ),

      // Snack bar (toast/error)
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkBgElevated,
        contentTextStyle: AppTextStyles.darkBody.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.bmd),
        elevation: 0,
        showCloseIcon: true,
        closeIconColor: AppColors.darkTextSecondary,
        dismissDirection: DismissDirection.horizontal,
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkBgSurface,
        modalBackgroundColor: AppColors.darkBgSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
        elevation: 0,
        modalElevation: 0,
        dragHandleColor: AppColors.darkBorderDefault,
        dragHandleSize: Size(32, 4),
        showDragHandle: true,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkBgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.bxl),
        titleTextStyle: AppTextStyles.darkH3,
        contentTextStyle: AppTextStyles.darkBody,
      ),

      // List tile
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minLeadingWidth: AppSizes.iconContainerSize,
        iconColor: AppColors.darkTextSecondary,
        textColor: AppColors.darkTextPrimary,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: AppSizes.iconMd,
      ),

      // Text theme — map Material roles to Ridivo scale
      textTheme: _buildTextTheme(dark: true),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIGHT
  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData light() {
    const ColorScheme cs = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCEAFE), // light blue tint
      onPrimaryContainer: AppColors.primaryDim,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEFF6FF),
      onSecondaryContainer: AppColors.primaryDim,
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFDCFCE7),
      onTertiaryContainer: Color(0xFF14532D),
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: AppColors.dangerBright,
      surface: AppColors.lightBgSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerLowest: AppColors.lightBgBase,
      surfaceContainerLow: AppColors.lightBgBase,
      surfaceContainer: AppColors.lightBgSurface,
      surfaceContainerHigh: AppColors.lightBgElevated,
      surfaceContainerHighest: AppColors.lightBgOverlay,
      surfaceDim: AppColors.lightBgOverlay,
      surfaceBright: AppColors.lightBgBase,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightBorderDefault,
      outlineVariant: AppColors.lightBorderActive,
      scrim: Color(0x99000000),
      inverseSurface: AppColors.darkBgSurface,
      onInverseSurface: AppColors.darkTextPrimary,
      inversePrimary: AppColors.primaryLight,
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.lightBgBase,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBgBase,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.lightAppBarTitle,
        iconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary,
          size: AppSizes.iconMd,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary,
          size: AppSizes.iconMd,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBgSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightTextMuted,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightBgSurface,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? AppColors.primary : AppColors.lightTextMuted,
            size: AppSizes.iconMd,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppColors.primary : AppColors.lightTextMuted,
          );
        }),
        elevation: 0,
        height: AppSizes.bottomNavHeight,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightBgSurface,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bmd,
          side: BorderSide(color: AppColors.lightBorderDefault),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryDim,
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.lightButton,
          animationDuration: AppDurations.instant,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.lightBgElevated,
          foregroundColor: AppColors.lightTextPrimary,
          disabledForegroundColor: AppColors.lightTextMuted,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          side: const BorderSide(color: AppColors.lightBorderDefault),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.lightButton,
          animationDuration: AppDurations.instant,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.lightLink,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          minimumSize: const Size(0, 48),
          animationDuration: AppDurations.instant,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
        sizeConstraints: BoxConstraints.tightFor(
          width: AppSizes.fabSize,
          height: AppSizes.fabSize,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBgElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(color: AppColors.lightBorderDefault),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(color: AppColors.lightBorderDefault),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(
            color: AppColors.lightBorderActive,
            width: 1.5,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(
            color: AppColors.lightBorderDanger,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.bsm,
          borderSide: BorderSide(
            color: AppColors.lightBorderDanger,
            width: 1.5,
          ),
        ),
        hintStyle: AppTextStyles.lightBody.copyWith(
          color: AppColors.lightTextMuted,
        ),
        labelStyle: AppTextStyles.lightLabel,
        errorStyle: AppTextStyles.lightCaption.copyWith(
          color: AppColors.lightTextDanger,
        ),
        prefixIconColor: AppColors.lightTextMuted,
        suffixIconColor: AppColors.lightTextMuted,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBgElevated,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.lightBgElevated,
        labelStyle: AppTextStyles.lightBody.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        secondaryLabelStyle: AppTextStyles.lightBodyStrong.copyWith(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: const StadiumBorder(),
        elevation: 0,
        pressElevation: 0,
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderDefault,
        thickness: 1,
        space: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.lightBgOverlay;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return AppColors.lightBorderDefault;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.lightBgElevated;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.lightBorderDefault, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightBgElevated,
        circularTrackColor: AppColors.lightBgElevated,
        linearMinHeight: 6,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightBgSurface,
        contentTextStyle: AppTextStyles.lightBody.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.bmd),
        elevation: 0,
        showCloseIcon: true,
        closeIconColor: AppColors.lightTextSecondary,
        dismissDirection: DismissDirection.horizontal,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightBgSurface,
        modalBackgroundColor: AppColors.lightBgSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
        elevation: 0,
        modalElevation: 0,
        dragHandleColor: AppColors.lightBorderDefault,
        dragHandleSize: Size(32, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightBgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.bxl),
        titleTextStyle: AppTextStyles.lightH3,
        contentTextStyle: AppTextStyles.lightBody,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minLeadingWidth: AppSizes.iconContainerSize,
        iconColor: AppColors.lightTextSecondary,
        textColor: AppColors.lightTextPrimary,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightTextSecondary,
        size: AppSizes.iconMd,
      ),
      textTheme: _buildTextTheme(dark: false),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TEXT THEME BUILDER
  // Maps Material TextTheme roles to the Ridivo type scale.
  // ─────────────────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme({required bool dark}) {
    return TextTheme(
      // Display roles → Ridivo display / h1 / h2
      displayLarge: dark
          ? AppTextStyles.darkDisplay
          : AppTextStyles.lightDisplay,
      displayMedium: dark ? AppTextStyles.darkH1 : AppTextStyles.lightH1,
      displaySmall: dark ? AppTextStyles.darkH2 : AppTextStyles.lightH2,
      // Headline roles → Ridivo h3 / h4
      headlineLarge: dark ? AppTextStyles.darkH3 : AppTextStyles.lightH3,
      headlineMedium: dark ? AppTextStyles.darkH3 : AppTextStyles.lightH3,
      headlineSmall: dark ? AppTextStyles.darkH4 : AppTextStyles.lightH4,
      // Title roles → Ridivo h4 / body-strong
      titleLarge: dark ? AppTextStyles.darkH4 : AppTextStyles.lightH4,
      titleMedium: dark
          ? AppTextStyles.darkBodyStrong
          : AppTextStyles.lightBodyStrong,
      titleSmall: dark
          ? AppTextStyles.darkBodyStrong
          : AppTextStyles.lightBodyStrong,
      // Body roles → Ridivo body / caption
      bodyLarge: dark
          ? AppTextStyles.darkBodyStrong
          : AppTextStyles.lightBodyStrong,
      bodyMedium: dark ? AppTextStyles.darkBody : AppTextStyles.lightBody,
      bodySmall: dark ? AppTextStyles.darkCaption : AppTextStyles.lightCaption,
      // Label roles → Ridivo button / label / label-upper
      labelLarge: dark ? AppTextStyles.darkButton : AppTextStyles.lightButton,
      labelMedium: dark ? AppTextStyles.darkLabel : AppTextStyles.lightLabel,
      labelSmall: dark
          ? AppTextStyles.darkLabelUpper
          : AppTextStyles.lightLabelUpper,
    );
  }
}
