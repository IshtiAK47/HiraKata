import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hirakata/core/data/kana_repository.dart';
import 'package:hirakata/core/models/kana.dart';
import 'package:hirakata/core/models/kana_category.dart';
import 'package:hirakata/core/models/kana_type.dart';
import 'package:hirakata/core/router/route_names.dart';
import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/app_typography.dart';

/// Screen displaying a grid of kana characters grouped by categories.
///
/// Supports searching by romaji or character, filtering by tab
/// (Basic, Dakuten, Handakuten, Yōon), and tapping to launch lessons.
class KanaListScreen extends ConsumerStatefulWidget {
  const KanaListScreen({super.key, required this.type});

  final String type;

  @override
  ConsumerState<KanaListScreen> createState() => _KanaListScreenState();
}

class _KanaListScreenState extends ConsumerState<KanaListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  KanaType get _kanaType =>
      widget.type == 'katakana' ? KanaType.katakana : KanaType.hiragana;

  Color get _accentColor =>
      _kanaType == KanaType.hiragana ? AppColors.hiragana : AppColors.katakana;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final kanaDataAsync = ref.watch(kanaDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _kanaType == KanaType.hiragana ? 'Hiragana (ひらがな)' : 'Katakana (カタカナ)',
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                  vertical: AppSpacing.xs,
                ),
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search character or romaji (e.g. "ka", "か")...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      fillColor: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5)
                          : Colors.white,
                    ),
                  ),
                ),
              ),

              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: _accentColor,
                labelColor: _accentColor,
                unselectedLabelColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                labelStyle: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTypography.titleSmall,
                tabs: const [
                  Tab(text: 'Basic'),
                  Tab(text: 'Dakuten'),
                  Tab(text: 'Handakuten'),
                  Tab(text: 'Yōon'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: kanaDataAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: _accentColor),
        ),
        error: (err, stack) => Center(
          child: Text('Failed to load kana data: $err'),
        ),
        data: (repo) {
          final allKana = repo.getByType(_kanaType);

          // If searching, show a unified search grid across all categories
          if (_searchQuery.isNotEmpty) {
            final filtered = allKana.where((k) {
              return k.romaji.toLowerCase().contains(_searchQuery) ||
                  k.character.contains(_searchQuery) ||
                  k.exampleWord.contains(_searchQuery) ||
                  k.exampleMeaning.toLowerCase().contains(_searchQuery);
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No characters found matching "$_searchQuery"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            return _KanaGrid(
              kanaList: filtered,
              accentColor: _accentColor,
              kanaType: widget.type,
            );
          }

          // Category tab views
          return TabBarView(
            controller: _tabController,
            children: [
              _KanaGrid(
                kanaList: repo.getByCategory(_kanaType, KanaCategory.basic),
                accentColor: _accentColor,
                kanaType: widget.type,
              ),
              _KanaGrid(
                kanaList: repo.getByCategory(_kanaType, KanaCategory.dakuten),
                accentColor: _accentColor,
                kanaType: widget.type,
              ),
              _KanaGrid(
                kanaList: repo.getByCategory(_kanaType, KanaCategory.handakuten),
                accentColor: _accentColor,
                kanaType: widget.type,
              ),
              _KanaGrid(
                kanaList: repo.getByCategory(_kanaType, KanaCategory.yoon),
                accentColor: _accentColor,
                kanaType: widget.type,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Reusable grid view displaying cards for a list of kana characters.
class _KanaGrid extends StatelessWidget {
  const _KanaGrid({
    required this.kanaList,
    required this.accentColor,
    required this.kanaType,
  });

  final List<Kana> kanaList;
  final Color accentColor;
  final String kanaType;

  @override
  Widget build(BuildContext context) {
    if (kanaList.isEmpty) {
      return Center(
        child: Text(
          'No characters in this section.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.82,
      ),
      itemCount: kanaList.length,
      itemBuilder: (context, index) {
        final item = kanaList[index];
        return _KanaTile(
          kana: item,
          accentColor: accentColor,
          kanaType: kanaType,
          index: index,
        );
      },
    );
  }
}

/// Individual card representing a single kana character in the grid.
class _KanaTile extends StatelessWidget {
  const _KanaTile({
    required this.kana,
    required this.accentColor,
    required this.kanaType,
    required this.index,
  });

  final Kana kana;
  final Color accentColor;
  final String kanaType;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push(RouteNames.lessonPath(kanaType, '${kana.orderIndex}'));
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.15),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Character
              Text(
                kana.character,
                style: AppTypography.kanaSmall.copyWith(
                  fontSize: kana.character.length > 1 ? 20 : 26,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? theme.colorScheme.onSurface
                      : AppColors.kanaDisplay,
                ),
              ),
              const SizedBox(height: 2),

              // Romaji
              Text(
                kana.romaji,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: (index % 12) * 25),
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
        );
  }
}
