import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UiUtil {
  static String formatLargeIntValue({
    required BuildContext context,
    required int value,
  }) {
    String formattedValueStr;

    if (value < 1000000) {
      formattedValueStr =
          '${value ~/ 1000} K${AppLocalizations.of(context)!.octetShort}';
    } else {
      formattedValueStr =
          '${(value / 1000000).toStringAsFixed(2)} M${AppLocalizations.of(context)!.octetShort}';
    }
    return formattedValueStr;
  }
}
