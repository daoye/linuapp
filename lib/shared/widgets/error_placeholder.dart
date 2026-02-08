import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/shared/utils.dart';
import 'package:app/shared/constants.dart';
import 'package:app/l10n/app_localizations.dart';

/// Widget to display when message content is malformed or unavailable
class ErrorPlaceholder extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorPlaceholder({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefersReducedMotion = AppUtils.prefersReducedMotion(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            )
                .animate()
                .fadeIn(
                  duration: prefersReducedMotion
                      ? Duration.zero
                      : AnimationDurations.slow,
                )
                .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: prefersReducedMotion
                      ? Duration.zero
                      : AnimationDurations.slow,
                ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Message Error',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(
                  duration: prefersReducedMotion
                      ? Duration.zero
                      : AnimationDurations.slow,
                  delay: prefersReducedMotion
                      ? Duration.zero
                      : AnimationDurations.delayMedium,
                ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
              ).animate().fadeIn(
                    duration: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.slow,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.delayLong,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget to display when image fails to load
class ImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final String? errorMessage;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height ?? 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
