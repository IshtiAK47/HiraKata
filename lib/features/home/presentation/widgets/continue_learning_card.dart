import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hirakata/core/data/kana_repository.dart';
import 'package:hirakata/core/data/progress_repository.dart';
import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/app_typography.dart';

/// Hero card shown at the top of the home screen.
///
/// Displays the user's current learning progress with a dynamic progress bar,
/// learned character count, and tapping it continues the journey.
class ContinueLearningCard extends ConsumerWidget {
  const ContinueLearningCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(progressVersionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progressRepo = ref.watch(progressRepositoryProvider);
    final kanaDataAsync = ref.watch(kanaDataProvider);

    return kanaDataAsync.when(
      loading: () => _buildCard(
        context: context,
        isDark: isDark,
        theme: theme,
        title: 'Continue Learning',
        subtitle: 'Loading progress...',
        learnedCount: 0,
        totalCount: 214,
        nextKanaChar: 'あ',
      ),
      error: (e, s) => _buildCard(
        context: context,
        isDark: isDark,
        theme: theme,
        title: 'Continue Learning',
        subtitle: 'Start your Hiragana journey',
        learnedCount: 0,
        totalCount: 214,
        nextKanaChar: 'あ',
      ),
      data: (repo) {
        final hiraganaList = repo.hiragana;
        final katakanaList = repo.katakana;

        final hiraganaKeys =
            hiraganaList.map((k) => 'hiragana_${k.character}').toList();
        final katakanaKeys =
            katakanaList.map((k) => 'katakana_${k.character}').toList();

        final hiraganaLearned = progressRepo.getLearnedCount(hiraganaKeys);
        final katakanaLearned = progressRepo.getLearnedCount(katakanaKeys);

        final totalLearned = hiraganaLearned + katakanaLearned;
        final totalKana = repo.totalCount;

        // Find next unlearned character
        String nextChar = 'あ';
        String subtitleText = 'Start your Hiragana journey';

        final nextHiragana = hiraganaList.firstWhere(
          (k) => !progressRepo.getProgress('hiragana_${k.character}').isLearned,
          orElse: () => hiraganaList.first,
        );

        if (totalLearned > 0 && totalLearned < totalKana) {
          nextChar = nextHiragana.character;
          subtitleText = 'Next: ${nextHiragana.character} (${nextHiragana.romaji})';
        } else if (totalLearned >= totalKana) {
          nextChar = '★';
          subtitleText = 'All characters learned! Time to practice.';
        } else {
          nextChar = nextHiragana.character;
        }

        return _buildCard(
          context: context,
          isDark: isDark,
          theme: theme,
          title: totalLearned > 0 ? 'Keep Going!' : 'Continue Learning',
          subtitle: subtitleText,
          learnedCount: totalLearned,
          totalCount: totalKana,
          nextKanaChar: nextChar,
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required bool isDark,
    required ThemeData theme,
    required String title,
    required String subtitle,
    required int learnedCount,
    required int totalCount,
    required String nextKanaChar,
  }) {
    final progressValue = totalCount > 0 ? (learnedCount / totalCount) : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkCardGradientStart.withValues(alpha: 0.6),
                      AppColors.darkCardGradientEnd.withValues(alpha: 0.6),
                    ]
                  : [
                      AppColors.lightCardGradientStart,
                      AppColors.lightCardGradientEnd,
                    ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.seed.withValues(alpha: isDark ? 0.15 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side — text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Dynamic Progress bar
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.onSurface
                            .withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$learnedCount / $totalCount characters learned',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              // Right side — kana display preview
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Center(
                  child: Text(
                    nextKanaChar,
                    style: AppTypography.kanaMedium.copyWith(
                      color: AppColors.hiragana,
                    ),
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
