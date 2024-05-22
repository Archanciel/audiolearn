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
  /// if utils/duration_expansion.dart is imported.
  String HHmmss() {
    int durationMinute = inMinutes.remainder(60);
    int durationSecond = inSeconds.remainder(60);
    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    return "$minusStr${inHours.abs()}:${numberFormatTwoInt.format(durationMinute.abs())}:${numberFormatTwoInt.format(durationSecond.abs())}";
  }

  /// WARNING: this method is callable on a Duration instance only
  /// if utils/duration_expansion.dart is imported.
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
  /// if utils/duration_expansion.dart is imported.
  ///
  /// Return Duration formatted as HH:mm:ss if the hours are > 0,
  /// else as mm:ss.
  ///
  /// Example: 1:45:24 or 45:24 if 0:45:24.
  ///
  /// Here's an example of how to use this method:
  ///
  /// Text(
  ///   globalAudioPlayerVM.currentAudioPosition.HHmmssZeroHH(),
  /// )
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

    // Previously, this version of computing twoDigitSeconds
    // was used:
    //
    // String twoDigitSeconds = twoDigits(inSeconds.remainder(60).abs());
    //
    // But this version was incorrect because the seconds were
    // not rounded which caused errors in the display of the
    // currently playing audio position or its remaining duration.
    // Adding the position and the remaining duration of the
    // currently playing audio gave a duration which was not
    // equal to the total duration of the audio, but was
    // 1 second less.
    //
    // A lot of usage examples can be found in the unit
    // duration_expansion_test.dart, group 'DurationExpansion
    // HHmmssZeroHH ensuring durations are correctly rounded
    // (test not performed in DateTimeParser test)'

    int secondsRounded = (inMilliseconds.remainder(60000).abs() / 1000).round();
    String twoDigitSeconds = twoDigits(secondsRounded);

    String minusStr = '';

    if (inMicroseconds < 0) {
      minusStr = '-';
    }

    if (addRemainingOneDigitTenthOfSecond) {
      int remainingOneDigitTenthOfSecond =
          (inMilliseconds - secondsRounded * 1000).abs() ~/ 100;
      return '$minusStr$hours$twoDigitMinutes:$twoDigitSeconds.$remainingOneDigitTenthOfSecond';
    }

    return '$minusStr$hours$twoDigitMinutes:$twoDigitSeconds';
  }
}
