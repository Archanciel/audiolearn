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

  static int convertToTenthsOfSeconds({
    required String timeString,
  }) {
    // Split the time string into hours, minutes, seconds, and tenths of a second
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
}
