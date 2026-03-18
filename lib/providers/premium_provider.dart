import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/hive/hive_service.dart';
import '../core/constants/app_constants.dart';

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier()
      : super(
          HiveService.premiumBox
                  .get(AppConstants.kPremiumKey, defaultValue: false) ??
              false,
        );

  Future<void> unlock() async {
    await HiveService.premiumBox.put(AppConstants.kPremiumKey, true);
    state = true;
  }

  Future<void> revoke() async {
    await HiveService.premiumBox.put(AppConstants.kPremiumKey, false);
    state = false;
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier();
});
