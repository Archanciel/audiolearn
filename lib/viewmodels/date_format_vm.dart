import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/settings_data_service.dart';

class DateFormatVM extends ChangeNotifier {
  static const List<String> dateFormatList = [
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy/MM/dd',
  ];

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
  void setDateFormat(String newDateFormat) {
    _selectedFormat = newDateFormat;

    _settingsDataService.set(
      settingType: SettingType.formatOfDate,
      settingSubType: FormatOfDate.formatOfDate,
      value: newDateFormat,
    );

    _settingsDataService.saveSettings();

    notifyListeners(); // Notify all listeners to rebuild
  }

  /// Select a date format from the list of available formats.
  /// 
  /// 0 --> 'dd/MM/yyyy'
  /// 1 --> 'MM/dd/yyyy'
  /// 2 --> 'yyyy/MM/dd'
  void selectDateFormat(int index) {
    setDateFormat(dateFormatList[index]);
  }

  // Helper function to format dates according to the selected format
  String formatDate(DateTime date) {
    return DateFormat(_selectedFormat).format(date);
  }
}
