import 'package:flutter/material.dart';

import '../services/settings_data_service.dart';

/// This VM (View Model) class is part of the MVVM architecture.
///
class LanguageProviderVM extends ChangeNotifier {
  final SettingsDataService _settingsDataService;

  late Locale _currentLocale;
  Locale get currentLocale => _currentLocale;

  LanguageProviderVM({
    required SettingsDataService settingsDataService,
  }) : _settingsDataService = settingsDataService {
    Language language = settingsDataService.get(
      settingType: SettingType.language,
      settingSubType: SettingType.language,
    );

    if (language == Language.english) {
      _currentLocale = const Locale('en');
    } else if (language == Language.french) {
      _currentLocale = const Locale('fr');
    } else {
      // setting default language to english
      _currentLocale = const Locale('en');
    }
  }

  void changeLocale(Locale newLocale) {
    _currentLocale = newLocale;
    Language language;

    if (newLocale == const Locale('en')) {
      language = Language.english;
    } else if (newLocale == const Locale('fr')) {
      language = Language.french;
    } else {
      // setting default language to english
      _currentLocale = const Locale('en');
      language = Language.english;
    }

    _settingsDataService.set(
        settingType: SettingType.language,
        settingSubType: SettingType.language,
        value: language);

    _settingsDataService.saveSettings();

    notifyListeners();
  }
}
