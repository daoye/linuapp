import 'package:flutter/material.dart';
import 'package:app/shared/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !isLoading,
      label: label,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: AnimationDurations.fast,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Row(
                  key: const ValueKey('content'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
