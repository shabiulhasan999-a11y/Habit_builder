import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color kBackground = Color(0xFF0A0A0F);
  static const Color kSurface = Color(0xFF13131A);
  static const Color kSurfaceVariant = Color(0xFF1C1C28);

  // Glassmorphism
  static const Color kGlassWhite = Color(0x14FFFFFF);
  static const Color kGlassBorder = Color(0x33FFFFFF);
  static const double kGlassBlur = 18.0;

  // Accents
  static const Color kAccentPrimary = Color(0xFF7C3AED);
  static const Color kAccentSecondary = Color(0xFF06B6D4);
  static const Color kAccentGreen = Color(0xFF22C55E);
  static const Color kAccentAmber = Color(0xFFF59E0B);
  static const Color kAccentRed = Color(0xFFEF4444);

  // Text
  static const Color kTextPrimary = Color(0xFFF1F5F9);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kTextDisabled = Color(0xFF475569);

  // Heatmap
  static const Color kHeatmapEmpty = Color(0xFF1E293B);
  static const Color kHeatmapL1 = Color(0xFF312E81);
  static const Color kHeatmapL2 = Color(0xFF4338CA);
  static const Color kHeatmapL3 = Color(0xFF6366F1);
  static const Color kHeatmapL4 = Color(0xFF818CF8);

  // Habit color palette (10 swatches)
  static const List<int> kHabitPalette = [
    0xFF7C3AED, // violet
    0xFF2563EB, // blue
    0xFF0891B2, // cyan
    0xFF059669, // emerald
    0xFF65A30D, // lime
    0xFFD97706, // amber
    0xFFDC2626, // red
    0xFFDB2777, // pink
    0xFF6366F1, // indigo
    0xFF0F766E, // teal
  ];

  // Common emojis for habits
  static const List<String> kHabitEmojis = [
    '🏃', '💪', '🧘', '📚', '💧', '🥗', '😴', '🎯',
    '✍️', '🎵', '🏊', '🚴', '🧠', '💊', '🌿', '☕',
    '🍎', '🏋️', '🚶', '🧹', '💰', '🎨', '🌅', '🙏',
    '📱', '💻', '🎮', '🌙', '⭐', '❤️',
  ];
}
