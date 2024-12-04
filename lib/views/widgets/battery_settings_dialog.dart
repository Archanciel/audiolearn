import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:app_settings/app_settings.dart';

class BatterySettingsDialog extends StatelessWidget {
  const BatterySettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.batteryParameters,
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Open the app's settings page
            AppSettings.openAppSettings();
          },
          child: Text(
            AppLocalizations.of(context)!.disableBatteryOptimisation,
          ),
        ),
      ),
    );
  }
}
