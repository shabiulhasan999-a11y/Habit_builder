import 'package:share_plus/share_plus.dart';
import '../models/habit.dart';

class ExportService {
  ExportService._();

  static Future<void> exportCSV(List<Habit> habits) async {
    final buffer = StringBuffer();

    // Header row
    buffer.writeln(
      'Name,Icon,Created Date,Current Streak,Best Streak,'
      'Total Completions,Last Completed,All Completion Dates',
    );

    for (final h in habits) {
      final created = h.createdAt.toIso8601String().substring(0, 10);
      final total = h.completionDates.length;
      final sorted = [...h.completionDates]..sort();
      final last = sorted.isEmpty ? '' : sorted.last;
      final allDates = sorted.join(' | ');

      // Wrap fields with commas in quotes
      buffer.writeln(
        '"${h.name}","${h.icon}",$created,'
        '${h.streakCount},${h.bestStreak},$total,'
        '$last,"$allDates"',
      );
    }

    await Share.share(
      buffer.toString(),
      subject: 'Habit Builder — Data Export',
    );
  }
}
