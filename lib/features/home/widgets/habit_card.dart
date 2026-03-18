import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';
import '../../../services/streak_service.dart';

class HabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final int index;

  const HabitCard({
    super.key,
    required this.habit,
    required this.index,
  });

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    if (StreakService.isCompletedToday(widget.habit.completionDates)) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(HabitCard old) {
    super.didUpdateWidget(old);
    final isDone =
        StreakService.isCompletedToday(widget.habit.completionDates);
    if (isDone && _checkController.value < 1.0) {
      _checkController.forward();
    } else if (!isDone && _checkController.value > 0.0) {
      _checkController.reverse();
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    await ref
        .read(habitProvider.notifier)
        .toggleCompletion(widget.habit.id);
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(habit: widget.habit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final habitColor = Color(habit.colorValue);

    return GestureDetector(
      onTap: () => context.push('/habit/${habit.id}'),
      onLongPress: _showOptions,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppColors.kGlassBlur,
              sigmaY: AppColors.kGlassBlur,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.kGlassWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.kGlassBorder,
                  width: 1,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Left color accent bar
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: habitColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Emoji icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: habitColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          habit.icon,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Name + streak
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              habit.name,
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  '${habit.streakCount} day streak',
                                  style: AppTextStyles.caption.copyWith(
                                    color: habit.streakCount > 0
                                        ? AppColors.kAccentAmber
                                        : AppColors.kTextDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Completion button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _pressing = true),
                        onTapUp: (_) => setState(() => _pressing = false),
                        onTapCancel: () => setState(() => _pressing = false),
                        onTap: _toggle,
                        child: AnimatedScale(
                          scale: _pressing ? 0.88 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: AnimatedBuilder(
                            animation: _checkController,
                            builder: (context, child) {
                              final t = _checkController.value;
                              final bg = Color.lerp(
                                Colors.transparent,
                                AppColors.kAccentGreen,
                                t,
                              )!;
                              final borderColor = Color.lerp(
                                AppColors.kTextDisabled,
                                AppColors.kAccentGreen,
                                t,
                              )!;
                              return Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: bg,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: Opacity(
                                  opacity: t,
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: (widget.index * 80).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.12, duration: 350.ms, curve: Curves.easeOutCubic);
  }
}

class _OptionsSheet extends ConsumerWidget {
  final Habit habit;
  const _OptionsSheet({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kGlassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.kTextDisabled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.edit_rounded,
                color: AppColors.kAccentPrimary),
            title: const Text('Edit Habit',
                style: AppTextStyles.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              context.push('/habit/${habit.id}/edit');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading:
                const Icon(Icons.delete_rounded, color: AppColors.kAccentRed),
            title: Text(
              'Delete Habit',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kAccentRed),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, ref);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Delete "${habit.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.kAccentRed)),
          ),
        ],
      ),
    );
  }
}
