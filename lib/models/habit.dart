import 'package:hive_flutter/hive_flutter.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int colorValue;

  @HiveField(3)
  late String icon;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late int streakCount;

  @HiveField(6)
  late int bestStreak;

  @HiveField(7)
  late List<String> completionDates;

  @HiveField(8)
  String? reminderTime;

  Habit copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? icon,
    DateTime? createdAt,
    int? streakCount,
    int? bestStreak,
    List<String>? completionDates,
    String? reminderTime,
    bool clearReminder = false,
  }) {
    final h = Habit()
      ..id = id ?? this.id
      ..name = name ?? this.name
      ..colorValue = colorValue ?? this.colorValue
      ..icon = icon ?? this.icon
      ..createdAt = createdAt ?? this.createdAt
      ..streakCount = streakCount ?? this.streakCount
      ..bestStreak = bestStreak ?? this.bestStreak
      ..completionDates = completionDates ?? List.from(this.completionDates)
      ..reminderTime = clearReminder ? null : (reminderTime ?? this.reminderTime);
    return h;
  }
}
