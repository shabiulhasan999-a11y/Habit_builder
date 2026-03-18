import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Layered glow rings + emoji
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.kAccentPrimary.withAlpha(30),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.0, 1.0),
                        duration: 2500.ms,
                        curve: Curves.easeInOut,
                      ),
                  // Middle ring
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.kGlassWhite,
                      border: Border.all(
                        color: AppColors.kAccentPrimary.withAlpha(50),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Emoji
                  const Text(
                    '🌱',
                    style: TextStyle(fontSize: 48),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: 0,
                        end: -6,
                        duration: 2000.ms,
                        curve: Curves.easeInOut,
                      ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 28),
            Text(
              'No habits yet',
              style: AppTextStyles.heading2,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 400.ms),
            const SizedBox(height: 10),
            Text(
              'Tap the button below to add your\nfirst habit and start building streaks 🔥',
              style: AppTextStyles.body.copyWith(
                color: AppColors.kTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, duration: 400.ms),
            const SizedBox(height: 32),
            // Decorative feature pills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _FeaturePill(icon: '📊', label: 'Track streaks'),
                _FeaturePill(icon: '🗓️', label: 'Heatmap view'),
                _FeaturePill(icon: '🔔', label: 'Reminders'),
              ],
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.3, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.kGlassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kGlassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
