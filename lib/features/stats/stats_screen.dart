import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/habit_provider.dart';
import '../../providers/premium_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/export_service.dart';
import '../../services/streak_service.dart';
import '../../models/habit.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final isPremium = ref.watch(premiumProvider);
    final themeColors = ref.watch(themeColorsProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Advanced Stats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isPremium && habits.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: 'Export CSV',
              onPressed: () => ExportService.exportCSV(habits),
            ),
        ],
      ),
      body: habits.isEmpty
          ? _EmptyState()
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryRow(habits: habits, accentColor: themeColors.primary),
                      const SizedBox(height: 28),
                      _SectionTitle(title: 'Last 7 Days'),
                      const SizedBox(height: 16),
                      _WeeklyChart(
                        habits: habits,
                        accentColor: themeColors.primary,
                      ),
                      const SizedBox(height: 28),
                      _SectionTitle(title: 'Per-Habit Breakdown'),
                      const SizedBox(height: 12),
                      ...List.generate(habits.length, (i) {
                        return _HabitStatRow(
                          habit: habits[i],
                          index: i,
                        ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.05);
                      }),
                    ],
                  ),
                ),
                // Paywall overlay if not premium
                if (!isPremium)
                  Positioned.fill(
                    child: _PaywallOverlay(
                      onUpgrade: () => context.push('/premium'),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ──────────────────────────────────────────────
// Summary row — 4 stat tiles
// ──────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final List<Habit> habits;
  final Color accentColor;

  const _SummaryRow({required this.habits, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final totalCompletions =
        habits.fold<int>(0, (sum, h) => sum + h.completionDates.length);
    final bestStreak =
        habits.fold<int>(0, (best, h) => math.max(best, h.bestStreak));
    final weekRate = _weeklyRate(habits);
    final activeStreaks = habits.where((h) => h.streakCount > 0).length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatTile(
          label: 'Total Completions',
          value: '$totalCompletions',
          icon: Icons.check_circle_rounded,
          color: AppColors.kAccentGreen,
        ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),
        _StatTile(
          label: 'Best Streak',
          value: '$bestStreak days',
          icon: Icons.local_fire_department_rounded,
          color: AppColors.kAccentAmber,
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        _StatTile(
          label: 'This Week',
          value: '${weekRate.round()}%',
          icon: Icons.calendar_today_rounded,
          color: accentColor,
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
        _StatTile(
          label: 'Active Streaks',
          value: '$activeStreaks',
          icon: Icons.bolt_rounded,
          color: AppColors.kAccentSecondary,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
      ],
    );
  }

  double _weeklyRate(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    final today = DateTime.now();
    int completions = 0;
    for (int d = 0; d < 7; d++) {
      final day = today.subtract(Duration(days: d));
      final s = StreakService.dateString(day);
      completions += habits.where((h) => h.completionDates.contains(s)).length;
    }
    return (completions / (habits.length * 7)) * 100;
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
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
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kGlassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.heading3.copyWith(color: color),
              ),
              Text(
                label,
                style: AppTextStyles.captionSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 7-day bar chart
// ──────────────────────────────────────────────
class _WeeklyChart extends StatelessWidget {
  final List<Habit> habits;
  final Color accentColor;

  const _WeeklyChart({required this.habits, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final rates = days.map((d) {
      final s = StreakService.dateString(d);
      final done = habits.where((h) => h.completionDates.contains(s)).length;
      return habits.isEmpty ? 0.0 : done / habits.length;
    }).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kGlassBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _BarChartPainter(rates: rates, color: accentColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((d) {
              const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
              final isToday = StreakService.dateString(d) ==
                  StreakService.dateString(DateTime.now());
              return Text(
                labels[d.weekday - 1],
                style: AppTextStyles.captionSmall.copyWith(
                  color: isToday
                      ? accentColor
                      : AppColors.kTextDisabled,
                  fontWeight:
                      isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> rates;
  final Color color;

  _BarChartPainter({required this.rates, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / rates.length;
    final maxBarH = size.height;
    final paint = Paint()..isAntiAlias = true;

    for (int i = 0; i < rates.length; i++) {
      final rate = rates[i];
      final x = i * barWidth + barWidth * 0.2;
      final w = barWidth * 0.6;
      final barH = math.max(rate * maxBarH, rate > 0 ? 4.0 : 0.0);

      // Background bar
      paint.color = AppColors.kGlassWhite;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, w, maxBarH),
          const Radius.circular(4),
        ),
        paint,
      );

      // Filled bar
      if (barH > 0) {
        paint.color = color.withAlpha((rate * 220 + 35).round().clamp(0, 255));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, maxBarH - barH, w, barH),
            const Radius.circular(4),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.rates != rates || old.color != color;
}

// ──────────────────────────────────────────────
// Per-habit breakdown row
// ──────────────────────────────────────────────
class _HabitStatRow extends StatelessWidget {
  final Habit habit;
  final int index;

  const _HabitStatRow({required this.habit, required this.index});

  @override
  Widget build(BuildContext context) {
    final total = habit.completionDates.length;
    // Completion rate over days since creation (capped at 30d)
    final daysSince = DateTime.now().difference(habit.createdAt).inDays + 1;
    final window = math.min(daysSince, 30);
    final recentCompletions = _recentCompletions(habit, window);
    final rate = window == 0 ? 0.0 : recentCompletions / window;
    final habitColor = Color(habit.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.kGlassBorder),
      ),
      child: Row(
        children: [
          // Emoji badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: habitColor.withAlpha(38),
            ),
            child: Center(
              child: Text(habit.icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        habit.name,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(rate * 100).round()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: habitColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      Container(height: 4, color: AppColors.kGlassWhite),
                      FractionallySizedBox(
                        widthFactor: rate.clamp(0.0, 1.0),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: habitColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total completions · ${habit.streakCount > 0 ? '🔥 ${habit.streakCount} day streak' : 'No active streak'}',
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _recentCompletions(Habit h, int days) {
    final today = DateTime.now();
    int count = 0;
    for (int d = 0; d < days; d++) {
      final s = StreakService.dateString(today.subtract(Duration(days: d)));
      if (h.completionDates.contains(s)) count++;
    }
    return count;
  }
}

// ──────────────────────────────────────────────
// Paywall overlay
// ──────────────────────────────────────────────
class _PaywallOverlay extends StatelessWidget {
  final VoidCallback onUpgrade;
  const _PaywallOverlay({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.kBackground.withAlpha(0),
            AppColors.kBackground.withAlpha(200),
            AppColors.kBackground,
          ],
          stops: const [0.0, 0.35, 0.55],
        ),
      ),
      child: Align(
        alignment: const Alignment(0, 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📊', style: TextStyle(fontSize: 48))
                .animate()
                .scale(begin: const Offset(0.7, 0.7), duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 12),
            Text(
              'Advanced Stats',
              style: AppTextStyles.heading2,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Pro to see detailed insights,\ncharts, and export your data.',
              style: AppTextStyles.body.copyWith(color: AppColors.kTextSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onUpgrade,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.kAccentPrimary, AppColors.kAccentSecondary],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kAccentPrimary.withAlpha(100),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'Unlock Advanced Stats ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Add habits to see your stats',
        style: AppTextStyles.body.copyWith(color: AppColors.kTextSecondary),
      ),
    );
  }
}
