import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StreakBanner extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;
  final Color? habitColor;

  const StreakBanner({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = habitColor ?? AppColors.kAccentPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppColors.kGlassBlur,
            sigmaY: AppColors.kGlassBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withAlpha(30),
                  AppColors.kGlassWhite,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accent.withAlpha(60),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StreakStat(
                    emoji: '🔥',
                    label: 'Current Streak',
                    value: currentStreak,
                    valueColor: currentStreak > 0
                        ? AppColors.kAccentAmber
                        : AppColors.kTextSecondary,
                    suffix: currentStreak == 1 ? 'day' : 'days',
                    highlight: currentStreak > 0,
                  ),
                ),
                Container(
                  width: 1,
                  height: 64,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  color: accent.withAlpha(40),
                ),
                Expanded(
                  child: _StreakStat(
                    emoji: '🏆',
                    label: 'Best Streak',
                    value: bestStreak,
                    valueColor: bestStreak > 0
                        ? accent
                        : AppColors.kTextSecondary,
                    suffix: bestStreak == 1 ? 'day' : 'days',
                    highlight: bestStreak > 0,
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
  final bool highlight;

  const _StreakStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.suffix,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: highlight ? 28 : 22),
          )
              .animate(
                onPlay: highlight ? (c) => c.repeat(reverse: true) : null,
              )
              .scale(
                begin: const Offset(1, 1),
                end: highlight ? const Offset(1.1, 1.1) : const Offset(1, 1),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: AppTextStyles.streakNumber.copyWith(
                  color: valueColor,
                  fontSize: 34,
                ),
              )
                  .animate(key: ValueKey('streak_${label}_$value'))
                  .shimmer(
                    duration: 700.ms,
                    color: valueColor.withAlpha(highlight ? 180 : 0),
                  ),
              const SizedBox(width: 4),
              Text(
                suffix,
                style: AppTextStyles.caption.copyWith(color: valueColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: highlight ? AppColors.kTextSecondary : AppColors.kTextDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
