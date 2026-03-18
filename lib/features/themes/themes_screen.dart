import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/premium_provider.dart';
import '../../providers/theme_provider.dart';

class ThemesScreen extends ConsumerWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider);
    final current = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Premium Themes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your app theme',
              style: AppTextStyles.body.copyWith(
                color: AppColors.kTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.85,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: AppThemePreset.values.indexed.map((entry) {
                final (i, preset) = entry;
                final colors = themePresetColors[preset]!;
                final isDefault = preset == AppThemePreset.purple;
                final isLocked = !isPremium && !isDefault;
                final isSelected = current == preset;

                return _ThemeCard(
                  colors: colors,
                  isSelected: isSelected,
                  isLocked: isLocked,
                  onTap: () {
                    if (isLocked) {
                      context.push('/premium');
                      return;
                    }
                    ref.read(themeProvider.notifier).setTheme(preset);
                  },
                )
                    .animate(delay: (i * 80).ms)
                    .fadeIn()
                    .scale(begin: const Offset(0.9, 0.9));
              }).toList(),
            ),
            if (!isPremium) ...[
              const SizedBox(height: 32),
              _UpgradeBanner(onTap: () => context.push('/premium')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ThemeColors colors;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.colors,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : AppColors.kGlassBorder,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withAlpha(60),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Color preview circles
            _ColorPreview(colors: colors, isLocked: isLocked),
            const SizedBox(height: 12),
            Text(
              '${colors.emoji} ${colors.name}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 4),
            if (isLocked)
              _LockedBadge()
            else if (isSelected)
              _SelectedBadge(color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  final ThemeColors colors;
  final bool isLocked;

  const _ColorPreview({required this.colors, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background circle
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.background,
            border: Border.all(color: AppColors.kGlassBorder),
          ),
        ),
        // Primary color circle
        Positioned(
          left: -8,
          top: 8,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
            ),
          ),
        ),
        // Secondary color circle
        Positioned(
          right: -8,
          top: 8,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.secondary,
            ),
          ),
        ),
        if (isLocked)
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.kSurfaceVariant,
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 14,
                color: AppColors.kTextDisabled,
              ),
            ),
          ),
      ],
    );
  }
}

class _LockedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.kGlassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kGlassBorder),
      ),
      child: Text(
        '✨ Pro',
        style: AppTextStyles.captionSmall.copyWith(
          color: AppColors.kTextSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  final Color color;
  const _SelectedBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            'Active',
            style: AppTextStyles.captionSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _UpgradeBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.kAccentPrimary.withAlpha(38),
              AppColors.kAccentSecondary.withAlpha(20),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.kAccentPrimary.withAlpha(80),
          ),
        ),
        child: Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock all themes',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                  Text(
                    'Upgrade to Pro to access Ocean, Forest & Sunset',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.kAccentPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
