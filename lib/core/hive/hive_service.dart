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
    await Hive.openBox<String>(AppConstants.kHiveSettingsBox);
  }

  static Box<Habit> get habitsBox =>
      Hive.box<Habit>(AppConstants.kHiveHabitsBox);

  static Box<bool> get premiumBox =>
      Hive.box<bool>(AppConstants.kHivePremiumBox);

  static Box<String> get settingsBox =>
      Hive.box<String>(AppConstants.kHiveSettingsBox);

  static String? get userName =>
      settingsBox.get(AppConstants.kUserNameKey);

  static Future<void> setUserName(String name) =>
      settingsBox.put(AppConstants.kUserNameKey, name);
}
