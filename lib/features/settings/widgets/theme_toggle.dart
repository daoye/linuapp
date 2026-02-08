import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/features/settings/settings_provider.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LinuSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: LinuSpacing.md),
            Text(
              l10n.theme,
              style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.systemTheme,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  icon: const Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.lightTheme,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      l10n.darkTheme,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(settingsProvider.notifier).setThemeMode(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
