import 'package:audiolearn/utils/duration_expansion.dart';

class DateTimeUtil {
  static DateTime getDateTimeLimitedToSeconds(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  static bool areDateTimesEqualWithinTolerance({
    required DateTime dateTimeOne,
    required DateTime dateTimeTwo,
    required int toleranceInSeconds,
  }) {
    final difference = dateTimeOne.difference(dateTimeTwo).inSeconds;
    return difference.abs() <= toleranceInSeconds;
  }

  /// Converts a time string to tenths of a second. Passed time string
  /// can be in the format of hh:mm:ss or hh:mm:ss.t or mm:ss or mm:ss.t.
  /// It can be negative as well: -hh:mm:ss or -hh:mm:ss.t or -mm:ss or
  /// -mm:ss.t.
  ///
  /// Example: 1:45:24.4 -> 6324, 0:52.4 -> 524
  ///         -1:45:24.4 -> -6324, -0:52.4 -> -524
  ///          10:00 -> 600, 10:00.1 -> 601
  ///         -10:00 -> -600, -10:00.1 -> -601
  static int convertToTenthsOfSeconds({
    required String timeString,
  }) {
    // Remove leading and trailing whitespaces
    timeString = timeString.trim();

    // Check if the time string is negative
    bool isNegative = timeString.startsWith('-');

    // Remove the negative sign if the time string is negative
    if (isNegative) {
      timeString = timeString.substring(1);
    }

    // Split the time string into hours, minutes, seconds, and tenths of second
    List<String> parts = timeString.split(':');
    int hours = 0;
    int minutes = 0;
    int totalTenthsOfSeconds;

    if (parts.length == 3) {
      // Parse hours, minutes, and seconds
      hours = int.parse(parts[0]);
      minutes = int.parse(parts[1]);

      totalTenthsOfSeconds = computeTenthOfSeconds(
        secondsStr: parts[2],
        hours: hours,
        minutes: minutes,
      );
    } else if (parts.length == 2) {
      // Parse minutes and seconds
      minutes = int.parse(parts[0]);

      totalTenthsOfSeconds = computeTenthOfSeconds(
          secondsStr: parts[1], hours: hours, minutes: minutes);
    } else {
      // Parse seconds
      totalTenthsOfSeconds = computeTenthOfSeconds(
          secondsStr: parts[0], hours: hours, minutes: minutes);
    }

    if (isNegative) {
      totalTenthsOfSeconds = -totalTenthsOfSeconds;
    }

    return totalTenthsOfSeconds;
  }

  static int computeTenthOfSeconds({
    required String secondsStr,
    required int hours,
    required int minutes,
  }) {
    List<String> secondsParts = secondsStr.split('.');

    int seconds = 0;
    int tenthsOfSecond = 0;

    if (secondsParts[0] == secondsStr) {
      seconds = int.parse(secondsStr);
    } else {
      seconds = int.parse(secondsParts[0]);
      tenthsOfSecond = int.parse(secondsParts[1]);
    }

    // Create a Duration object from the parsed values
    Duration duration = Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: tenthsOfSecond * 100,
    );

    return (duration.inMilliseconds / 100).round();
  }

  /// Converts a time string with tenths of a second to a time
  /// string with seconds.
  ///
  /// Example: 1:45:24.4 -> 1:45:24, 1:45:24.5 -> 1:45:25
  ///          0:52.4 -> 0:52, 0:52.5 -> 0:53
  static String convertTimeWithTenthOfSecToTimeWithSec({
    required String timeWithTenthOfSecondsStr,
  }) {
    int tenthOfSeconds = DateTimeUtil.convertToTenthsOfSeconds(
      timeString: timeWithTenthOfSecondsStr,
    );

    Duration duration = Duration(milliseconds: tenthOfSeconds * 100);
    String timeWithSecondsOnlyStr =
        duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: false);

    return timeWithSecondsOnlyStr;
  }

  /// Removes the date and time elements from the passed file name.
  /// The date and time elements are expected to be in the format
  /// of "YYMMDD-HHMMSS-" at the beginning of the file name and
  /// " HH-MM-SS" at the end of the file name.
  ///
  /// Example: "240528-130636-Interview de Chat GPT  - IA, intelligence,
  /// philosophie, géopolitique, post-vérité... 24-01-12" is returned
  /// as "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique,
  /// post-vérité..."
  static String removeDateTimeElementsFromFileName(String fileName) {
    // Regular expression to match the prefix and suffix
    final regex = RegExp(r'^\d{6}-\d{6}-| \d{2}-\d{2}-\d{2}$');
    return fileName.replaceAll(regex, '');
  }

  static String formatSecondsToHHMMSS({
    required int seconds,
  }) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    // Format the result with leading zeros for single digits
    String formattedTime = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  static String formatSecondsToHHMM({
    required int seconds,
  }) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;

    // Format the result with leading zeros for single digits
    String formattedTime = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';

    return formattedTime;
  }
}
