// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';

/// WARNING: these methods are callable on a Duration instance only
/// if utils/duration_expansion.dart is imported
/// (import '../utils/duration_expansion.dart';)
///
/// Add format methods to the Duration class.
extension DurationExpansion on Duration {
  static final NumberFormat numberFormatTwoInt = NumberFormat('00');

  /// Returns the Duration formatted as HH:mm.
  String HHmm() {
    int durationMinute = inMinutes.remainder(60);
    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }

  /// WARNING: this method is callable on a Duration instance only
  /// if utils/duration_expansion.dart is imported in the code file
  /// where this method is called.
  ///
  /// Returns the Duration formatted as HH:mm:ss.
  ///
  /// If the Duration is negative, the minus sign is added to
  /// the formatted Duration.
  ///
  /// If addRemainingOneDigitTenthOfSecond is true, the Duration
  /// is formatted as HH:mm:ss.t where t is the remaining tenth
  /// of second.
  String HHmmss({
    bool addRemainingOneDigitTenthOfSecond = false,
  }) {
    int durationMinute = inMinutes.remainder(60);
    int durationSecond = inSeconds.remainder(60);
    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    if (addRemainingOneDigitTenthOfSecond) {
      // the case when the method is called in the CommentAddEditDialogWidget
      // when the user is defining a comment position in tenth of seconds
      int remainingOneDigitTenthOfSecond =
          inMilliseconds.remainder(1000).abs() ~/
              100; // the remaining tenth of second

      return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}:${numberFormatTwoInt.format(durationSecond.abs())}.$remainingOneDigitTenthOfSecond";
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}:${numberFormatTwoInt.format(durationSecond.abs())}";
  }

  /// WARNING: this method is callable on a Duration instance only
  /// if utils/duration_expansion.dart is imported in the code file
  /// where this method is called.
  ///
  /// Returns the Duration formatted as dd:HH:mm
  String ddHHmm() {
    int durationMinute = inMinutes.remainder(60);
    int durationHour =
        Duration(minutes: (inMinutes - durationMinute)).inHours.remainder(24);
    int durationDay = Duration(hours: (inHours - durationHour)).inDays;
    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    return "$minusStr${numberFormatTwoInt.format(durationDay.abs())}:${numberFormatTwoInt.format(durationHour.abs())}:${numberFormatTwoInt.format(durationMinute.abs())}";
  }

  /// WARNING: this method is callable on a Duration instance only
  /// if utils/duration_expansion.dart is imported in the code file
  /// where this method is called.
  ///
  /// Return Duration formatted as HH:mm:ss if the hours are > 0,
  /// else as mm:ss.
  ///
  /// Example: 1:45:24 or 45:24 if 0:45:24 or 1:45:24.8 or 45:24.3
  /// if 0:45:24.3
  ///
  /// Here's an example of how to use this method:
  ///
  /// Text(
  ///   audioPlayerVM.currentAudioPosition.HHmmssZeroHH(),
  /// )
  ///
  /// If addRemainingOneDigitTenthOfSecond is true, the Duration
  /// is formatted as HH:mm:ss.t where t is the remaining tenth
  /// of second. Else, the .t tenth of seconds is rounded to the
  /// nearest second. 0:52.4 --> 0:52, 0:52.5 --> 0:53.
  String HHmmssZeroHH({
    bool addRemainingOneDigitTenthOfSecond = false,
  }) {
    String hoursStr = '';

    int hoursInt = inHours.abs();

    if (hoursInt > 0) {
      hoursStr = '$hoursInt:';
    }

    int remainingMinuteInt = inMinutes.remainder(60).abs();

    String remainingMinutesStr;

    if (hoursInt > 0) {
      remainingMinutesStr = twoDigits(remainingMinuteInt);
    } else {
        remainingMinutesStr = remainingMinuteInt.toString();
    }

    String minusStr = inMicroseconds < 0 ? '-' : '';

    if (addRemainingOneDigitTenthOfSecond) {
      int secondsInt = inSeconds.remainder(60).abs();
      int remainingOneDigitTenthOfSecond =
          (inMilliseconds.remainder(1000).abs() / 100).round();

      if (remainingOneDigitTenthOfSecond == 10) {
        remainingOneDigitTenthOfSecond = 0;
        secondsInt++;
      }

      String twoDigitSecondsStr = twoDigits(secondsInt);
      return '$minusStr$hoursStr$remainingMinutesStr:$twoDigitSecondsStr.$remainingOneDigitTenthOfSecond';
    } else {
      int secondsRounded =
          (inMilliseconds.remainder(60000).abs() / 1000).round();
      String twoDigitSecondsStr = twoDigits(secondsRounded).toString();

      return '$minusStr$hoursStr$remainingMinutesStr:$twoDigitSecondsStr';
    }
  }

  String twoDigits(int n) {
    if (n >= 10) {
      return "$n";
    }
    
    return "0$n";
  }
}
