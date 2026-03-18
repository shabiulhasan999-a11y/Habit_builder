import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/hive/hive_service.dart';
import '../core/notifications/notification_service.dart';
import '../models/habit.dart';
import '../services/streak_service.dart';

const _uuid = Uuid();

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super(_loadSorted());

  static List<Habit> _loadSorted() {
    return HiveService.habitsBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void _reload() {
    state = _loadSorted();
  }

  Future<void> addHabit({
    required String name,
    required int colorValue,
    required String icon,
    String? reminderTime,
  }) async {
    final habit = Habit()
      ..id = _uuid.v4()
      ..name = name
      ..colorValue = colorValue
      ..icon = icon
      ..createdAt = DateTime.now()
      ..streakCount = 0
      ..bestStreak = 0
      ..completionDates = []
      ..reminderTime = reminderTime;

    await HiveService.habitsBox.add(habit);

    if (reminderTime != null) {
      await NotificationService.instance.scheduleHabitReminder(habit);
    }

    _reload();
  }

  Future<void> updateHabit(Habit updated) async {
    // Find the stored habit and update fields in-place
    final box = HiveService.habitsBox;
    for (int i = 0; i < box.length; i++) {
      final h = box.getAt(i);
      if (h != null && h.id == updated.id) {
        h.name = updated.name;
        h.colorValue = updated.colorValue;
        h.icon = updated.icon;
        h.reminderTime = updated.reminderTime;
        await h.save();

        // Reschedule or cancel notification
        await NotificationService.instance.cancelHabitReminder(h.id);
        if (h.reminderTime != null) {
          await NotificationService.instance.scheduleHabitReminder(h);
        }
        break;
      }
    }
    _reload();
  }

  Future<void> deleteHabit(String id) async {
    await NotificationService.instance.cancelHabitReminder(id);
    final box = HiveService.habitsBox;
    for (int i = 0; i < box.length; i++) {
      final h = box.getAt(i);
      if (h != null && h.id == id) {
        await h.delete();
        break;
      }
    }
    _reload();
  }

  Future<void> toggleCompletion(String id) async {
    final box = HiveService.habitsBox;
    for (int i = 0; i < box.length; i++) {
      final h = box.getAt(i);
      if (h != null && h.id == id) {
        final today = StreakService.todayString();
        if (h.completionDates.contains(today)) {
          h.completionDates.remove(today);
        } else {
          h.completionDates.add(today);
        }
        h.streakCount = StreakService.calculateCurrentStreak(h.completionDates);
        h.bestStreak =
            max(h.bestStreak, StreakService.calculateBestStreak(h.completionDates));
        await h.save();
        break;
      }
    }
    _reload();
  }

  /// Recalculate streaks for all habits (called on app launch to handle midnight reset)
  Future<void> recalculateAllStreaks() async {
    final box = HiveService.habitsBox;
    for (int i = 0; i < box.length; i++) {
      final h = box.getAt(i);
      if (h != null) {
        final newStreak =
            StreakService.calculateCurrentStreak(h.completionDates);
        if (h.streakCount != newStreak) {
          h.streakCount = newStreak;
          await h.save();
        }
      }
    }
    _reload();
  }
}

final habitProvider =
    StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});

/// Convenience provider to get a single habit by id
final habitByIdProvider = Provider.family<Habit?, String>((ref, id) {
  final habits = ref.watch(habitProvider);
  try {
    return habits.firstWhere((h) => h.id == id);
  } catch (_) {
    return null;
  }
});
