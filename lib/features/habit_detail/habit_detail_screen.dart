import 'package:flutter/material.dart';
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
    final isDoneToday =
        StreakService.isCompletedToday(habit.completionDates);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.kBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      habitColor.withAlpha(179),
                      AppColors.kBackground,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 60, bottom: 14),
              title: Row(
                children: [
                  Text(
                    habit.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      habit.name,
                      style: AppTextStyles.heading3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => context.push('/habit/$habitId/edit'),
                tooltip: 'Edit',
              ),
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
          : _MarkDoneButton(
              habitColor: habitColor,
              onPressed: () => ref
                  .read(habitProvider.notifier)
                  .toggleCompletion(habitId),
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
          color: habitColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: habitColor.withAlpha(100),
              blurRadius: 20,
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
        color: AppColors.kAccentGreen.withAlpha(26),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.kAccentGreen, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.kAccentGreen, size: 22),
          SizedBox(width: 8),
          Text(
            'Done Today! 🎉',
            style: TextStyle(
              color: AppColors.kAccentGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
