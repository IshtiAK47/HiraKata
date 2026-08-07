import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hirakata/core/router/route_names.dart';
import 'package:hirakata/features/home/presentation/home_screen.dart';
import 'package:hirakata/features/learn/presentation/kana_list_screen.dart';
import 'package:hirakata/features/learn/presentation/lesson_detail_screen.dart';
import 'package:hirakata/features/practice/presentation/practice_screen.dart';
import 'package:hirakata/features/progress/presentation/progress_screen.dart';
import 'package:hirakata/features/settings/presentation/developer_info_screen.dart';
import 'package:hirakata/features/settings/presentation/settings_screen.dart';
import 'package:hirakata/features/splash/presentation/splash_screen.dart';

/// Application router configuration using [GoRouter].
///
/// Defines all routes and their transitions for the HiraKata app.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: [
    // ── Splash ────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.splash,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),

    // ── Home ──────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.home,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ),

    // ── Learn (Kana Grid View) ────────────────────────────────────
    GoRoute(
      path: RouteNames.learn,
      pageBuilder: (context, state) {
        final type = state.pathParameters['type'] ?? 'hiragana';
        return CustomTransitionPage(
          key: state.pageKey,
          child: KanaListScreen(type: type),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeInOut),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

    // ── Lesson Detail Screen ──────────────────────────────────────
    GoRoute(
      path: RouteNames.lesson,
      pageBuilder: (context, state) {
        final type = state.pathParameters['type'] ?? 'hiragana';
        final id = state.pathParameters['id'] ?? '0';
        return CustomTransitionPage(
          key: state.pageKey,
          child: LessonDetailScreen(type: type, id: id),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeInOut),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),

    // ── Practice ──────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.practice,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PracticeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: Curves.easeInOut),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),

    // ── Progress ──────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.progress,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProgressScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: Curves.easeInOut),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),

    // ── Settings ──────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.settings,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: Curves.easeInOut),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),

    // ── Developer Info ────────────────────────────────────────────
    GoRoute(
      path: RouteNames.developerInfo,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DeveloperInfoScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: Curves.easeInOut),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
  ],
);
