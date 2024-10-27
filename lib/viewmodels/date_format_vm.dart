import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/settings_data_service.dart';

class DateFormatVM extends ChangeNotifier {
  final SettingsDataService _settingsDataService;

  late String _selectedFormat; // Default format
  String get selectedFormat => _selectedFormat;

  DateFormatVM({
    required SettingsDataService settingsDataService,
  }) : _settingsDataService = settingsDataService {
    _selectedFormat = settingsDataService.get(
      settingType: SettingType.formatOfDate,
      settingSubType: FormatOfDate.formatOfDate,
    );
  }

  /// Update the selected date format.
  ///
  /// {newDateFormat} can be any of the following:
  ///   - 'dd/MM/yyyy'
  ///   - 'MM/dd/yyyy'
  ///   - 'yyyy/MM/dd'
  void updateFormat(String newDateFormat) {
    _selectedFormat = newDateFormat;

    _settingsDataService.set(
      settingType: SettingType.formatOfDate,
      settingSubType: FormatOfDate.formatOfDate,
      value: newDateFormat,
    );

    _settingsDataService.saveSettings();

    notifyListeners(); // Notify all listeners to rebuild
  }

  // Helper function to format dates according to the selected format
  String formatDate(DateTime date) {
    return DateFormat(_selectedFormat).format(date);
  }
}
