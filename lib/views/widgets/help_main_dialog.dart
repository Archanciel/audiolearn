import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants.dart';

class HelpMainDialog extends StatelessWidget {
  const HelpMainDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.helpMainTitle,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.helpMainIntroduction,
              style: kDialogTextFieldStyle,
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuItem(
                      context: context,
                      icon: Icons.key,
                      title: AppLocalizations.of(context)!.helpAudioLearnIntroductionTitle,
                      subtitle: AppLocalizations.of(context)!.helpAudioLearnIntroductionSubTitle,
                      onTap: () {
                        // Navigate to Account settings or show details
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.key,
                      title: AppLocalizations.of(context)!.helpLocalPlaylistTitle,
                      subtitle: AppLocalizations.of(context)!.helpLocalPlaylistSubTitle,
                      onTap: () {
                        // Navigate to Account settings or show details
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.key,
                      title: AppLocalizations.of(context)!.helpPlaylistMenuTitle,
                      subtitle: AppLocalizations.of(context)!.helpPlaylistMenuSubTitle,
                      onTap: () {
                        // Navigate to Account settings or show details
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.key,
                      title: AppLocalizations.of(context)!.helpAudioMenuTitle,
                      subtitle: AppLocalizations.of(context)!.helpAudioMenuSubTitle,
                      onTap: () {
                        // Navigate to Account settings or show details
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    IconData? icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      // leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
