import '../constants.dart';

class DateTimeParser {
  static final RegExp regExpYYYYDateTime =
      RegExp(r'^(\d+/\d+/\d{4})\s(\d+:\d{2})');
  static final RegExp regExpNoYearDateTime = RegExp(r'^(\d+/\d+)\s(\d+:\d{2})');
  static final RegExp regExpHHMMorMMSSTime = RegExp(r'(^[-]?\d+:\d{2})');
  static final RegExp regExpHHAnyMMTime = RegExp(r'(^[-]?\d+:\d+)');
  static final RegExp regExpAllHHMMTime = RegExp(r'([-]?\d+:\d{2})');
  static final RegExp regExpDDHHMMTime = RegExp(r'(^[-]?\d+:\d+:\d{2})');
  static final RegExp regExpDDHHAnyMMTime = RegExp(r'(^[-]?\d+:\d+:\d+)');

  /// Parses the passed hourMinuteStr or minuteSecondStr formatted
  /// as hh:mm or h:mm or -hh:mm or -h:mm for hourMinuteStr or as
  /// mm:ss or m:ss or -mm:ss or -m:ss for minuteSecondStr and
  /// returns the hh:mm, h:mm, -hh:mm or -h:mm / mm:ss or m:ss
  /// or -mm:ss or -m:ss parsed String or null if the passed
  /// time string does not respect the hourMinuteStr or
  /// minuteSecondStr format, like 03:2 or 3:2 or 03-02 or 03:a2
  /// or -03:2 or -3:2 or -03-02 or -03:a2 for example.
  static String? parseHHMMorMMSSTimeStr(String hourMinuteStr) {
    final RegExpMatch? match = regExpHHMMorMMSSTime.firstMatch(hourMinuteStr);
    final String? parsedHourMinuteStr = match?.group(1);

    return parsedHourMinuteStr;
  }

  /// Parses the passed dayHourMinuteStr duration formatted as
  /// 
  /// dd:hh:mm or
  /// -dd:hh:mm or
  /// d:hh:mm or
  /// -d:hh:mm or
  /// hh:mm or
  /// -hh:mm or
  /// h:mm or
  /// -h:mm
  /// 
  /// and returns
  /// 
  /// dd:hh:mm or
  /// -dd:hh:mm or
  /// d:hh:mm or
  /// -d:hh:mm or
  /// hh:mm or
  /// -hh:mm or
  /// h:mm or
  /// -h:mm
  /// 
  /// parsed String or null if the passed dayHourMinuteStr does not respect the
  /// format examples listed above, like 03:2 or 3:2 or 03-02 or 03:a2 or -03:2 or
  /// -3:2 or -03-02 or -03:a2 for example.
  static String? parseDDHHMMDurationStr(String dayHourMinuteStr) {
    final RegExpMatch? match = regExpDDHHMMTime.firstMatch(dayHourMinuteStr);
    final String? parsedDayHourMinuteStr = match?.group(1);

    return parsedDayHourMinuteStr;
  }

  /// Parses the passed mm:ss (12:35) minuteSecondStr and returns
  /// a Duration instanciated with the parsed minute and second
  /// values.
  static Duration? parseMMSSDuration(String minuteSecondStr) {
    final String? parsedMinuteSecondStr =
        DateTimeParser.parseHHMMorMMSSTimeStr(minuteSecondStr);

    if (parsedMinuteSecondStr != null) {
      List<String> minuteSecondStrLst = parsedMinuteSecondStr.split(':');
      List<int> minuteSecondIntLst = minuteSecondStrLst
          .map((element) => int.parse(element))
          .toList(growable: false);

      final int minuteInt = minuteSecondIntLst[0].abs();
      int secondInt = minuteSecondIntLst[1].abs();

      Duration duration = Duration(minutes: minuteInt, seconds: secondInt);

      if (minuteSecondStrLst[0].startsWith('-')) {
        return Duration.zero - duration;
      } else {
        return duration;
      }
    }

    return null;
  }

  /// Parses the passed HH:mm (12:35) hourMinuteStr and returns a Duration
  /// instanciated with the parsed hour and minute values.
  static Duration? parseHHMMDuration(String hourMinuteStr) {
    final String? parsedHourMinuteStr =
        DateTimeParser.parseHHMMorMMSSTimeStr(hourMinuteStr);

    if (parsedHourMinuteStr != null) {
      List<String> hourMinuteStrLst = parsedHourMinuteStr.split(':');
      List<int> hourMinuteIntLst = hourMinuteStrLst
          .map((element) => int.parse(element))
          .toList(growable: false);

      final int hourInt = hourMinuteIntLst[0].abs();
      int minuteInt = hourMinuteIntLst[1].abs();

      Duration duration = Duration(hours: hourInt, minutes: minuteInt);

      if (hourMinuteStrLst[0].startsWith('-')) {
        return Duration.zero - duration;
      } else {
        return duration;
      }
    }

    return null;
  }

  /// Parses the passed dayHourMinuteStr and returns a Duration
  /// instanciated with the parsed day, hour and minute values.
  static Duration? parseDDHHMMDuration(String dayHourMinuteStr) {
    final String? parsedDayHourMinuteStr =
        DateTimeParser.parseDDHHMMDurationStr(dayHourMinuteStr);

    if (parsedDayHourMinuteStr != null) {
      List<String> dayHourMinuteStrLst = parsedDayHourMinuteStr.split(':');
      List<int> hourMinuteIntLst = dayHourMinuteStrLst
          .map((element) => int.parse(element))
          .toList(growable: false);

      final int dayInt = hourMinuteIntLst[0];
      final int hourInt = hourMinuteIntLst[1];
      final int minuteInt = hourMinuteIntLst[2];

      Duration duration =
          Duration(days: dayInt, hours: hourInt, minutes: minuteInt);

      if (dayHourMinuteStr.startsWith('-00')) {
        return Duration.zero - duration;
      } else {
        return duration;
      }
    }

    return null;
  }

  /// Parses the passed dayHourMinuteStr or hourMinuteStr and
  /// returns a Duration instanciated with the parsed hour and
  /// minute values.
  static Duration? parseDDHHMMorHHMMDuration(String dayHourMinuteStr) {
    final String? parsedDayHourMinuteStr =
        DateTimeParser.parseDDHHMMDurationStr(dayHourMinuteStr);

    if (parsedDayHourMinuteStr != null) {
      return createDayHourMinuteDuration(parsedDayHourMinuteStr);
    } else {
      final String? parsedHourMinuteStr =
          DateTimeParser.parseHHMMorMMSSTimeStr(dayHourMinuteStr);
      if (parsedHourMinuteStr != null) {
        return createHourMinuteDuration(parsedHourMinuteStr);
      }
    }

    return null;
  }

  static Duration createHourMinuteDuration(String parsedHourMinuteStr) {
    List<String> dayHourMinuteStrLst = parsedHourMinuteStr.split(':');
    List<int> hourMinuteIntLst = dayHourMinuteStrLst
        .map((element) => int.parse(element))
        .toList(growable: false);

    final int hourInt = hourMinuteIntLst[0].abs();
    final int minuteInt = hourMinuteIntLst[1].abs();

    Duration duration = Duration(hours: hourInt, minutes: minuteInt);

    if (parsedHourMinuteStr.startsWith('-')) {
      return Duration.zero - duration;
    } else {
      return duration;
    }
  }

  static Duration createDayHourMinuteDuration(String parsedDayHourMinuteStr) {
    List<String> dayHourMinuteStrLst = parsedDayHourMinuteStr.split(':');
    List<int> dayHourMinuteIntLst = dayHourMinuteStrLst
        .map((element) => int.parse(element))
        .toList(growable: false);

    final int dayInt = dayHourMinuteIntLst[0].abs();
    final int hourInt = dayHourMinuteIntLst[1].abs();
    final int minuteInt = dayHourMinuteIntLst[2].abs();

    Duration duration =
        Duration(days: dayInt, hours: hourInt, minutes: minuteInt);

    if (parsedDayHourMinuteStr.startsWith('-')) {
      return Duration.zero - duration;
    } else {
      return duration;
    }
  }

  /// Returns the english formatted passed french formatted date
  /// time string. In case the passed date time string format
  /// is invalid, null is returned.
  static String? convertFrenchFormatToEnglishFormatDateTimeStr(
      {required String frenchFormatDateTimeStr}) {
    DateTime? endDateTime;
    String? englishFormatDateTimeStr;

    try {
      endDateTime = frenchDateTimeFormat.parse(frenchFormatDateTimeStr);
    // ignore: empty_catches
    } on FormatException {}

    if (endDateTime != null) {
      englishFormatDateTimeStr = englishDateTimeFormat.format(endDateTime);
    }

    return englishFormatDateTimeStr;
  }

  /// Returns the french formatted passed english formatted date
  /// time string. In case the passed date time string format
  /// is invalid, null is returned.
  static String? convertEnglishFormatToFrenchFormatDateTimeStr(
      {required String englishFormatDateTimeStr}) {
    DateTime? endDateTime;
    String? frenchFormatDateTimeStr;

    try {
      endDateTime = englishDateTimeFormat.parse(englishFormatDateTimeStr);
    // ignore: empty_catches
    } on FormatException {}

    if (endDateTime != null) {
      frenchFormatDateTimeStr = frenchDateTimeFormat.format(endDateTime);
    }

    return frenchFormatDateTimeStr;
  }

  /// Examples: 2021-01-01T10:35 --> 2021-01-01T11:00
  ///           2021-01-01T10:25 --> 2021-01-01T10:00
  static DateTime roundDateTimeToHour(DateTime dateTime) {
    if (dateTime.minute >= 30) {
      return DateTime(dateTime.year, dateTime.month, dateTime.day,
          dateTime.hour + 1, 0, 0, 0, 0);
    } else {
      return DateTime(dateTime.year, dateTime.month, dateTime.day,
          dateTime.hour, 0, 0, 0, 0);
    }
  }

  /// This method takes a DateTime object as input and returns a new DateTime
  /// object with the same year, month, day as the input, but with hour, minute,
  /// seconds and milliseconds set to zero. Essentially, it rounds the input
  /// DateTime object down to the nearest day.
  static DateTime truncateDateTimeToDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
