import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../viewmodels/playlist_list_vm.dart';

class UiUtil {
  static String formatLargeSizeToKbOrMb({
    required BuildContext context,
    required int sizeInBytes,
  }) {
    String formattedValueStr;

    if (sizeInBytes < 1000000) {
      formattedValueStr =
          '${sizeInBytes ~/ 1000} K${AppLocalizations.of(context)!.octetShort}';
    } else {
      formattedValueStr =
          '${(sizeInBytes / 1000000).toStringAsFixed(2)} M${AppLocalizations.of(context)!.octetShort}';
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

  static Future<void> savePlaylistAndCommentsToZip({
    required BuildContext context,
  }) async {
    String? selectedFilePathNameLst = await filePickerSelectTargetDir();

    if (selectedFilePathNameLst == null) {
      return;
    }

    await Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).savePlaylistsCommentsAndSettingsJsonFilesToZip(
      targetDirectoryPath: selectedFilePathNameLst,
    );
  }

  static
  Future<String?> filePickerSelectTargetDir() async {
    return await FilePicker.platform.getDirectoryPath();
  }

}
