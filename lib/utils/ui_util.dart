import 'dart:io';

import 'package:audiolearn/models/playlist.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../viewmodels/date_format_vm.dart';
import '../viewmodels/playlist_list_vm.dart';
import '../viewmodels/warning_message_vm.dart';
import 'dir_util.dart';

class StorageUtil {
  /// Check if device has sufficient storage space
  static Future<bool> hasEnoughSpace({required int requiredBytes}) async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get available storage space in bytes
  static Future<int> getAvailableSpace() async {
    // This would require a platform-specific implementation
    // Consider using a plugin like 'disk_space' or 'device_info_plus'
    return 0;
  }
}

class UiUtil {
  static Logger logger = Logger();

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

  static Future<void> savePlaylistsCommentsPicturesAndAppSettingsToZip({
    required BuildContext context,
    required bool addPictureJpgFilesToZip,
  }) async {
    String? targetSaveDirectoryPath = await filePickerSelectTargetDir();

    if (targetSaveDirectoryPath == null) {
      return;
    }

    await Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).savePlaylistsCommentPictureAndSettingsJsonFilesToZip(
      targetDirectoryPath: targetSaveDirectoryPath,
      addPictureJpgFilesToZip: addPictureJpgFilesToZip,
    );
  }

  static Future<void> saveUniquePlaylistCommentsAndPicturesToZip({
    required BuildContext context,
    required Playlist playlist,
  }) async {
    String? targetSaveDirectoryPath = await filePickerSelectTargetDir();

    if (targetSaveDirectoryPath == null) {
      return;
    }

    await Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).saveUniquePlaylistCommentAndPictureJsonFilesToZip(
      playlist: playlist,
      targetDir: targetSaveDirectoryPath,
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

  static Future<void> restorePlaylistsAudioMp3FilesFromZip({
    required BuildContext context,
    required List<Playlist> playlistsLst,
    required WarningMessageVM warningMessageVMlistenFalse,
    bool uniquePlaylistIsRestored = false,
  }) async {
    String selectedZipFilePathName = await filePickerSelectZipFilePathName();

    if (selectedZipFilePathName.isEmpty) {
      return;
    }

    if (selectedZipFilePathName == 'INSUFFICIENT_STORAGE_SPACE') {
      warningMessageVMlistenFalse.setError(
        errorType: ErrorType.insufficientStorageSpace,
      );
      return;
    } else if (selectedZipFilePathName == 'PATH_ERROR') {
      warningMessageVMlistenFalse.setError(
        errorType: ErrorType.pathError,
      );

      return;
    }

    List<dynamic> resultLst = await Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).restorePlaylistsAudioMp3FilesFromZip(
      zipFilePathName: selectedZipFilePathName,
      listOfPlaylists: playlistsLst,
      uniquePlaylistIsRestored: uniquePlaylistIsRestored,
    );

    int restoredAudioCount = resultLst[0];
    int restoredPlaylistCount = resultLst[1];
    bool uniquePlaylistMp3ZipFileWasRestored = resultLst[2];

    warningMessageVMlistenFalse.confirmMp3RestorationFromMp3Zip(
      zipFilePathName: selectedZipFilePathName,
      restoredMp3Number: restoredAudioCount,
      playlistsNumber: restoredPlaylistCount,
      wasIndividualPlaylistMp3ZipUsed: uniquePlaylistMp3ZipFileWasRestored,
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
    FilePickerResult? result;

    try {
      // Check available storage first (optional enhancement)
      // bool hasSpace = await StorageUtil.hasEnoughSpace(requiredBytes: 100 * 1024 * 1024); // 100MB
      // if (!hasSpace) {
      //   logger.e('Insufficient storage space');
      //   return '';
      // }

      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
        withData: false, // Keep this false to avoid loading file into memory
        initialDirectory: Platform.isAndroid ? '/storage/emulated/0' : null,
      );

      if (result != null && result.files.isNotEmpty) {
        String? filePath = result.files.first.path;

        if (filePath != null && filePath.isNotEmpty) {
          // Verify the file exists and is accessible
          File selectedFile = File(filePath);
          if (await selectedFile.exists()) {
            return filePath;
          } else {
            logger.e('Selected file does not exist: $filePath');
          }
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'unknown_path') {
        // The ENOSPC error doesn't appear in e.message, only in native logs
        // So we need to infer it from the context or check for other indicators

        // Option 1: Check if it's likely a storage issue by checking available space
        try {
          Directory tempDir = await getTemporaryDirectory();
          // If we can't write to temp directory, it's likely a storage issue

          // Try to create a small test file to check storage
          File testFile = File('${tempDir.path}/storage_test.tmp');
          await testFile.writeAsString('test');
          await testFile.delete();

          // If we reach here, it's not a storage issue
          logger.e('Failed to retrieve file path: ${e.message}');
          return 'PATH_ERROR';
        } catch (storageError) {
          // If we can't write the test file, it's likely storage full
          logger.e('Insufficient storage space detected during file selection');
          return 'INSUFFICIENT_STORAGE_SPACE';
        }
      } else {
        logger.e(
            'Platform exception selecting zip file: ${e.code} - ${e.message}');
      }
    } catch (e) {
      logger.e('Error selecting zip file: $e');
    }

    return '';
  }

  static bool isAudioPlayable({
    required Audio audio,
  }) {
    return File(audio.filePathName).existsSync();
  }

  /// The method returns a list containing the parsed date time or date
  /// and the evaluated duration of the audio mp3 saving to zip operation.
  ///
  /// If the date time or the date parsing fails, it returns a list
  /// containing only null.
  static Future<List<dynamic>> obtainAudioMp3SavingToZipDuration({
    required PlaylistListVM playlistListVMlistenFalse,
    required DateFormatVM dateFormatVMlistenFalse,
    required WarningMessageVM warningMessageVMlistenFalse,
    required List<Playlist> playlistsLst,
    required String oldestAudioDownloadDateFormattedStr,
  }) async {
    // Since the entered date can be either a date or a date time,
    // we try to parse it as a date time first, then as a date.
    // If both parsing attempts fail, we display an error message.

    DateTime? parseDateTimeOrDateStrUsinAppDateFormat =
        dateFormatVMlistenFalse.parseDateTimeStrUsinAppDateFormat(
      dateTimeStr: oldestAudioDownloadDateFormattedStr,
    );

    parseDateTimeOrDateStrUsinAppDateFormat ??=
        dateFormatVMlistenFalse.parseDateStrUsinAppDateFormat(
      dateStr: oldestAudioDownloadDateFormattedStr,
    );

    if (parseDateTimeOrDateStrUsinAppDateFormat == null) {
      warningMessageVMlistenFalse.setError(
        errorType: ErrorType.dateFormatError,
        errorArgOne: oldestAudioDownloadDateFormattedStr,
      );
      return [parseDateTimeOrDateStrUsinAppDateFormat];
    }

    Duration audioMp3SavingToZipDuration =
        await playlistListVMlistenFalse.evaluateSavingAudioMp3FileToZipDuration(
      listOfPlaylists: playlistsLst,
      fromAudioDownloadDateTime: parseDateTimeOrDateStrUsinAppDateFormat,
    );

    return [
      parseDateTimeOrDateStrUsinAppDateFormat,
      audioMp3SavingToZipDuration,
    ];
  }
}
