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

  late String _selectedDateFormat; // Default format
  String get selectedDateFormat => _selectedDateFormat;

  late String _selectedDateTimeFormat; // Default format
  String get selectedDateTimeFormat => _selectedDateTimeFormat;

  DateFormatVM({
    required SettingsDataService settingsDataService,
  }) : _settingsDataService = settingsDataService {
    _selectedDateFormat = settingsDataService.get(
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
  void _setDateFormat({
    required String newDateFormat,
  }) {
    _selectedDateFormat = newDateFormat;

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
  void selectDateFormat({
    required int dateFormatIndex,
  }) {
    _selectedDateFormat = dateFormatList[dateFormatIndex];
    
    _settingsDataService.set(
      settingType: SettingType.formatOfDate,
      settingSubType: FormatOfDate.formatOfDate,
      value: dateFormatList[dateFormatIndex],
    );
    
    _settingsDataService.saveSettings();
    
    notifyListeners(); 
  }

  /// Format the date according to the selected date format.
  String formatDate(DateTime date) {
    return DateFormat(_selectedDateFormat).format(date);
  }

  /// Format the date according to the selected date format.
  String formatDateTime(DateTime date) {
    return DateFormat('$_selectedDateFormat HH:mm').format(date);
  }
}
