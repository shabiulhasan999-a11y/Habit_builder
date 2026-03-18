import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit.dart';
import '../constants/app_constants.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HabitAdapter());
    await Hive.openBox<Habit>(AppConstants.kHiveHabitsBox);
    await Hive.openBox<bool>(AppConstants.kHivePremiumBox);
  }

  static Box<Habit> get habitsBox =>
      Hive.box<Habit>(AppConstants.kHiveHabitsBox);

  static Box<bool> get premiumBox =>
      Hive.box<bool>(AppConstants.kHivePremiumBox);
}
