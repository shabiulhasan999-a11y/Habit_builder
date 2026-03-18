import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StreakBanner extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;

  const StreakBanner({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppColors.kGlassBlur,
            sigmaY: AppColors.kGlassBlur,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.kGlassWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.kGlassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StreakStat(
                    emoji: '🔥',
                    label: 'Current Streak',
                    value: currentStreak,
                    valueColor: AppColors.kAccentAmber,
                    suffix: currentStreak == 1 ? 'day' : 'days',
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: AppColors.kGlassBorder,
                ),
                Expanded(
                  child: _StreakStat(
                    emoji: '🏆',
                    label: 'Best Streak',
                    value: bestStreak,
                    valueColor: AppColors.kAccentPrimary,
                    suffix: bestStreak == 1 ? 'day' : 'days',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;
  final Color valueColor;
  final String suffix;

  const _StreakStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$value',
              style: AppTextStyles.streakNumber.copyWith(color: valueColor),
            )
                .animate(key: ValueKey('streak_$value'))
                .shimmer(duration: 600.ms, color: valueColor.withAlpha(128)),
            const SizedBox(width: 4),
            Text(
              suffix,
              style: AppTextStyles.caption.copyWith(color: valueColor),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.captionSmall),
      ],
    );
  }
}
