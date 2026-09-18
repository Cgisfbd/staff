import 'package:flutter/material.dart';

/// Supreme FAANG-grade TaleemOne Black & Golden / Off-white & Golden palette.
/// Strictly compliant with:
/// - TaleemOne ERP Universal Constitution (AGENTS.md & STAFF_RULES.md)
/// - Liquid Crystal Glassmorphism Standard
/// - Zero Solid Cards Mandate & Pure Amber Gold System
class AppColors {
  AppColors._();

  // ─── SHARED GOLDEN AMBER ACCENTS (TaleemOne Signature) ───
  static const Color goldPrimary = Color(0xFFD97706); // Amber 600
  static const Color goldLight = Color(0xFFF59E0B);   // Amber 500
  static const Color goldBright = Color(0xFFFBBF24);  // Amber 400
  static const Color goldDark = Color(0xFFB45309);    // Amber 700
  static const Color goldChampagne = Color(0xFFFDE68A);// Soft Champagne Accent (Amber 200)
  static const Color goldGlow = Color(0xFFF59E0B);     // Luminous Amber Glow

  // ─── LIGHT MODE TOKENS (Warm Off-White & Golden) ───
  static const Color lightBg = Color(0xFFFAF7F2);      // Exact ERP Off-White Canvas
  static const Color lightBackground = Color(0xFFFAF7F2); // Alias for lightBg
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1E1B18);
  static const Color textLightPrimary = Color(0xFF1E1B18); // Alias
  static const Color lightTextSecondary = Color(0xFF6E665E);
  static const Color textLightSecondary = Color(0xFF6E665E); // Alias
  static const Color lightTextMuted = Color(0xFF9E968D);
  static const Color textLightMuted = Color(0xFF9E968D); // Alias

  // Light Liquid Crystal Glassmorphism Fills & Borders (Alpha-based)
  static const Color lightGlassSurface = Color(0x8CFFFFFF); // 55% translucent frosted crystal
  static final Color lightGlassFill = Colors.white.withValues(alpha: 0.55);
  static const Color lightGlassBorder = Color(0x59D97706);  // 35% luminous amber border
  static const Color lightGlassEmblem = Color(0xA6FFFFFF);  // 65% translucent pure glass
  static const Color lightModalSurface = Color(0xF7FFFFFF); // 97% frosted white
  static final Color lightInputFill = Colors.white.withValues(alpha: 0.70);

  // Light Ambient Glow Tokens
  static const Color lightGlowAmber = Color(0x29F59E0B); // 16% opacity Amber 500
  static const Color lightGlowRose = Color(0x18F59E0B);  // Harmonized warm amber-rose glow

  // ─── DARK MODE TOKENS (Deep Obsidian Black & Golden) ───
  static const Color darkBg = Color(0xFF0B0B0F);       // Pure Deep Obsidian Black
  static const Color darkBackground = Color(0xFF0B0B0F); // Alias for darkBg
  static const Color darkSurface = Color(0xFF14141B);
  static const Color darkTextPrimary = Color(0xFFF5F4F0);
  static const Color textDarkPrimary = Color(0xFFF5F4F0); // Alias
  static const Color darkTextSecondary = Color(0xFF9C978F);
  static const Color textDarkSecondary = Color(0xFF9C978F); // Alias
  static const Color darkTextMuted = Color(0xFF6B665F);
  static const Color textDarkMuted = Color(0xFF6B665F); // Alias

  // Dark Liquid Crystal Glassmorphism Fills & Borders (Alpha-based)
  static const Color darkGlassSurface = Color(0xA6161620); // 65% translucent frosted obsidian
  static final Color darkGlassFill = const Color(0xFF161620).withValues(alpha: 0.65);
  static const Color darkGlassBorder = Color(0x66F59E0B);  // 40% luminous gold border
  static const Color darkGlassEmblem = Color(0x3DFFFFFF);  // 24% translucent glass
  static const Color darkModalSurface = Color(0xF214141B); // 95% frosted obsidian
  static final Color darkInputFill = const Color(0xFF1A1A26).withValues(alpha: 0.75);

  // Dark Ambient Glow Tokens
  static const Color darkGlowAmber = Color(0x29B45309);  // 16% opacity Amber 700
  static const Color darkGlowOnyx = Color(0x4D000000);   // 30% deep shadow glow

  // ─── STATUS & UTILITY COLORS ───
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color statusPresent = Color(0xFF10B981);    // Emerald
  static const Color statusAbsent = Color(0xFFEF4444);     // Crimson Red
  static const Color statusLeave = Color(0xFFD97706);      // Amber Gold
  static const Color statusInfo = Color(0xFFF59E0B);       // Luminous Amber

  // Compatibility Brand Tokens & Aliases (Harmonized to TaleemOne Gold)
  static const Color charcoalDark = Color(0xFFD97706);     // Primary Golden Accent
  static const Color charcoalMedium = Color(0xFFB45309);   // Deep Amber Accent
  static const Color purplePrimary = Color(0xFFD97706);    // Harmonized
  static const Color purpleLight = Color(0xFFF59E0B);      // Harmonized
  static const Color emeraldPrimary = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF047857);
  static const Color amberPrimary = Color(0xFFD97706);
  static const Color amberDark = Color(0xFFB45309);
  static const Color rosePrimary = Color(0xFFEF4444);

  // Neutral Luxury Shadow
  static const Color webGlassShadow = Color(0x1F000000);
}
