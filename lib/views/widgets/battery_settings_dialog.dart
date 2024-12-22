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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.disableBatteryOptimisation,
                style: kDialogTextFieldStyle,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Open the app's settings page
                  AppSettings.openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      kButtonColor, // Set button color in dark mode
                  foregroundColor:
                      Colors.white, // Set button text color in dark mode
                ),
                child: Text(
                  AppLocalizations.of(context)!.openBatteryOptimisationButton,
                ),
              ),
              const SizedBox(height: 30),
              // Add the first image with width constraints
              LayoutBuilder(
                builder: (context, constraints) {
                  return Image.asset(
                    'assets/images/batterie_option_access_fr.jpg',
                    fit: BoxFit.contain,
                    width:
                        constraints.maxWidth, // Limit width to the screen width
                  );
                },
              ),
              const SizedBox(height: 30),
              // Add the second image with width constraints
              LayoutBuilder(
                builder: (context, constraints) {
                  return Image.asset(
                    'assets/images/batterie_option_selection_fr.jpg',
                    fit: BoxFit.contain,
                    width:
                        constraints.maxWidth, // Limit width to the screen width
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
