import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/habit_provider.dart';
import '../../services/streak_service.dart';
import 'widgets/completion_stats_row.dart';
import 'widgets/heatmap_calendar.dart';
import 'widgets/streak_banner.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitByIdProvider(habitId));

    if (habit == null) {
      return Scaffold(
        backgroundColor: AppColors.kBackground,
        body: const Center(
          child: Text('Habit not found', style: AppTextStyles.body),
        ),
      );
    }

    final habitColor = Color(habit.colorValue);
    final isDoneToday = StreakService.isCompletedToday(habit.completionDates);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.kBackground,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _HeroBackground(
                habitColor: habitColor,
                icon: habit.icon,
                name: habit.name,
                streak: habit.streakCount,
                isDone: isDoneToday,
              ),
            ),
            leading: _GlassButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
            ),
            actions: [
              _GlassButton(
                icon: Icons.edit_rounded,
                onTap: () => context.push('/habit/$habitId/edit'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreakBanner(
                    currentStreak: habit.streakCount,
                    bestStreak: habit.bestStreak,
                    habitColor: habitColor,
                  ),
                  const SizedBox(height: 16),
                  CompletionStatsRow(habit: habit),
                  const SizedBox(height: 28),
                  HeatmapCalendar(
                    completionDates: habit.completionDates,
                    habitColor: habitColor,
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isDoneToday
          ? _DoneButton(habitColor: habitColor)
              .animate()
              .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.easeOutBack)
              .fadeIn()
          : _MarkDoneButton(
              habitColor: habitColor,
              onPressed: () =>
                  ref.read(habitProvider.notifier).toggleCompletion(habitId),
            )
              .animate(delay: 100.ms)
              .slideY(begin: 0.5, duration: 350.ms, curve: Curves.easeOutCubic)
              .fadeIn(),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  final Color habitColor;
  final String icon;
  final String name;
  final int streak;
  final bool isDone;

  const _HeroBackground({
    required this.habitColor,
    required this.icon,
    required this.name,
    required this.streak,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient from habit color
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                habitColor.withAlpha(200),
                habitColor.withAlpha(60),
                AppColors.kBackground,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Noise texture overlay via radial glow
        Positioned(
          top: -60,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withAlpha(20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Centered content (visible when expanded)
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Large emoji in glowing circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(30),
                  border: Border.all(
                    color: Colors.white.withAlpha(60),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: habitColor.withAlpha(100),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              if (streak > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(50)),
                  ),
                  child: Text(
                    isDone
                        ? '🔥 $streak day streak · Done today!'
                        : '🔥 $streak day streak',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(50)),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkDoneButton extends StatelessWidget {
  final Color habitColor;
  final VoidCallback onPressed;

  const _MarkDoneButton({
    required this.habitColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [habitColor, habitColor.withAlpha(200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: habitColor.withAlpha(120),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Mark as Done',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  final Color habitColor;
  const _DoneButton({required this.habitColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kAccentGreen,
            const Color(0xFF34D399),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.kAccentGreen.withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          SizedBox(width: 8),
          Text(
            'Done Today! 🎉',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
