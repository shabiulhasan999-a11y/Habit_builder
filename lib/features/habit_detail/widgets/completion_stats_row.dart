import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/habit.dart';
import '../../../services/streak_service.dart';

class CompletionStatsRow extends StatelessWidget {
  final Habit habit;

  const CompletionStatsRow({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final total = habit.completionDates.length;
    final thisWeek = _countThisWeek();
    final rate = _completionRate();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total',
              value: '$total',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.kAccentGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'This Week',
              value: '$thisWeek',
              icon: Icons.calendar_today_rounded,
              color: AppColors.kAccentSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Rate',
              value: '$rate%',
              icon: Icons.trending_up_rounded,
              color: AppColors.kAccentPrimary,
            ),
          ),
        ],
      ),
    );
  }

  int _countThisWeek() {
    final now = DateTime.now();
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      if (habit.completionDates.contains(StreakService.dateString(d))) {
        count++;
      }
    }
    return count;
  }

  int _completionRate() {
    final created = habit.createdAt;
    final now = DateTime.now();
    final days = now.difference(created).inDays + 1;
    if (days <= 0) return 0;
    return ((habit.completionDates.length / days) * 100).round().clamp(0, 100);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: color, fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.captionSmall),
        ],
      ),
    );
  }
}
