import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:app_settings/app_settings.dart';

import '../../constants.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)!.disableBatteryOptimisation,
              style: kDialogTextFieldStyle,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Open the app's settings page
                AppSettings.openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kButtonColor, // Set button color in dark mode
                foregroundColor:
                    Colors.white, // Set button text color in dark mode
              ),
              child: Text(
                AppLocalizations.of(context)!.openBatteryOptimisationButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
