import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hirakata/core/data/kana_repository.dart';
import 'package:hirakata/core/data/progress_repository.dart';
import 'package:hirakata/core/models/kana.dart';
import 'package:hirakata/core/models/kana_type.dart';
import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/app_typography.dart';

enum PracticeMode { menu, flashcards, quiz, recognition, matching }

/// Main practice module with interactive games and flashcard modes.
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  PracticeMode _activeMode = PracticeMode.menu;
  KanaType _selectedType = KanaType.hiragana;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        leading: _activeMode != PracticeMode.menu
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _activeMode = PracticeMode.menu),
              )
            : null,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_activeMode) {
      case PracticeMode.menu:
        return 'Practice Modes';
      case PracticeMode.flashcards:
        return 'Flashcards';
      case PracticeMode.quiz:
        return 'Multiple Choice Quiz';
      case PracticeMode.recognition:
        return 'Character Recognition';
      case PracticeMode.matching:
        return 'Matching Game';
    }
  }

  Widget _buildBody() {
    switch (_activeMode) {
      case PracticeMode.menu:
        return _buildMenu();
      case PracticeMode.flashcards:
        return _FlashcardPracticeView(type: _selectedType);
      case PracticeMode.quiz:
        return _QuizPracticeView(type: _selectedType);
      case PracticeMode.recognition:
        return _RecognitionPracticeView(type: _selectedType);
      case PracticeMode.matching:
        return _MatchingPracticeView(type: _selectedType);
    }
  }

  Widget _buildMenu() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kana type selector toggle
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  selected: _selectedType == KanaType.hiragana,
                  label: const Center(child: Text('Hiragana')),
                  selectedColor: AppColors.hiragana.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.hiragana,
                  onSelected: (val) =>
                      setState(() => _selectedType = KanaType.hiragana),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilterChip(
                  selected: _selectedType == KanaType.katakana,
                  label: const Center(child: Text('Katakana')),
                  selectedColor: AppColors.katakana.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.katakana,
                  onSelected: (val) =>
                      setState(() => _selectedType = KanaType.katakana),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Select a practice mode',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 1. Flashcards Card
          _ModeSelectionCard(
            icon: Icons.style_outlined,
            title: 'Flashcards',
            description: 'Flip character cards with memory aids and examples',
            accentColor: AppColors.hiragana,
            onTap: () => setState(() => _activeMode = PracticeMode.flashcards),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: AppSpacing.md),

          // 2. Quiz Card
          _ModeSelectionCard(
            icon: Icons.quiz_outlined,
            title: 'Multiple Choice Quiz',
            description: 'Read the character and choose the correct romaji',
            accentColor: AppColors.katakana,
            onTap: () => setState(() => _activeMode = PracticeMode.quiz),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: AppSpacing.md),

          // 3. Recognition Card
          _ModeSelectionCard(
            icon: Icons.search_rounded,
            title: 'Character Recognition',
            description: 'Read the romaji and pick the matching character',
            accentColor: AppColors.practice,
            onTap: () => setState(() => _activeMode = PracticeMode.recognition),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

          const SizedBox(height: AppSpacing.md),

          // 4. Matching Card
          _ModeSelectionCard(
            icon: Icons.grid_view_rounded,
            title: 'Matching Pair Game',
            description: 'Match pairs of kana characters with their romaji',
            accentColor: AppColors.progress,
            onTap: () => setState(() => _activeMode = PracticeMode.matching),
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
        ],
      ),
    );
  }
}

class _ModeSelectionCard extends StatelessWidget {
  const _ModeSelectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 1. Flashcard Mode View ─────────────────────────────────────────────
class _FlashcardPracticeView extends ConsumerStatefulWidget {
  const _FlashcardPracticeView({required this.type});

  final KanaType type;

  @override
  ConsumerState<_FlashcardPracticeView> createState() =>
      __FlashcardPracticeViewState();
}

class __FlashcardPracticeViewState
    extends ConsumerState<_FlashcardPracticeView> {
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kanaDataAsync = ref.watch(kanaDataProvider);
    final isDark = theme.brightness == Brightness.dark;

    return kanaDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (repo) {
        final list = repo.getByType(widget.type);
        if (list.isEmpty) return const Center(child: Text('No data'));

        final currentKana = list[_currentIndex % list.length];
        final accentColor = widget.type == KanaType.hiragana
            ? AppColors.hiragana
            : AppColors.katakana;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              Text(
                'Card ${_currentIndex + 1} of ${list.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Flip Card Container
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFlipped = !_isFlipped),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                      return AnimatedBuilder(
                        animation: rotate,
                        child: child,
                        builder: (context, child) {
                          final isUnder = ValueKey(_isFlipped) != child?.key;
                          var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                          if (isUnder) tilt = -tilt;
                          final value = isUnder
                              ? min(rotate.value, pi / 2)
                              : rotate.value;
                          return Transform(
                            transform: Matrix4.rotationY(value)..setEntry(3, 2, tilt),
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                      );
                    },
                    child: _isFlipped
                        ? _CardBack(
                            key: const ValueKey(true),
                            kana: currentKana,
                            accentColor: accentColor,
                            isDark: isDark,
                          )
                        : _CardFront(
                            key: const ValueKey(false),
                            kana: currentKana,
                            accentColor: accentColor,
                            isDark: isDark,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Controls
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                      onPressed: () {
                        ref
                            .read(progressRepositoryProvider)
                            .recordPracticeResult(
                              characterKey: '${widget.type.name}_${currentKana.character}',
                              isCorrect: false,
                            );
                        setState(() {
                          _isFlipped = false;
                          _currentIndex++;
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.error, size: 18),
                      label: const Text('Review Again', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                      onPressed: () {
                        ref
                            .read(progressRepositoryProvider)
                            .recordPracticeResult(
                              characterKey: '${widget.type.name}_${currentKana.character}',
                              isCorrect: true,
                            );
                        setState(() {
                          _isFlipped = false;
                          _currentIndex++;
                        });
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('I Know This!', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    super.key,
    required this.kana,
    required this.accentColor,
    required this.isDark,
  });

  final Kana kana;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            kana.character,
            style: AppTypography.kanaHero.copyWith(
              fontSize: 120,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined,
                  size: 18, color: accentColor.withValues(alpha: 0.7)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Tap to flip card',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({
    super.key,
    required this.kana,
    required this.accentColor,
    required this.isDark,
  });

  final Kana kana;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            kana.romaji,
            style: AppTypography.headlineLarge.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Mnemonic:',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            kana.mnemonic,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  kana.exampleWord,
                  style: AppTypography.kanaSmall,
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Text(
                    '${kana.exampleRomaji} (${kana.exampleMeaning})',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Quiz Mode View ──────────────────────────────────────────────────
class _QuizPracticeView extends ConsumerStatefulWidget {
  const _QuizPracticeView({required this.type});

  final KanaType type;

  @override
  ConsumerState<_QuizPracticeView> createState() => __QuizPracticeViewState();
}

class __QuizPracticeViewState extends ConsumerState<_QuizPracticeView> {
  int _score = 0;
  int _questionCount = 0;
  Kana? _targetKana;
  List<String> _options = [];
  String? _selectedOption;

  void _nextQuestion(List<Kana> allKana) {
    if (allKana.isEmpty) return;
    final random = Random();
    final target = allKana[random.nextInt(allKana.length)];

    final optionsSet = <String>{target.romaji};
    while (optionsSet.length < 4) {
      optionsSet.add(allKana[random.nextInt(allKana.length)].romaji);
    }

    final optionsList = optionsSet.toList()..shuffle();

    setState(() {
      _targetKana = target;
      _options = optionsList;
      _selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kanaDataAsync = ref.watch(kanaDataProvider);

    return kanaDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (repo) {
        final list = repo.getByType(widget.type);
        if (_targetKana == null && list.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _nextQuestion(list);
          });
        }

        if (_targetKana == null) return const SizedBox.shrink();

        final accentColor = widget.type == KanaType.hiragana
            ? AppColors.hiragana
            : AppColors.katakana;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: $_score / $_questionCount',
                      style: theme.textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(widget.type.displayName,
                        style: TextStyle(color: accentColor)),
                  ),
                ],
              ),
              const Spacer(),

              // Target Character Display
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    _targetKana!.character,
                    style: AppTypography.kanaHero.copyWith(fontSize: 90),
                  ),
                ),
              ),

              const Spacer(),

              // Option Buttons (Grid 2x2)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 2.5,
                ),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final isSelected = _selectedOption == option;
                  final isCorrect = option == _targetKana!.romaji;

                  Color btnColor = theme.colorScheme.surfaceContainerHighest;
                  if (_selectedOption != null) {
                    if (isCorrect) {
                      btnColor = AppColors.successLight;
                    } else if (isSelected) {
                      btnColor = AppColors.errorLight;
                    }
                  }

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                    ),
                    onPressed: _selectedOption != null
                        ? null
                        : () {
                            setState(() {
                              _selectedOption = option;
                              _questionCount++;
                              if (isCorrect) _score++;
                            });
                            ref
                                .read(progressRepositoryProvider)
                                .recordPracticeResult(
                                  characterKey:
                                      '${widget.type.name}_${_targetKana!.character}',
                                  isCorrect: isCorrect,
                                );

                            Future.delayed(const Duration(milliseconds: 1000),
                                () {
                              if (mounted) _nextQuestion(list);
                            });
                          },
                    child: Text(
                      option,
                      style: AppTypography.titleLarge.copyWith(
                        color: _selectedOption != null
                            ? (isCorrect
                                ? AppColors.success
                                : isSelected
                                    ? AppColors.error
                                    : null)
                            : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

// ── 3. Recognition Practice View ───────────────────────────────────────
class _RecognitionPracticeView extends ConsumerStatefulWidget {
  const _RecognitionPracticeView({required this.type});

  final KanaType type;

  @override
  ConsumerState<_RecognitionPracticeView> createState() =>
      __RecognitionPracticeViewState();
}

class __RecognitionPracticeViewState
    extends ConsumerState<_RecognitionPracticeView> {
  int _score = 0;
  int _questionCount = 0;
  Kana? _targetKana;
  List<Kana> _options = [];
  Kana? _selectedKana;

  void _nextQuestion(List<Kana> allKana) {
    if (allKana.isEmpty) return;
    final random = Random();
    final target = allKana[random.nextInt(allKana.length)];

    final optionsSet = <Kana>{target};
    while (optionsSet.length < 4) {
      optionsSet.add(allKana[random.nextInt(allKana.length)]);
    }

    final optionsList = optionsSet.toList()..shuffle();

    setState(() {
      _targetKana = target;
      _options = optionsList;
      _selectedKana = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kanaDataAsync = ref.watch(kanaDataProvider);

    return kanaDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (repo) {
        final list = repo.getByType(widget.type);
        if (_targetKana == null && list.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _nextQuestion(list);
          });
        }

        if (_targetKana == null) return const SizedBox.shrink();

        final accentColor = widget.type == KanaType.hiragana
            ? AppColors.hiragana
            : AppColors.katakana;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: $_score / $_questionCount',
                      style: theme.textTheme.titleMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(widget.type.displayName,
                        style: TextStyle(color: accentColor)),
                  ),
                ],
              ),
              const Spacer(),

              // Target Romaji Display
              Text(
                'Which character represents:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _targetKana!.romaji,
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 48,
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              // Grid of 4 Kana choices
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.5,
                ),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final isSelected = _selectedKana == option;
                  final isCorrect = option == _targetKana;

                  Color btnColor = theme.colorScheme.surfaceContainerHighest;
                  if (_selectedKana != null) {
                    if (isCorrect) {
                      btnColor = AppColors.successLight;
                    } else if (isSelected) {
                      btnColor = AppColors.errorLight;
                    }
                  }

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                    ),
                    onPressed: _selectedKana != null
                        ? null
                        : () {
                            setState(() {
                              _selectedKana = option;
                              _questionCount++;
                              if (isCorrect) _score++;
                            });
                            ref
                                .read(progressRepositoryProvider)
                                .recordPracticeResult(
                                  characterKey:
                                      '${widget.type.name}_${_targetKana!.character}',
                                  isCorrect: isCorrect,
                                );

                            Future.delayed(const Duration(milliseconds: 1000),
                                () {
                              if (mounted) _nextQuestion(list);
                            });
                          },
                    child: Text(
                      option.character,
                      style: AppTypography.kanaMedium.copyWith(fontSize: 44),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

// ── 4. Matching Game View ──────────────────────────────────────────────
class _MatchingPracticeView extends ConsumerStatefulWidget {
  const _MatchingPracticeView({required this.type});

  final KanaType type;

  @override
  ConsumerState<_MatchingPracticeView> createState() =>
      __MatchingPracticeViewState();
}

class __MatchingPracticeViewState extends ConsumerState<_MatchingPracticeView> {
  List<_MatchingTile> _tiles = [];
  _MatchingTile? _selectedTile;
  int _matchedPairs = 0;

  void _initGame(List<Kana> allKana) {
    if (allKana.length < 4) return;
    final random = Random();
    final shuffled = List<Kana>.from(allKana)..shuffle(random);
    final chosen = shuffled.take(4).toList();

    final tiles = <_MatchingTile>[];
    for (int i = 0; i < chosen.length; i++) {
      final k = chosen[i];
      tiles.add(_MatchingTile(id: i, text: k.character, matchId: i, isKana: true));
      tiles.add(_MatchingTile(id: i + 10, text: k.romaji, matchId: i, isKana: false));
    }
    tiles.shuffle(random);

    setState(() {
      _tiles = tiles;
      _selectedTile = null;
      _matchedPairs = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kanaDataAsync = ref.watch(kanaDataProvider);

    return kanaDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (repo) {
        final list = repo.getByType(widget.type);
        if (_tiles.isEmpty && list.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _initGame(list));
        }

        final isWon = _matchedPairs == 4;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              Text('Match Kana with Romaji ($_matchedPairs / 4 matched)',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xl),

              if (isWon) ...[
                const Spacer(),
                const Icon(Icons.stars_rounded, size: 80, color: AppColors.warning),
                const SizedBox(height: AppSpacing.md),
                Text('Great Job! All Pairs Matched!',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton.icon(
                  onPressed: () => _initGame(list),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play Again'),
                ),
                const Spacer(),
              ] else ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _tiles.length,
                  itemBuilder: (context, index) {
                    final tile = _tiles[index];
                    final isSelected = _selectedTile == tile;

                    if (tile.isMatched) {
                      return const SizedBox.shrink();
                    }

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                      ),
                      onPressed: () {
                        if (_selectedTile == null) {
                          setState(() => _selectedTile = tile);
                        } else if (_selectedTile == tile) {
                          setState(() => _selectedTile = null);
                        } else {
                          if (_selectedTile!.matchId == tile.matchId) {
                            // Matched!
                            setState(() {
                              _selectedTile!.isMatched = true;
                              tile.isMatched = true;
                              _selectedTile = null;
                              _matchedPairs++;
                            });
                          } else {
                            // Wrong pair
                            setState(() => _selectedTile = null);
                          }
                        }
                      },
                      child: Text(
                        tile.text,
                        style: tile.isKana
                            ? AppTypography.kanaMedium
                            : AppTypography.titleLarge,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MatchingTile {
  _MatchingTile({
    required this.id,
    required this.text,
    required this.matchId,
    required this.isKana,
  });

  final int id;
  final String text;
  final int matchId;
  final bool isKana;
  bool isMatched = false;
}
