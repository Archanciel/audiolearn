import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../models/audio.dart';

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

  static List<Color?> generateAudioStateColors({
    required Audio audio,
    required int audioIndex,
    required int currentAudioIndex,
    required bool isDarkTheme,
  }) {
    Color? audioTitleTextColor;
    Color? audioTitleBackgroundColor;

    if (audioIndex == currentAudioIndex) {
      return generateCurrentAudioStateColors();
    } else if (audio.wasFullyListened()) {
      audioTitleTextColor = (isDarkTheme)
          ? kSliderThumbColorInDarkMode
          : kSliderThumbColorInLightMode;
      audioTitleBackgroundColor = null;
    } else if (audio.isPartiallyListened()) {
      audioTitleTextColor = Colors.blue;
      audioTitleBackgroundColor = null;
    } else {
      // is not listened
      audioTitleTextColor = (isDarkTheme) ? Colors.white : Colors.black;
      audioTitleBackgroundColor = null;
    }

    return [audioTitleTextColor, audioTitleBackgroundColor];
  }

  static List<Color?> generateCurrentAudioStateColors() {
    return [Colors.white, Colors.blue];
  }
}
