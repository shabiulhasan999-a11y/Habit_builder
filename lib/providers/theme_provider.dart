import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/hive/hive_service.dart';

enum AppThemePreset { purple, ocean, forest, sunset }

class ThemeColors {
  final String name;
  final String emoji;
  final Color primary;
  final Color secondary;
  final Color background;

  const ThemeColors({
    required this.name,
    required this.emoji,
    required this.primary,
    required this.secondary,
    required this.background,
  });
}

const themePresetColors = <AppThemePreset, ThemeColors>{
  AppThemePreset.purple: ThemeColors(
    name: 'Midnight',
    emoji: '🌙',
    primary: Color(0xFF7C3AED),
    secondary: Color(0xFF06B6D4),
    background: Color(0xFF0A0A0F),
  ),
  AppThemePreset.ocean: ThemeColors(
    name: 'Ocean',
    emoji: '🌊',
    primary: Color(0xFF0EA5E9),
    secondary: Color(0xFF06B6D4),
    background: Color(0xFF060F1A),
  ),
  AppThemePreset.forest: ThemeColors(
    name: 'Forest',
    emoji: '🌿',
    primary: Color(0xFF16A34A),
    secondary: Color(0xFF65A30D),
    background: Color(0xFF060F0A),
  ),
  AppThemePreset.sunset: ThemeColors(
    name: 'Sunset',
    emoji: '🌅',
    primary: Color(0xFFEA580C),
    secondary: Color(0xFFEF4444),
    background: Color(0xFF120A06),
  ),
};

class ThemeNotifier extends StateNotifier<AppThemePreset> {
  static const _key = 'theme_preset';

  ThemeNotifier() : super(_load());

  static AppThemePreset _load() {
    final stored = HiveService.settingsBox.get(_key);
    if (stored == null) return AppThemePreset.purple;
    return AppThemePreset.values.firstWhere(
      (e) => e.name == stored,
      orElse: () => AppThemePreset.purple,
    );
  }

  Future<void> setTheme(AppThemePreset preset) async {
    await HiveService.settingsBox.put(_key, preset.name);
    state = preset;
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, AppThemePreset>((ref) {
  return ThemeNotifier();
});

final themeColorsProvider = Provider<ThemeColors>((ref) {
  return themePresetColors[ref.watch(themeProvider)]!;
});
