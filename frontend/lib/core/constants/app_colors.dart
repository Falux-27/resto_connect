import 'package:flutter/material.dart';

/// Palette officielle Resto Connect Dakar
/// Extraite des maquettes iOS — JOJ 2026
abstract class AppColors {
  // ─── Backgrounds ───────────────────────────────────────────
  static const Color sand      = Color(0xFFE8E4DC); // fond app global
  static const Color white     = Color(0xFFFFFFFF);
  static const Color cardBg    = Color(0xFFF9F7F3); // fond des cards
  static const Color inputBg   = Color(0xFFF3F4F6); // fond search bar

  // ─── Brand ─────────────────────────────────────────────────
  static const Color orange    = Color(0xFFF97316); // CTA, icône IA, badge match
  static const Color orangeLight = Color(0xFFFFF7ED); // fond dish card recommandée
  static const Color teal      = Color(0xFF14B8A6); // AI banner, chip "Proche"
  static const Color tealLight = Color(0xFFE6FAF8); // fond AI hint banner

  // ─── Text ──────────────────────────────────────────────────
  static const Color ink       = Color(0xFF1F2937); // titres principaux
  static const Color body      = Color(0xFF374151); // texte courant
  static const Color muted     = Color(0xFF6B7280); // sous-titres, labels
  static const Color label     = Color(0xFF9CA3AF); // petits labels caps
  static const Color divider   = Color(0xFFE5E7EB);

  // ─── Tags ──────────────────────────────────────────────────
  static const Color halalBg   = Color(0xFFDCFCE7);
  static const Color halalText = Color(0xFF16A34A);
  static const Color vegeBg    = Color(0xFFF0FDF4);
  static const Color vegeText  = Color(0xFF15803D);
  static const Color tagBg     = Color(0xFFF3F4F6);
  static const Color tagText   = Color(0xFF374151);

  // ─── Stars / Rating ────────────────────────────────────────
  static const Color star      = Color(0xFFFBBF24);

  // ─── Match score ───────────────────────────────────────────
  static const Color matchBg   = Color(0xFF1F2937); // fond badge "88% match"
  static const Color matchText = Color(0xFFFFFFFF);
}