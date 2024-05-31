// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';

/// WARNING: these methods are callable on a Duration instance only
/// if utils/duration_expansion.dart is imported.
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
      int remainingOneDigitTenthOfSecond = inMilliseconds.remainder(1000).abs() ~/
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
  ///   globalAudioPlayerVM.currentAudioPosition.HHmmssZeroHH(),
  /// )
  /// 
  /// If addRemainingOneDigitTenthOfSecond is true, the Duration
  /// is formatted as HH:mm:ss.t where t is the remaining tenth
  /// of second.
  String HHmmssZeroHH({
    bool addRemainingOneDigitTenthOfSecond = false,
  }) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = '';

    if (inHours > 0) {
      hours = '$inHours:';
    } else if (inHours == 0) {
      hours = '';
    } else {
      hours = '${inHours.abs()}:';
    }

    String twoDigitMinutes;

    if (hours.isEmpty) {
      twoDigitMinutes = inMinutes.remainder(60).abs().toString();
    } else {
      twoDigitMinutes = twoDigits(inMinutes.remainder(60).abs());
    }

    int secondsRounded = (inMilliseconds.remainder(60000).abs() / 1000).round();
    String twoDigitSeconds = twoDigits(secondsRounded);

    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    if (addRemainingOneDigitTenthOfSecond) {
      // the case when the method is called in the CommentAddEditDialogWidget
      // when the user is defining a comment position in tenth of seconds
      int remainingOneDigitTenthOfSecond =
          (inMilliseconds.remainder(60000).abs() - secondsRounded * 1000)
                  .abs() ~/
              100;
      return '$minusStr$hours$twoDigitMinutes:$twoDigitSeconds.$remainingOneDigitTenthOfSecond';
    }

    return '$minusStr$hours$twoDigitMinutes:$twoDigitSeconds';
  }
}
