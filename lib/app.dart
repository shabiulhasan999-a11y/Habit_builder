import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/habit_provider.dart';

class HabitApp extends ConsumerStatefulWidget {
  const HabitApp({super.key});

  @override
  ConsumerState<HabitApp> createState() => _HabitAppState();
}

class _HabitAppState extends ConsumerState<HabitApp> {
  @override
  void initState() {
    super.initState();
    // Recalculate all streaks on app launch (handles midnight reset)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitProvider.notifier).recalculateAllStreaks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Habit Builder',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
