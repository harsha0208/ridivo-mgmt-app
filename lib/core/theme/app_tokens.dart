import 'package:flutter/material.dart';

/// Spacing tokens — 4pt grid, no exceptions.
/// Source: designSystem.md §1
abstract final class AppSpacing {
  static const double xs = 4;   // Tight internal gaps
  static const double sm = 8;   // Label-to-value, icon gap
  static const double mdSm = 12; // Card internal padding vertical
  static const double md = 16;  // Screen horizontal padding, card padding
  static const double mdLg = 20; // Between sections inside cards
  static const double lg = 24;  // Between major sections
  static const double xl = 32;  // Large section gaps, hero spacing
  static const double xxl = 48; // Screen breathing room (top/bottom)

  // Derived layout rules
  static const double screenHorizontalPadding = md;
  static const double cardPaddingHorizontal = md;
  static const double cardPaddingVertical = mdSm;
  static const double sectionGap = lg;
  static const double cardGap = md;
  static const double iconTextGap = mdSm;
  static const double labelValueGap = xs;
  static const double bottomNavClearance = 80;

  // Common EdgeInsets
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: mdSm);
  static const EdgeInsets cardPaddingFull =
      EdgeInsets.all(md);
  static const EdgeInsets statChipPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: mdSm);
}

/// Border radius tokens. Source: designSystem.md §4
abstract final class AppRadius {
  static const double xs = 4;   // Badges, progress segments
  static const double sm = 8;   // Inputs, small chips, icon squircle
  static const double md = 12;  // Standard cards, notification rows
  static const double lg = 16;  // Large feature cards, map containers
  static const double xl = 20;  // Bottom sheets, modals (top corners only)
  static const double full = 999; // Pills, FAB, avatars, circular icon containers

  // BorderRadius helpers
  static const BorderRadius bxs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius bsm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius bmd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius blg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius bxl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius bfull = BorderRadius.all(Radius.circular(full));

  /// Bottom-sheet: only top corners rounded
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );
}

/// Elevation / shadow tokens. Source: designSystem.md §5
abstract final class AppShadows {
  /// Base surface cards: no shadow — use border instead.
  static const List<BoxShadow> none = [];

  /// Elevated cards, bottom sheets.
  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x66000000), // #000000 @ 40%
      blurRadius: 24,
      offset: Offset(0, -4),
    ),
  ];

  /// Map overlay cards (speed, weather).
  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: Color(0x99000000), // #000000 @ 60%
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Floating action button — blue glow.
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x66258CF4), // primary @ 40%
      blurRadius: 16,
      spreadRadius: 2,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A258CF4), // primary @ 10%
      blurRadius: 0,
      spreadRadius: 2,
    ),
  ];

  /// Tooltip / popup.
  static const List<BoxShadow> tooltip = [
    BoxShadow(
      color: Color(0xB3000000), // #000000 @ 70%
      blurRadius: 20,
    ),
  ];
}

/// Motion / animation duration tokens. Source: designSystem.md §24
abstract final class AppDurations {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration page = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xslow = Duration(milliseconds: 1200);
}

/// Easing curve tokens. Source: designSystem.md §24
abstract final class AppCurves {
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve decelerate = Curves.decelerate;
  // elasticOut with custom damping is approximated via Curves.elasticOut
  static const Curve spring = Curves.elasticOut;
  static const Curve linear = Curves.linear;
}

/// Component-dimension constants. Source: designSystem.md §6, §7, §9
abstract final class AppSizes {
  // Buttons
  static const double buttonHeight = 56;
  static const double buttonSmallHeight = 36;
  static const double buttonDashedHeight = 48;

  // Input fields
  static const double inputHeight = 56;

  // OTP digit box
  static const double otpBoxWidth = 52;
  static const double otpBoxHeight = 60;

  // Bottom navigation
  static const double bottomNavHeight = 64;

  // AppBar
  static const double appBarHeight = 56;

  // FAB
  static const double fabSize = 56;

  // Avatar sizes
  static const double avatarXs = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 48;
  static const double avatarXl = 80;

  // Icon container
  static const double iconContainerSize = 40;

  // Icons
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;

  // Map controls
  static const double mapControlSize = 40;

  // Notification unread dot
  static const double unreadDot = 8;

  // Step progress bar segments
  static const double progressSegmentHeight = 4;
  static const double progressBarHeight = 6;

  // Bottom sheet snap heights (fraction of screen)
  static const double sheetCollapsedFraction = 0.40;
  static const double sheetExpandedFraction = 0.70;
}
