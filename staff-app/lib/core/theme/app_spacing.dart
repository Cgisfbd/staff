import 'package:flutter/material.dart';

/// Spacing and layout invariants matching the ERP web standard.
class AppSpacing {
  AppSpacing._();

  // Spacing scales
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Unified Corner Radius Law (Rule 8.3: 10.0 to 12.0 for cards/inputs)
  static const double radiusSm = 8.0;
  static const double radiusMd = 10.0; // 0.625rem in web
  static const double radiusLg = 12.0; // Standard ERP card radius
  static const double radiusXl = 16.0;
  static const double radiusSheet = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius roundedSheet = BorderRadius.only(
    topLeft: Radius.circular(radiusSheet),
    topRight: Radius.circular(radiusSheet),
  );
}
