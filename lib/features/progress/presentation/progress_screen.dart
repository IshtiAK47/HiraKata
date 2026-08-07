import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hirakata/core/data/kana_repository.dart';
import 'package:hirakata/core/data/progress_repository.dart';
import 'package:hirakata/core/models/kana_category.dart';
import 'package:hirakata/core/models/kana_type.dart';
import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/app_typography.dart';

/// Screen displaying user learning progress, stats, accuracy, and streaks.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ref.watch(progressVersionProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);
    final kanaDataAsync = ref.watch(kanaDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Progress'),
      ),
      body: kanaDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading stats: $e')),
        data: (repo) {
          final hiraganaList = repo.hiragana;
          final katakanaList = repo.katakana;

          final hiraganaLearned = progressRepo.getLearnedCount(
            hiraganaList.map((k) => 'hiragana_${k.character}').toList(),
          );
          final katakanaLearned = progressRepo.getLearnedCount(
            katakanaList.map((k) => 'katakana_${k.character}').toList(),
          );

          final totalLearned = hiraganaLearned + katakanaLearned;
          final totalKana = repo.totalCount;
          final overallPercentage =
              totalKana > 0 ? (totalLearned / totalKana) : 0.0;

          final streak = progressRepo.streakDays;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Streak Hero Card ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFFE65100).withValues(alpha: 0.4),
                              const Color(0xFFF57C00).withValues(alpha: 0.4),
                            ]
                          : [
                              const Color(0xFFFFF3E0),
                              const Color(0xFFFFE0B2),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.deepOrange,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$streak Day Streak!',
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              streak > 0
                                  ? 'Keep learning daily to grow your streak!'
                                  : 'Start practicing today to build a streak!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

                const SizedBox(height: AppSpacing.xxl),

                // ── Overall Progress Overview ───────────────────────
                Text('Overall Completion', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Characters Learned',
                              style: theme.textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '$totalLearned / $totalKana (${(overallPercentage * 100).toStringAsFixed(1)}%)',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        child: LinearProgressIndicator(
                          value: overallPercentage,
                          minHeight: 10,
                          backgroundColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                const SizedBox(height: AppSpacing.xxl),

                // ── Hiragana & Katakana Tracks Breakdown ─────────────
                Text('Track Breakdown', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: _TrackProgressCard(
                        title: 'Hiragana',
                        learned: hiraganaLearned,
                        total: hiraganaList.length,
                        accentColor: AppColors.hiragana,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _TrackProgressCard(
                        title: 'Katakana',
                        learned: katakanaLearned,
                        total: katakanaList.length,
                        accentColor: AppColors.katakana,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: AppSpacing.xxl),

                // ── Category Breakdown ──────────────────────────────
                Text('Hiragana Categories', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),

                ...KanaCategory.values.map((cat) {
                  final catKana = repo.getByCategory(KanaType.hiragana, cat);
                  final learned = progressRepo.getLearnedCount(
                    catKana.map((k) => 'hiragana_${k.character}').toList(),
                  );
                  return _CategoryProgressRow(
                    categoryName: cat.displayName,
                    learned: learned,
                    total: catKana.length,
                    accentColor: AppColors.hiragana,
                  );
                }),

                const SizedBox(height: AppSpacing.xl),

                Text('Katakana Categories', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),

                ...KanaCategory.values.map((cat) {
                  final catKana = repo.getByCategory(KanaType.katakana, cat);
                  final learned = progressRepo.getLearnedCount(
                    catKana.map((k) => 'katakana_${k.character}').toList(),
                  );
                  return _CategoryProgressRow(
                    categoryName: cat.displayName,
                    learned: learned,
                    total: catKana.length,
                    accentColor: AppColors.katakana,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TrackProgressCard extends StatelessWidget {
  const _TrackProgressCard({
    required this.title,
    required this.learned,
    required this.total,
    required this.accentColor,
    required this.isDark,
  });

  final String title;
  final int learned;
  final int total;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (learned / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$learned / $total',
            style: AppTypography.headlineSmall.copyWith(color: accentColor),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: accentColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({
    required this.categoryName,
    required this.learned,
    required this.total,
    required this.accentColor,
  });

  final String categoryName;
  final int learned;
  final int total;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = total > 0 ? (learned / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(categoryName, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text('$learned/$total', style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
