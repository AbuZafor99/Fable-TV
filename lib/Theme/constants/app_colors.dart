import 'package:flutter/material.dart';

/// NimbusTV design tokens (dark cinematic) from the Claude Design handoff.
class TColors {
  TColors._();

  // ── Brand ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C5CFF); // Electric violet
  static const Color primaryDark = Color(0xFF6A49F2);
  static const Color primaryLight = Color(0xFFB9A6FF);
  static const Color accent = Color(0xFF19C39A); // Teal secondary

  // ── Backgrounds ──────────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF08080D); // App bg
  static const Color bgSheet = Color(0xFF0D0D15); // Bottom sheets
  static const Color bgCard = Color(0xFF14141F); // Card surface
  static const Color bgElevated = Color(0xFF1B1B29); // Elevated card
  static const Color bgCard3 = Color(0xFF23232F);

  // ── Text ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF3F2F8);
  static const Color textSecondary = Color(0xFF9D9AB2); // muted
  static const Color textDisabled = Color(0xFF6A677E); // faint

  // ── Status ───────────────────────────────────────────────────────────
  static const Color live = Color(0xFFFF5468); // LIVE badge
  static const Color online = Color(0xFF19E3B1);
  static const Color warning = Color(0xFFFFD166);
  static const Color offline = Color(0xFF636366);
  static const Color hd = Color(0xFF4C8DFF); // HD badge

  // ── UI ───────────────────────────────────────────────────────────────
  static const Color divider = Color(0x12FFFFFF); // ~7% white
  static const Color dividerStrong = Color(0x1FFFFFFF); // ~12% white
  static const Color shimmerBase = Color(0xFF14141F);
  static const Color shimmerHighlight = Color(0xFF23232F);
  static const Color mapDot = Color(0xFF3A3550);
}
