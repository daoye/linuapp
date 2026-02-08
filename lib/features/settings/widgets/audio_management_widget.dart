import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/l10n/app_localizations.dart';

class AudioManagementWidget extends StatelessWidget {
  const AudioManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.library_music_outlined),
        title: Text(l10n.audioManagement),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/audio-management');
        },
      ),
    );
  }
}
