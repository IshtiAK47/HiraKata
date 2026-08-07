import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hirakata/core/router/app_router.dart';
import 'package:hirakata/core/theme/app_theme.dart';
import 'package:hirakata/core/theme/theme_provider.dart';

/// Root widget for the HiraKata application.
///
/// Configures Material 3 theming (light/dark/system) and routing.
class HiraKataApp extends ConsumerWidget {
  const HiraKataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'HiraKata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
