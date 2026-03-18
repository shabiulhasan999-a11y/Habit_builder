import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../services/streak_service.dart';

class HeatmapCalendar extends StatelessWidget {
  final List<String> completionDates;
  final Color habitColor;

  const HeatmapCalendar({
    super.key,
    required this.completionDates,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final completionSet = completionDates.toSet();
    final today = DateTime.now();
    // Align to the Monday of the current week then go back 51 more weeks = 52 weeks total
    final todayWeekday = today.weekday; // 1=Mon, 7=Sun
    final startOfThisWeek =
        today.subtract(Duration(days: todayWeekday - 1));
    final startDate = startOfThisWeek.subtract(const Duration(days: 51 * 7));

    const cellSize = 11.0;
    const cellGap = 2.5;
    const weeks = 52;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Last 52 Weeks',
            style: AppTextStyles.caption.copyWith(
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month labels row
              _MonthLabels(
                startDate: startDate,
                weeks: weeks,
                cellSize: cellSize,
                cellGap: cellGap,
              ),
              const SizedBox(height: 4),
              // Grid
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(
                    weeks * (cellSize + cellGap) - cellGap,
                    7 * (cellSize + cellGap) - cellGap,
                  ),
                  painter: _HeatmapPainter(
                    startDate: startDate,
                    today: today,
                    completionSet: completionSet,
                    habitColor: habitColor,
                    cellSize: cellSize,
                    cellGap: cellGap,
                    weeks: weeks,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Legend
              _Legend(habitColor: habitColor),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthLabels extends StatelessWidget {
  final DateTime startDate;
  final int weeks;
  final double cellSize;
  final double cellGap;

  const _MonthLabels({
    required this.startDate,
    required this.weeks,
    required this.cellSize,
    required this.cellGap,
  });

  @override
  Widget build(BuildContext context) {
    final cellTotal = cellSize + cellGap;
    final labels = <Widget>[];
    String? lastMonth;
    double xPos = 0;

    for (int col = 0; col < weeks; col++) {
      final date = startDate.add(Duration(days: col * 7));
      final monthName = _shortMonth(date.month);
      if (monthName != lastMonth) {
        labels.add(Positioned(
          left: xPos,
          child: Text(
            monthName,
            style: AppTextStyles.captionSmall.copyWith(fontSize: 10),
          ),
        ));
        lastMonth = monthName;
      }
      xPos += cellTotal;
    }

    return SizedBox(
      height: 14,
      width: weeks * cellTotal - cellGap,
      child: Stack(children: labels),
    );
  }

  String _shortMonth(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }
}

class _HeatmapPainter extends CustomPainter {
  final DateTime startDate;
  final DateTime today;
  final Set<String> completionSet;
  final Color habitColor;
  final double cellSize;
  final double cellGap;
  final int weeks;

  _HeatmapPainter({
    required this.startDate,
    required this.today,
    required this.completionSet,
    required this.habitColor,
    required this.cellSize,
    required this.cellGap,
    required this.weeks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellTotal = cellSize + cellGap;
    final todayOnly = DateTime(today.year, today.month, today.day);
    final paint = Paint()..isAntiAlias = true;

    for (int col = 0; col < weeks; col++) {
      for (int row = 0; row < 7; row++) {
        final date = startDate.add(Duration(days: col * 7 + row));
        final dateOnly = DateTime(date.year, date.month, date.day);
        if (dateOnly.isAfter(todayOnly)) continue;

        final dateStr = StreakService.dateString(date);
        final isDone = completionSet.contains(dateStr);
        final isToday = dateOnly == todayOnly;

        final left = col * cellTotal;
        final top = row * cellTotal;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cellSize, cellSize),
          const Radius.circular(2.5),
        );

        if (isDone) {
          paint.color = habitColor.withAlpha(220);
        } else {
          paint.color = AppColors.kHeatmapEmpty;
        }
        canvas.drawRRect(rect, paint);

        // Today indicator: small dot border
        if (isToday && !isDone) {
          paint.color = habitColor.withAlpha(128);
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 1.5;
          canvas.drawRRect(rect, paint);
          paint.style = PaintingStyle.fill;
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) {
    return old.completionSet.length != completionSet.length ||
        old.habitColor != habitColor;
  }
}

class _Legend extends StatelessWidget {
  final Color habitColor;
  const _Legend({required this.habitColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Less', style: AppTextStyles.captionSmall),
        const SizedBox(width: 6),
        ...List.generate(5, (i) {
          final opacity = i == 0 ? 0.15 : (i * 0.2 + 0.15);
          return Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: i == 0
                    ? AppColors.kHeatmapEmpty
                    : habitColor.withOpacity(opacity),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          );
        }),
        const SizedBox(width: 6),
        Text('More', style: AppTextStyles.captionSmall),
      ],
    );
  }
}
