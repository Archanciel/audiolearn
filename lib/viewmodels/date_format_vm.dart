import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/settings_data_service.dart';

class DateFormatVM extends ChangeNotifier {
  static const List<String> dateFormatLst = [
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy/MM/dd',
  ];

  static const List<String> dateYyFormatLst = [
    'dd/MM/yy',
    'MM/dd/yy',
    'yy/MM/dd',
  ];

  // Values used in the audio sort/filter dialog
  static const List<String> dateFormatLowCaseLst = [
    'dd/mm/yyyy',
    'mm/dd/yyyy',
    'yyyy/mm/dd',
  ];

  final SettingsDataService _settingsDataService;

  late String _selectedDateFormat;
  String get selectedDateFormat => _selectedDateFormat;

  late String _selectedDateYyFormat;
  String get selectedDateYyFormat => _selectedDateYyFormat;

  // Value used in the audio sort/filter dialog
  late String _selectedDateFormatLowCase;
  String get selectedDateFormatLowCase => _selectedDateFormatLowCase;

  DateFormatVM({
    required SettingsDataService settingsDataService,
  }) : _settingsDataService = settingsDataService {
    _selectedDateFormat = settingsDataService.get(
      settingType: SettingType.formatOfDate,
      settingSubType: FormatOfDate.formatOfDate,
    );

    int dateFormatIndex = dateFormatLst.indexOf(_selectedDateFormat);

    _selectedDateYyFormat = dateYyFormatLst[dateFormatIndex];
    _selectedDateFormatLowCase = dateFormatLowCaseLst[dateFormatIndex];
  }

  /// Select a date format from the list of available formats
  /// and save it to the application settings.
  ///
  /// 0 --> 'dd/MM/yyyy'
  /// 1 --> 'MM/dd/yyyy'
  /// 2 --> 'yyyy/MM/dd'
  void selectDateFormat({
    required int dateFormatIndex,
  }) {
    _selectedDateFormat = dateFormatLst[dateFormatIndex];
    _selectedDateYyFormat = dateYyFormatLst[dateFormatIndex];
    _selectedDateFormatLowCase = dateFormatLowCaseLst[dateFormatIndex];

    _settingsDataService.set(
      settingType: SettingType.formatOfDate,
      settingSubType: FormatOfDate.formatOfDate,
      value: dateFormatLst[dateFormatIndex],
    );

    _settingsDataService.saveSettings();

    notifyListeners();
  }

  /// Format the date according to the selected date format.
  String formatDate(DateTime date) {
    return DateFormat(_selectedDateFormat).format(date);
  }

  /// Format the date with 2 characters year according to the selected date format.
  String formatDateYy(DateTime date) {
    return DateFormat(_selectedDateYyFormat).format(date);
  }

  /// Format the date according to the selected date format.
  String formatDateTime(DateTime date) {
    return DateFormat('$_selectedDateFormat HH:mm').format(date);
  }

  /// Parses a date string into a DateTime object based on the application date
  /// format.
  ///
  /// If the passed dateStr is empty, null is returned.
  ///
  /// Returns the parsed DateTime if successful, otherwise return null.
  DateTime? parseDateStrUsinAppDateFormat({
    required String dateStr,
  }) {
    if (dateStr.isEmpty) {
      return null;
    }

    // Try parsing the date string using each format.
    try {
      return DateFormat(_selectedDateFormat).parseStrict(dateStr);
    } catch (_) {
      return null;
    }
  }
}
