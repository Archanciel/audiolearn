import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BatterySettingsPage extends StatelessWidget {
  const BatterySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!
                .appBarMenuEnableNextAudioAutoPlay),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (Platform.isAndroid) {
              final intent = AndroidIntent(
                action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
              );
              intent.launch();
            } else {
              // iOS doesn't have direct access to battery optimization settings
              print("Battery optimization settings are not available on iOS.");
            }
          },
          child: Text(AppLocalizations.of(context)!
                .appBarMenuEnableNextAudioAutoPlay),
        ),
      ),
    );
  }
}
