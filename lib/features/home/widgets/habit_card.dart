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
  bool _cardPressing = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (StreakService.isCompletedToday(widget.habit.completionDates)) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(HabitCard old) {
    super.didUpdateWidget(old);
    final isDone = StreakService.isCompletedToday(widget.habit.completionDates);
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
    await ref.read(habitProvider.notifier).toggleCompletion(widget.habit.id);
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
    final isDone = StreakService.isCompletedToday(habit.completionDates);

    return GestureDetector(
      onTap: () => context.push('/habit/${habit.id}'),
      onLongPress: _showOptions,
      onTapDown: (_) => setState(() => _cardPressing = true),
      onTapUp: (_) => setState(() => _cardPressing = false),
      onTapCancel: () => setState(() => _cardPressing = false),
      child: AnimatedScale(
        scale: _cardPressing ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppColors.kGlassBlur,
                sigmaY: AppColors.kGlassBlur,
              ),
              child: AnimatedBuilder(
                animation: _checkController,
                builder: (context, _) {
                  final t = _checkController.value;
                  return Container(
                    decoration: BoxDecoration(
                      // Subtle gradient tint from habit color
                      gradient: LinearGradient(
                        colors: [
                          Color.lerp(
                            habitColor.withAlpha(18),
                            habitColor.withAlpha(36),
                            t,
                          )!,
                          Color.lerp(
                            AppColors.kGlassWhite,
                            habitColor.withAlpha(10),
                            t,
                          )!,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Color.lerp(
                          AppColors.kGlassBorder,
                          habitColor.withAlpha(90),
                          t,
                        )!,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: habitColor.withAlpha((20 + t * 20).round()),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // Emoji with gradient background
                          _EmojiBadge(
                            emoji: habit.icon,
                            color: habitColor,
                            isDone: isDone,
                            t: t,
                          ),
                          const SizedBox(width: 14),
                          // Name + streak badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 16,
                                    color: Color.lerp(
                                      AppColors.kTextPrimary,
                                      Colors.white,
                                      t * 0.15,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                _StreakPill(
                                  streakCount: habit.streakCount,
                                  isDone: isDone,
                                  habitColor: habitColor,
                                  reminderTime: habit.reminderTime,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Completion button
                          _CompletionButton(
                            controller: _checkController,
                            pressing: _pressing,
                            onTapDown: (_) =>
                                setState(() => _pressing = true),
                            onTapUp: (_) =>
                                setState(() => _pressing = false),
                            onTapCancel: () =>
                                setState(() => _pressing = false),
                            onTap: _toggle,
                            isDone: isDone,
                            habitColor: habitColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: (widget.index * 80).ms)
        .fadeIn(duration: 380.ms)
        .slideY(begin: 0.14, duration: 380.ms, curve: Curves.easeOutCubic);
  }
}

class _EmojiBadge extends StatelessWidget {
  final String emoji;
  final Color color;
  final bool isDone;
  final double t;

  const _EmojiBadge({
    required this.emoji,
    required this.color,
    required this.isDone,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha((60 + t * 40).round()),
            color.withAlpha((30 + t * 20).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha((40 + t * 60).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((30 + t * 30).round()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int streakCount;
  final bool isDone;
  final Color habitColor;
  final String? reminderTime;

  const _StreakPill({
    required this.streakCount,
    required this.isDone,
    required this.habitColor,
    this.reminderTime,
  });

  String _formatTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final period = h < 12 ? 'AM' : 'PM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    final min = m.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    // Time chip
    if (reminderTime != null) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.kGlassWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.kGlassBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.alarm_rounded,
                  size: 10, color: AppColors.kTextSecondary),
              const SizedBox(width: 3),
              Text(
                _formatTime(reminderTime!),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Streak chip (always shown)
    if (streakCount > 0) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: streakCount >= 3
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)],
                  )
                : null,
            color: streakCount < 3 ? AppColors.kAccentAmber.withAlpha(26) : null,
            borderRadius: BorderRadius.circular(20),
            border: streakCount < 3
                ? Border.all(color: AppColors.kAccentAmber.withAlpha(77), width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                streakCount >= 3 ? '🔥' : '⚡',
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 3),
              Text(
                '$streakCount day${streakCount == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: streakCount >= 3 ? Colors.white : AppColors.kAccentAmber,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Done chip
    if (isDone) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.kAccentGreen.withAlpha(26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.kAccentGreen.withAlpha(77), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, size: 10, color: AppColors.kAccentGreen),
              SizedBox(width: 3),
              Text(
                'Done',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kAccentGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (chips.isEmpty) {
      return Text(
        'Start your streak today',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.kTextDisabled,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: chips,
    );
  }
}

class _CompletionButton extends StatelessWidget {
  final AnimationController controller;
  final bool pressing;
  final void Function(TapDownDetails) onTapDown;
  final void Function(TapUpDetails) onTapUp;
  final VoidCallback onTapCancel;
  final VoidCallback onTap;
  final bool isDone;
  final Color habitColor;

  const _CompletionButton({
    required this.controller,
    required this.pressing,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.onTap,
    required this.isDone,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onTap: onTap,
      child: AnimatedScale(
        scale: pressing ? 0.84 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value;
            final isDone = t > 0.5;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isDone
                        ? LinearGradient(
                            colors: [
                              AppColors.kAccentGreen,
                              AppColors.kAccentGreen.withAlpha(200),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: !isDone ? Colors.transparent : null,
                    border: t > 0.1
                        ? Border.all(
                            color: Color.lerp(
                              AppColors.kTextDisabled,
                              AppColors.kAccentGreen,
                              t,
                            )!,
                            width: 2,
                          )
                        : null,
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: AppColors.kAccentGreen
                                  .withAlpha((t * 80).round()),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: t > 0.1
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.white.withAlpha((t * 255).round()),
                            size: 22,
                          )
                        : Icon(
                            Icons.radio_button_unchecked_rounded,
                            color: AppColors.kTextSecondary,
                            size: 26,
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDone ? 'Done' : 'Mark\ndone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isDone
                        ? AppColors.kAccentGreen
                        : AppColors.kTextSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Options bottom sheet ───────────────────────────────────────────────────

class _OptionsSheet extends ConsumerWidget {
  final Habit habit;
  const _OptionsSheet({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitColor = Color(habit.colorValue);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.kGlassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.kTextDisabled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Habit identity header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: habitColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: Text(habit.icon,
                          style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Text(habit.name, style: AppTextStyles.heading3),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.kAccentPrimary.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded,
                  color: AppColors.kAccentPrimary, size: 18),
            ),
            title: const Text('Edit Habit', style: AppTextStyles.bodyMedium),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.kTextDisabled, size: 18),
            onTap: () {
              Navigator.pop(context);
              context.push('/habit/${habit.id}/edit');
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.kAccentRed.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_rounded,
                  color: AppColors.kAccentRed, size: 18),
            ),
            title: Text(
              'Delete Habit',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.kAccentRed),
            ),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.kTextDisabled, size: 18),
            onTap: () => _confirmDelete(context, ref),
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
              // Capture notifier + id before any pops dispose the widget/ref
              final notifier = ref.read(habitProvider.notifier);
              final id = habit.id;
              Navigator.pop(ctx);      // close dialog
              Navigator.pop(context);  // close bottom sheet
              notifier.deleteHabit(id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.kAccentRed)),
          ),
        ],
      ),
    );
  }
}
