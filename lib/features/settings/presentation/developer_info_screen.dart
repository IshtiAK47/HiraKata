import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hirakata/core/theme/app_colors.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/app_typography.dart';

/// Screen displaying Developer Information and Project Links.
class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer & App Info'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),

              // ── Developer Profile Card ──────────────────────────────
              Container(
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
                  border: Border.all(
                    color: AppColors.seed.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.seed.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.seed.withValues(alpha: 0.2),
                        border: Border.all(
                          color: AppColors.seed,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.code_rounded,
                          size: 44,
                          color: AppColors.seed,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Ishtiak Mahmood',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Software Engineer & App Developer',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                  ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Developer Links Section ─────────────────────────────
              Text('Developer Links', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),

              _LinkTile(
                icon: Icons.code_outlined,
                title: 'GitHub Profile',
                subtitle: 'github.com/ishtiak47',
                url: 'https://github.com/ishtiak47',
                onTap: () => _launchUrl(context, 'https://github.com/ishtiak47'),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

              const SizedBox(height: AppSpacing.md),

              _LinkTile(
                icon: Icons.language_rounded,
                title: 'Personal Portfolio Website',
                subtitle: 'www.ishtiak47.me',
                url: 'https://www.ishtiak47.me',
                onTap: () => _launchUrl(context, 'https://www.ishtiak47.me'),
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

              const SizedBox(height: AppSpacing.xxl),

              // ── Project Repository Section ──────────────────────────
              Text('Project Source Code', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),

              _LinkTile(
                icon: Icons.folder_special_outlined,
                title: 'HiraKata GitHub Repository',
                subtitle: 'github.com/IshtiAK47/HiraKata',
                url: 'https://github.com/IshtiAK47/HiraKata',
                accentColor: AppColors.katakana,
                onTap: () =>
                    _launchUrl(context, 'https://github.com/IshtiAK47/HiraKata'),
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.onTap,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String url;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = accentColor ?? AppColors.hiragana;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
