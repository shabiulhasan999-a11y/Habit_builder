import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/premium_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  int _selectedPlan = 1; // 0 = monthly, 1 = annual

  static const _features = [
    ('🚀', 'Unlimited Habits', 'Track as many habits as you want'),
    ('🎨', 'Premium Themes', 'Unlock beautiful custom themes'),
    ('📊', 'Advanced Stats', 'Detailed insights and trends'),
    ('📤', 'Data Export', 'Export your data as CSV'),
  ];

  static const _plans = [
    ('Monthly', '\$2.99', '/month', false),
    ('Annual', '\$19.99', '/year · Best Value', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF0D0D1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.kTextSecondary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Crown icon
                      const Text(
                        '👑',
                        style: TextStyle(fontSize: 64),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 300.ms),
                      const SizedBox(height: 16),
                      Text(
                        'Unlock Premium',
                        style: AppTextStyles.heading1,
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text(
                        'Build unlimited habits and achieve your goals',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.kTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 32),
                      // Features list
                      ...List.generate(_features.length, (i) {
                        final (emoji, title, desc) = _features[i];
                        return _FeatureTile(
                          emoji: emoji,
                          title: title,
                          description: desc,
                        )
                            .animate(delay: (250 + i * 60).ms)
                            .fadeIn()
                            .slideX(begin: -0.1);
                      }),
                      const SizedBox(height: 28),
                      // Plan selector
                      Row(
                        children: List.generate(_plans.length, (i) {
                          final (name, price, detail, isBest) = _plans[i];
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: i == 0 ? 8 : 0,
                                left: i == 1 ? 8 : 0,
                              ),
                              child: _PlanCard(
                                name: name,
                                price: price,
                                detail: detail,
                                isBest: isBest,
                                isSelected: _selectedPlan == i,
                                onTap: () =>
                                    setState(() => _selectedPlan = i),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      // Continue button
                      _ContinueButton(
                        onPressed: () async {
                          await ref
                              .read(premiumProvider.notifier)
                              .unlock();
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Premium unlocked!'),
                            ),
                          );
                          // ignore: use_build_context_synchronously
                          context.pop();
                        },
                      ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Restore Purchases',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.kTextDisabled,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cancel anytime · Secure payment',
                        style: AppTextStyles.captionSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _FeatureTile({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.kAccentPrimary.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                Text(
                  description,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.kAccentGreen,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String detail;
  final bool isBest;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.detail,
    required this.isBest,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kAccentPrimary.withAlpha(38)
              : AppColors.kGlassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.kAccentPrimary
                : AppColors.kGlassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBest)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.kAccentAmber,
                      AppColors.kAccentRed,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            Text(name, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text(
              price,
              style: AppTextStyles.heading3.copyWith(
                color: isSelected
                    ? AppColors.kAccentPrimary
                    : AppColors.kTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: AppTextStyles.captionSmall.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ContinueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.kAccentPrimary,
              AppColors.kAccentSecondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.kAccentPrimary.withAlpha(100),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Continue ✨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
