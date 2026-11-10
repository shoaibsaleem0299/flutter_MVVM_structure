import 'package:flutter/material.dart';

/// Centralized color tokens for the application.
/// Provides base seeds, semantic accents, and light/dark color definitions.
class AppColors {
  const AppColors._();

  // Brand Seed
  static const seed = Color(0xFF3F51B5);

  // Semantic: Success
  static const success = Color(0xFF2E7D32);
  static const onSuccess = Color(0xFFFFFFFF);
  static const successContainer = Color(0xFFC8E6C9);
  static const onSuccessContainer = Color(0xFF1B5E20);

  // Semantic: Warning
  static const warning = Color(0xFFED6C02);
  static const onWarning = Color(0xFFFFFFFF);
  static const warningContainer = Color(0xFFFFE0B2);
  static const onSuccessWarning = Color(0xFFE65100);

  // Semantic: Info
  static const info = Color(0xFF0288D1);
  static const onInfo = Color(0xFFFFFFFF);
  static const infoContainer = Color(0xFFB3E5FC);
  static const onInfoContainer = Color(0xFF01579B);

  // Semantic: Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);

  // Neutrals: Light
  static const surfaceLight = Color(0xFFFDFCFF);
  static const backgroundLight = Color(0xFFFDFCFF);
  static const onSurfaceLight = Color(0xFF1A1C1E);
  static const outlineLight = Color(0xFF74777F);

  // Neutrals: Dark
  static const surfaceDark = Color(0xFF121316);
  static const backgroundDark = Color(0xFF121316);
  static const onSurfaceDark = Color(0xFFE2E2E6);
  static const outlineDark = Color(0xFF8E9099);
}
