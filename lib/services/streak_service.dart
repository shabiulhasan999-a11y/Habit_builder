class StreakService {
  StreakService._();

  /// Returns the current streak for the given list of completion date strings.
  /// Dates are in 'YYYY-MM-DD' format.
  static int calculateCurrentStreak(List<String> completionDates) {
    if (completionDates.isEmpty) return 0;

    final today = _dateOnly(DateTime.now());

    // Deduplicate and sort descending (most recent first)
    final sorted = completionDates
        .map(DateTime.parse)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final mostRecent = _dateOnly(sorted.first);
    final daysDiff = today.difference(mostRecent).inDays;

    // Streak is broken if last completion was 2+ days ago
    if (daysDiff > 1) return 0;

    int streak = 1;
    for (int i = 0; i < sorted.length - 1; i++) {
      final curr = _dateOnly(sorted[i]);
      final next = _dateOnly(sorted[i + 1]);
      if (curr.difference(next).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Returns the best (longest) streak across all history.
  static int calculateBestStreak(List<String> completionDates) {
    if (completionDates.isEmpty) return 0;

    final sorted = completionDates
        .map(DateTime.parse)
        .toSet()
        .toList()
      ..sort();

    int best = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff =
          _dateOnly(sorted[i]).difference(_dateOnly(sorted[i - 1])).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return best;
  }

  static bool isCompletedToday(List<String> completionDates) {
    return completionDates.contains(todayString());
  }

  static String todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String dateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
