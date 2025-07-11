/// WARNING: these methods are callable on a DateTime instance only
/// if utils/date_time_expansion.dart is imported
/// (import '../utils/date_time_expansion.dart';)
extension DateTimeExtension on DateTime {
  bool isAtOrAfter(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }
}