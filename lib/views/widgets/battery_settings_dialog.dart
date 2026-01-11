import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/language_provider_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';

/// This dialog is displayed when the user selects the battery settings menu item
/// from the application left appbar popup menu. It contains informations to enable
/// the user to correctly set the Android Battery option to "Unrestricted", which
/// enables the app to automatically play the next audio in the current playlist.
class BatterySettingsDialog extends StatelessWidget with ScreenMixin {
  BatterySettingsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVMlistenFalse =
        Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    ); // by default, listen is true

    LanguageProviderVM languageProviderVMlistenFalse =
        Provider.of<LanguageProviderVM>(
      context,
      listen: false,
    );

    return Theme(
      data: themeProviderVMlistenFalse.currentTheme == AppTheme.dark
          ? ScreenMixin.themeDataDark
          : ScreenMixin.themeDataLight,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.batteryParameters,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                const SizedBox(height: 40),
                // Add the first image with width constraints
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Image.asset(
                      (languageProviderVMlistenFalse.currentLocale ==
                              const Locale('en'))
                          ? 'assets/images/battery_option_access_en.jpg'
                          : 'assets/images/battery_option_access_fr.jpg',
                      fit: BoxFit.contain,
                      width: constraints
                          .maxWidth, // Limit width to the screen width
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Add the second image with width constraints
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Image.asset(
                      (languageProviderVMlistenFalse.currentLocale ==
                              const Locale('en'))
                          ? 'assets/images/battery_option_selection_en.jpg'
                          : 'assets/images/battery_option_selection_fr.jpg',
                      fit: BoxFit.contain,
                      width: constraints
                          .maxWidth, // Limit width to the screen width
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
