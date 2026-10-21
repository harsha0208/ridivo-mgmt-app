import 'package:flutter/material.dart';

/// Design-system color tokens for Ridivo.
///
/// Dark palette: the canonical brand palette — deep navy surfaces, electric blue
/// primary, four semantic colors.
///
/// Light palette: an accessible inversion of the dark palette. The primary and
/// all semantic hues are identical; only the surface and text layers are
/// swapped to a slate-white hierarchy.
///
/// Source: ridivo-design-system/uploads/designSystem.md §2, §19, §20
abstract final class AppColors {
  // ─────────────────────────────────────────────────────────────────────────
  // SHARED (same in both themes)
  // ─────────────────────────────────────────────────────────────────────────

  // Brand / Primary
  static const Color primary = Color(0xFF258CF4);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDim = Color(0xFF1E3A8A);

  // Semantic — Success
  static const Color success = Color(0xFF22C55E);
  static const Color successDim = Color(0xFF14532D);
  static const Color successTeal = Color(0xFF0DA672); // health SOS / web success

  // Semantic — Warning
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDim = Color(0xFF78350F);

  // Semantic — Danger
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDim = Color(0xFF7F1D1D);
  static const Color dangerBright = Color(0xFFDC2626);

  // Icon container tints (identical across both themes)
  static const Color iconBgBlue = Color(0xFF1E3A8A);
  static const Color iconBgNeutral = Color(0xFF1E293B);
  static const Color iconBgOrange = Color(0xFF7C2D12);
  static const Color iconBgAmber = Color(0xFF78350F);
  static const Color iconBgPurple = Color(0xFF3B0764);

  // ─────────────────────────────────────────────────────────────────────────
  // DARK THEME
  // ─────────────────────────────────────────────────────────────────────────

  // Surfaces (3 layers — always go one level deeper for nested content)
  static const Color darkBgBase = Color(0xFF090D18); // Screen background
  static const Color darkBgSurface = Color(0xFF111827); // Cards, sheets, modals
  static const Color darkBgElevated = Color(0xFF1A2235); // Inputs, nested cards
  static const Color darkBgOverlay = Color(0xFF0D1321); // Map overlays

  // Text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(
    0xFF64748B,
  ); // Muted labels/hints — brighter for contrast on dark surfaces
  static const Color darkTextAccent = Color(0xFF3B82F6);
  static const Color darkTextSuccess = Color(0xFF22C55E);
  static const Color darkTextWarning = Color(0xFFF59E0B);
  static const Color darkTextDanger = Color(0xFFEF4444);

  // Borders
  static const Color darkBorderDefault = Color(0xFF1E293B);
  static const Color darkBorderActive = Color(0xFF2563EB);
  static const Color darkBorderDanger = Color(0xFFEF4444);

  // ─────────────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────────

  // Surfaces
  static const Color lightBgBase = Color(0xFFFFFFFF); // Screen background
  static const Color lightBgSurface = Color(0xFFF8FAFC); // Cards, sheets
  static const Color lightBgElevated = Color(
    0xFFF1F5F9,
  ); // Inputs, nested cards
  static const Color lightBgOverlay = Color(0xFFE2E8F0); // Overlays

  // Text
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightTextAccent = Color(0xFF2563EB);
  static const Color lightTextSuccess = Color(0xFF16A34A);
  static const Color lightTextWarning = Color(0xFFD97706);
  static const Color lightTextDanger = Color(0xFFDC2626);

  // Borders
  static const Color lightBorderDefault = Color(0xFFE2E8F0);
  static const Color lightBorderActive = Color(0xFF2563EB);
  static const Color lightBorderDanger = Color(0xFFEF4444);
}
