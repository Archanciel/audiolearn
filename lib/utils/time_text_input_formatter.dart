// lib/utils/time_text_input_formatter.dart
import 'package:flutter/services.dart';

/// Permissive input formatter for times "h:mm:ss.t", "mm:ss.t", "ss.t", numbers.
/// If you do NOT want to accept negative values, remove the leading "-" from the regex.
class TimeTextInputFormatter extends TextInputFormatter {
  final _valid = RegExp(r'^-?[0-9:.\s]*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.length > newValue.text.length) {
      // Allow deletions freely.
      return newValue;
    }
    if (!_valid.hasMatch(newValue.text)) return oldValue;
    return newValue;
  }
}
