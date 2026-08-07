import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hirakata/core/theme/app_spacing.dart';
import 'package:hirakata/core/theme/app_typography.dart';

/// Widget displaying interactive step-by-step stroke order for a character.
class StrokeOrderVisualizer extends StatefulWidget {
  const StrokeOrderVisualizer({
    super.key,
    required this.character,
    required this.strokeSteps,
    required this.accentColor,
  });

  final String character;
  final List<String> strokeSteps;
  final Color accentColor;

  @override
  State<StrokeOrderVisualizer> createState() => _StrokeOrderVisualizerState();
}

class _StrokeOrderVisualizerState extends State<StrokeOrderVisualizer> {
  int _currentStep = 0;
  bool _isPlaying = false;

  void _nextStep() {
    if (_currentStep < widget.strokeSteps.length - 1) {
      setState(() => _currentStep++);
    } else {
      setState(() => _currentStep = 0);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _toggleAutoPlay() async {
    setState(() => _isPlaying = !_isPlaying);
    while (_isPlaying && mounted) {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted || !_isPlaying) break;
      _nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalSteps = widget.strokeSteps.length;

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
          // Header
          Row(
            children: [
              Icon(
                Icons.draw_rounded,
                color: widget.accentColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Stroke Order',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  'Step ${_currentStep + 1} of $totalSteps',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Visual Display Box
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : widget.accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Grid guide lines (Japanese manuscript grid)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridGuidePainter(
                        color: widget.accentColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  // Character Display with stroke highlight pulse
                  Text(
                    widget.character,
                    style: AppTypography.kanaLarge.copyWith(
                      fontSize: 80,
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : Colors.black87,
                    ),
                  )
                      .animate(
                        key: ValueKey('step_$_currentStep'),
                      )
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        duration: 300.ms,
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Current step description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
                  : theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Text(
              totalSteps > 0
                  ? widget.strokeSteps[_currentStep]
                  : 'Follow the natural flow of strokes.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Control buttons (Prev, Play, Next)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.skip_previous_rounded),
                onPressed: _currentStep > 0 ? _prevStep : null,
                iconSize: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
                onPressed: _toggleAutoPlay,
                iconSize: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton.filledTonal(
                icon: const Icon(Icons.skip_next_rounded),
                onPressed: _nextStep,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper painter to draw faint crosshair guide lines behind the character.
class _GridGuidePainter extends CustomPainter {
  const _GridGuidePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Center vertical dashed line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Center horizontal dashed line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GridGuidePainter oldDelegate) =>
      oldDelegate.color != color;
}
