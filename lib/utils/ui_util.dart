import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../viewmodels/playlist_list_vm.dart';
import 'dir_util.dart';

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

  /// Returns a list containing the audio title text color and the audio title
  /// background color.
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

  /// Returns a list containing the audio title text color and the audio title
  /// background color.
  static List<Color?> generateCurrentAudioStateColors() {
    return [Colors.white, Colors.blue];
  }

  static Future<void> savePlaylistsCommentsAndAppSettingsToZip({
    required BuildContext context,
  }) async {
    String? targetSaveDirectoryPath = await filePickerSelectTargetDir();

    if (targetSaveDirectoryPath == null) {
      return;
    }

    await Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).savePlaylistsCommentsPicturesAndSettingsJsonFilesToZip(
      targetDirectoryPath: targetSaveDirectoryPath,
    );
  }

  static Future<void> restorePlaylistsCommentsAndAppSettingsFromZip({
    required BuildContext context,
    required bool doReplaceExistingPlaylists,
  }) async {
    String selectedZipFilePathName = await filePickerSelectZipFilePathName();

    if (selectedZipFilePathName.isEmpty) {
      return;
    }

    await Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).restorePlaylistsCommentsAndSettingsJsonFilesFromZip(
      zipFilePathName: selectedZipFilePathName,
      doReplaceExistingPlaylists: doReplaceExistingPlaylists,
    );
  }

  static Future<String?> filePickerSelectTargetDir() async {
    return await FilePicker.platform.getDirectoryPath();
  }

  static Future<String> filePickerSelectPictureFilePathName() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg'],
      allowMultiple: false,
      initialDirectory: DirUtil.getApplicationPath(),
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first.path ?? '';
    }

    return '';
  }

  static Future<String> filePickerSelectZipFilePathName() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      allowMultiple: false,
      withData: false,
      initialDirectory: Platform.isAndroid ? '/storage/emulated/0' : null,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first.path ?? '';
    }

    return '';
  }

  static bool isAudioPlayable({
    required Audio audio,
  }) {
    return File(audio.filePathName).existsSync();
  }
}
