import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:hirakata/core/router/route_names.dart';
import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/app_typography.dart';

/// Splash screen with a simple logo fade-in animation.
///
/// Automatically navigates to the home screen after a short delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── App icon ──────────────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.hiragana,
                    AppColors.katakana,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'あ',
                  style: AppTypography.kanaLarge.copyWith(
                    color: Colors.white,
                    fontSize: 52,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: AppSpacing.xl),

            // ── App name ──────────────────────────────────────────
            Text(
              'HiraKata',
              style: AppTypography.headlineLarge.copyWith(
                color: isDark
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),

            const SizedBox(height: AppSpacing.sm),

            // ── Tagline ───────────────────────────────────────────
            Text(
              'Learn Hiragana & Katakana',
              style: AppTypography.bodyMedium.copyWith(
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.5,
                ),
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
