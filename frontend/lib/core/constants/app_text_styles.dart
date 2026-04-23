import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // ─── Display ───────────────────────────────────────────────
  /// "Qu'est-ce qu'on mange à Dakar ?" — titre hero
  static TextStyle get heroTitle => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        height: 1.15,
        letterSpacing: -0.5,
      );

  // ─── Headings ──────────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.25,
      );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get h3 => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color.fromARGB(255, 21, 21, 22),
      );

  // ─── Body ──────────────────────────────────────────────────
  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.body,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.body,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.4,
      );

  // ─── Labels ────────────────────────────────────────────────
  /// "BONJOUR " — label caps en haut
  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.label,
        letterSpacing: 1.2,
      );

  static TextStyle get labelCaps => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.orange,
        letterSpacing: 1.4,
      );

  // ─── Prix ──────────────────────────────────────────────────
  static TextStyle get price => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get priceSmall => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      );

  // ─── Input ─────────────────────────────────────────────────
  static TextStyle get inputHint => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
      );

  static TextStyle get inputText => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      );

  // ─── Boutons ───────────────────────────────────────────────
  static TextStyle get button => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  // ─── Rating ────────────────────────────────────────────────
  static TextStyle get rating => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );
}