import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/hive/hive_service.dart';
import '../../providers/habit_provider.dart';
import '../../providers/premium_provider.dart';
import '../../services/streak_service.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/habit_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final isPremium = ref.watch(premiumProvider);

    final completedCount =
        habits.where((h) => StreakService.isCompletedToday(h.completionDates)).length;
    final allDone = habits.isNotEmpty && completedCount == habits.length;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Stack(
        children: [
          // Ambient glow overlays
          Positioned(
            top: -80,
            left: -60,
            child: _GlowOrb(
              color: AppColors.kAccentPrimary.withAlpha(40),
              size: 260,
            ),
          ),
          Positioned(
            top: -40,
            right: -80,
            child: _GlowOrb(
              color: const Color(0xFF06B6D4).withAlpha(28), // cyan
              size: 220,
            ),
          ),
          if (allDone)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _GlowOrb(
                color: AppColors.kAccentGreen.withAlpha(22),
                size: 300,
              ),
            ),
          // Main scroll content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 64, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Today's Habits",
                          style: AppTextStyles.heading1,
                        ),
                        if (habits.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _ProgressBar(
                            completed: completedCount,
                            total: habits.length,
                            allDone: allDone,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded),
                    tooltip: 'Stats',
                    onPressed: () => context.push('/stats'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.palette_rounded),
                    tooltip: 'Themes',
                    onPressed: () => context.push('/themes'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: isPremium
                        ? _ProBadge()
                        : _GoProButton(
                            onPressed: () => context.push('/premium'),
                          ),
                  ),
                ],
              ),
              if (habits.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(top: 4, bottom: 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => HabitCard(
                        habit: habits[index],
                        index: index,
                      ),
                      childCount: habits.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: _GradientFab(
        onPressed: () => context.push('/habit/new'),
      )
          .animate(delay: 200.ms)
          .slideY(begin: 1, duration: 400.ms, curve: Curves.easeOutCubic)
          .fadeIn(),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    final name = HiveService.userName;
    final suffix = name != null && name.isNotEmpty ? ', $name' : '';
    if (hour < 12) return 'Good morning$suffix 🌅';
    if (hour < 17) return 'Good afternoon$suffix ☀️';
    return 'Good evening$suffix 🌙';
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  final bool allDone;

  const _ProgressBar({
    required this.completed,
    required this.total,
    required this.allDone,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              allDone ? 'All done! 🎉' : '$completed of $total completed',
              style: AppTextStyles.caption.copyWith(
                color: allDone
                    ? AppColors.kAccentGreen
                    : AppColors.kTextSecondary,
                fontWeight: allDone ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.kTextDisabled,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 4,
                color: AppColors.kGlassWhite,
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: allDone
                          ? [AppColors.kAccentGreen, const Color(0xFF34D399)]
                          : [AppColors.kAccentPrimary, AppColors.kAccentSecondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (allDone ? AppColors.kAccentGreen : AppColors.kAccentPrimary)
                            .withAlpha(120),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoProButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoProButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.kAccentPrimary, AppColors.kAccentSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.kAccentPrimary.withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✨', style: TextStyle(fontSize: 12)),
            SizedBox(width: 4),
            Text(
              'Go Pro',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.kAccentPrimary.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.kAccentPrimary.withAlpha(80),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('✨', style: TextStyle(fontSize: 12)),
          SizedBox(width: 4),
          Text(
            'Pro',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.kAccentPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _GradientFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.kAccentPrimary, AppColors.kAccentSecondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
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
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Add Habit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Decorative spinning arc used on empty state (exported for reuse)
class ArcPainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final double strokeWidth;

  const ArcPainter({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(ArcPainter old) =>
      old.color != color ||
      old.startAngle != startAngle ||
      old.sweepAngle != sweepAngle;
}
