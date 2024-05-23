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
}
