import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hirakata/core/data/progress_repository.dart';
import 'package:hirakata/core/router/route_names.dart';
import 'package:hirakata/core/services/audio_service.dart';
import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/theme_provider.dart';

/// Settings screen for managing theme, progress reset, and app info.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showThemeSelector(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Theme Mode',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(Icons.brightness_auto_rounded),
                  title: const Text('System Default'),
                  subtitle: const Text('Match system light/dark setting'),
                  trailing: currentMode == ThemeMode.system
                      ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode_rounded),
                  title: const Text('Light Mode'),
                  subtitle: const Text('Always use crisp light theme'),
                  trailing: currentMode == ThemeMode.light
                      ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Always use sleek dark theme'),
                  trailing: currentMode == ThemeMode.dark
                      ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getThemeSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    final isSoundEnabled = ref.watch(soundEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // ── Preferences Section ──────────────────────────────────
          Text('Preferences', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_medium_rounded),
                  title: const Text('Theme Mode'),
                  subtitle: Text(_getThemeSubtitle(themeMode)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showThemeSelector(context, ref, themeMode),
                ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Play audio pronunciations and feedback'),
                  value: isSoundEnabled,
                  onChanged: (val) {
                    ref.read(soundEnabledProvider.notifier).toggleSound(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Data & Reset Section ─────────────────────────────────
          Text('Data & Progress', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),

          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
              title: const Text('Reset All Progress',
                  style: TextStyle(color: AppColors.error)),
              subtitle: const Text('Clear learned state, accuracy, and streaks'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset All Progress?'),
                    content: const Text(
                      'This action cannot be undone. All learned characters and practice stats will be reset.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Reset Everything'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(progressRepositoryProvider).resetAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All progress has been reset.'),
                      ),
                    );
                  }
                }
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── About & Developer Section ─────────────────────────────
          Text('About & Developer', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Developer & App Info'),
                  subtitle: const Text('Ishtiak Mahmood • Tap for Developer Info'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(RouteNames.developerInfo),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('App Version'),
                  trailing: Text(
                    '1.0.0 (0.1.0+1)',
                    style: TextStyle(color: Colors.grey),
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
