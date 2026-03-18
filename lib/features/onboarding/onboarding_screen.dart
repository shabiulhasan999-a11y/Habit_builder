import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/hive/hive_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final trimmed = _controller.text.trim();
      setState(() => _canContinue = trimmed.isNotEmpty && trimmed.length <= 30);
    });
    // Auto-focus after animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    await HiveService.setUserName(name);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60,
            left: -60,
            child: _buildGlow(AppColors.kAccentPrimary.withAlpha(50), 280),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _buildGlow(const Color(0xFF06B6D4).withAlpha(30), 240),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // App icon / emoji
                  Text('🌱', style: const TextStyle(fontSize: 52))
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to\nHabit Builder',
                    style: AppTextStyles.heading1.copyWith(fontSize: 32, height: 1.15),
                  )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.15),
                  const SizedBox(height: 12),
                  Text(
                    'Build lasting habits, one day at a time.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.kTextSecondary,
                    ),
                  )
                      .animate(delay: 180.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.15),
                  const SizedBox(height: 52),
                  Text(
                    "What's your name?",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kTextSecondary,
                      fontSize: 13,
                    ),
                  )
                      .animate(delay: 280.ms)
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 10),
                  _NameField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmit: _canContinue ? _continue : null,
                  )
                      .animate(delay: 320.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.1),
                  const Spacer(),
                  _ContinueButton(
                    enabled: _canContinue,
                    onPressed: _continue,
                  )
                      .animate(delay: 450.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onSubmit;

  const _NameField({
    required this.controller,
    required this.focusNode,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kGlassWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kGlassBorder, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textCapitalization: TextCapitalization.words,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 18,
          color: AppColors.kTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'e.g. Alex',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 18,
            color: AppColors.kTextDisabled,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        onSubmitted: (_) => onSubmit?.call(),
        textInputAction: TextInputAction.done,
        maxLength: 30,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
            null, // hide counter
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _ContinueButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.kAccentPrimary, AppColors.kAccentSecondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.kAccentPrimary.withAlpha(100),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : null,
          ),
          child: const Center(
            child: Text(
              "Let's go →",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
