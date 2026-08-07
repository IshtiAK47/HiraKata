import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:hirakata/core/router/route_names.dart';
import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'widgets/continue_learning_card.dart';
import 'widgets/learning_category_tile.dart';
import 'widgets/section_card.dart';

/// The main home screen of the HiraKata app.
///
/// Displays a clean vertical layout with sections for continuing learning,
/// choosing Hiragana or Katakana, practicing, viewing progress, and settings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.hiragana, AppColors.katakana],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Center(
                      child: Text(
                        'あ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('HiraKata'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push(RouteNames.settings),
                ),
              ],
            ),

            // ── Content ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.sm),

                  // ── Greeting ────────────────────────────────
                  Text(
                    'Ready to learn?',
                    style: theme.textTheme.headlineMedium,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: -0.05, end: 0, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Continue Learning ───────────────────────
                  ContinueLearningCard(
                    onTap: () => context.push(RouteNames.learnPath('hiragana')),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: 0.05, end: 0, duration: 500.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Section label ───────────────────────────
                  Text(
                    'Choose a track',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: AppSpacing.md),

                  // ── Hiragana / Katakana Tiles ───────────────
                  Row(
                    children: [
                      Expanded(
                        child: LearningCategoryTile(
                          title: 'Hiragana',
                          subtitle: '107 characters',
                          kanaPreview: 'あ',
                          accentColor: AppColors.hiragana,
                          onTap: () => context.push(
                            RouteNames.learnPath('hiragana'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: LearningCategoryTile(
                          title: 'Katakana',
                          subtitle: '107 characters',
                          kanaPreview: 'ア',
                          accentColor: AppColors.katakana,
                          onTap: () => context.push(
                            RouteNames.learnPath('katakana'),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 300.ms)
                      .slideY(begin: 0.05, end: 0, duration: 500.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Other Sections ──────────────────────────
                  Text(
                    'More',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms),

                  const SizedBox(height: AppSpacing.md),

                  SectionCard(
                    icon: Icons.school_outlined,
                    title: 'Practice',
                    subtitle: 'Flashcards, quizzes & matching',
                    accentColor: AppColors.practice,
                    onTap: () => context.push(RouteNames.practice),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 450.ms)
                      .slideY(begin: 0.03, end: 0, duration: 400.ms),

                  const SizedBox(height: AppSpacing.md),

                  SectionCard(
                    icon: Icons.insights_outlined,
                    title: 'Progress',
                    subtitle: 'Track your learning journey',
                    accentColor: AppColors.progress,
                    onTap: () => context.push(RouteNames.progress),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms)
                      .slideY(begin: 0.03, end: 0, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
