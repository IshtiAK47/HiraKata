import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hirakata/core/data/kana_repository.dart';
import 'package:hirakata/core/data/progress_repository.dart';
import 'package:hirakata/core/services/audio_service.dart';
import 'package:hirakata/core/models/kana.dart';
import 'package:hirakata/core/models/kana_type.dart';
import 'package:hirakata/core/router/route_names.dart';
import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/app_typography.dart';
import 'widgets/stroke_order_visualizer.dart';

/// Detailed lesson view for a single kana character.
///
/// Features hero display, romaji, mnemonic, stroke order,
/// real example word, learning tip, confusion warning, and next/prev controls.
class LessonDetailScreen extends ConsumerWidget {
  const LessonDetailScreen({
    super.key,
    required this.type,
    required this.id,
  });

  final String type;
  final String id;

  KanaType get _kanaType =>
      type == 'katakana' ? KanaType.katakana : KanaType.hiragana;

  Color get _accentColor =>
      _kanaType == KanaType.hiragana ? AppColors.hiragana : AppColors.katakana;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orderIndex = int.tryParse(id) ?? 0;

    final kanaDataAsync = ref.watch(kanaDataProvider);

    return kanaDataAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(color: _accentColor),
        ),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error loading lesson: $err')),
      ),
      data: (repo) {
        final kana = repo.getByIndex(_kanaType, orderIndex);

        if (kana == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Character not found.')),
          );
        }

        // Mark character as learned
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(progressRepositoryProvider)
              .markAsLearned('${_kanaType.name}_${kana.character}');
        });

        final totalKana = repo.countByType(_kanaType);
        final hasPrev = orderIndex > 0;
        final hasNext = orderIndex < totalKana - 1;

        return Scaffold(
          appBar: AppBar(
            title: Text('${kana.type.displayName} Lesson'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: AppSpacing.lg),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${orderIndex + 1} / $totalKana',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Hero Card ─────────────────────────────────
                        _HeroCharacterCard(
                          kana: kana,
                          accentColor: _accentColor,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.0, 1.0),
                              duration: 400.ms,
                            ),

                        const SizedBox(height: AppSpacing.xl),

                        // ── Mnemonic Card ─────────────────────────────
                        _MnemonicCard(
                          mnemonic: kana.mnemonic,
                          accentColor: _accentColor,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 100.ms)
                            .slideY(begin: 0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Example Word Card ─────────────────────────
                        _ExampleWordCard(
                          word: kana.exampleWord,
                          romaji: kana.exampleRomaji,
                          meaning: kana.exampleMeaning,
                          accentColor: _accentColor,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideY(begin: 0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Stroke Order Visualizer ───────────────────
                        StrokeOrderVisualizer(
                          character: kana.character,
                          strokeSteps: kana.strokeOrder,
                          accentColor: _accentColor,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 300.ms)
                            .slideY(begin: 0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Learning Tip ──────────────────────────────
                        _LearningTipCard(
                          tip: kana.learningTip,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 400.ms),

                        // ── Common Confusion Warning ──────────────────
                        if (kana.commonConfusion != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _ConfusionWarningCard(
                            warning: kana.commonConfusion!,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 450.ms),
                        ],

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),

                // ── Bottom Navigation Bar ────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surface
                        : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Previous button
                      if (hasPrev)
                        OutlinedButton.icon(
                          onPressed: () {
                            context.pushReplacement(
                              RouteNames.lessonPath(type, '${orderIndex - 1}'),
                            );
                          },
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Prev'),
                        )
                      else
                        const SizedBox.shrink(),

                      const Spacer(),

                      // Next / Complete button
                      Flexible(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _accentColor,
                          ),
                          onPressed: () {
                            if (hasNext) {
                              context.pushReplacement(
                                RouteNames.lessonPath(type, '${orderIndex + 1}'),
                              );
                            } else {
                              context.pop();
                            }
                          },
                          icon: Icon(
                            hasNext
                                ? Icons.arrow_forward_rounded
                                : Icons.check_circle_rounded,
                            size: 18,
                          ),
                          label: Text(
                            hasNext ? 'Next Character' : 'Complete Track',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Hero Card Widget ──────────────────────────────────────────────────
class _HeroCharacterCard extends ConsumerWidget {
  const _HeroCharacterCard({
    required this.kana,
    required this.accentColor,
  });

  final Kana kana;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        children: [
          // Main Character
          Text(
            kana.character,
            style: AppTypography.kanaHero.copyWith(
              color: isDark ? theme.colorScheme.onSurface : Colors.black87,
              fontSize: kana.character.length > 1 ? 84 : 110,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Romaji Reading & Audio icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                kana.romaji,
                style: AppTypography.headlineMedium.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: accentColor.withValues(alpha: 0.12),
                ),
                icon: Icon(
                  Icons.volume_up_rounded,
                  color: accentColor,
                  size: 20,
                ),
                onPressed: () {
                  ref.read(audioServiceProvider).speak(kana.character);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Playing pronunciation: "${kana.character}" (${kana.romaji})'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              '${kana.category.displayName} • ${kana.type.displayName}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mnemonic Card Widget ──────────────────────────────────────────────
class _MnemonicCard extends StatelessWidget {
  const _MnemonicCard({
    required this.mnemonic,
    required this.accentColor,
  });

  final String mnemonic;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.warning,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Memory Hint (Mnemonic)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            mnemonic,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Example Word Card Widget ──────────────────────────────────────────
class _ExampleWordCard extends ConsumerWidget {
  const _ExampleWordCard({
    required this.word,
    required this.romaji,
    required this.meaning,
    required this.accentColor,
  });

  final String word;
  final String romaji;
  final String meaning;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Example Word',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.volume_up_rounded, color: accentColor, size: 20),
                onPressed: () {
                  ref.read(audioServiceProvider).speak(word);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              // Japanese word
              Text(
                word,
                style: AppTypography.exampleWord.copyWith(
                  fontSize: 32,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reading
                    Text(
                      romaji,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Meaning
                    Text(
                      meaning,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Learning Tip Widget ───────────────────────────────────────────────
class _LearningTipCard extends StatelessWidget {
  const _LearningTipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confusion Warning Widget ──────────────────────────────────────────
class _ConfusionWarningCard extends StatelessWidget {
  const _ConfusionWarningCard({required this.warning});

  final String warning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              warning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
