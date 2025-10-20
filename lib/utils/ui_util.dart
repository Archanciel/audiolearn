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
import '../models/comment.dart';
import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/date_format_vm.dart';
import '../viewmodels/playlist_list_vm.dart';
import '../viewmodels/warning_message_vm.dart';
import '../views/widgets/confirm_action_dialog.dart';
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
    String? mp3ZipDirectoryPath;
    String selectedZipFilePathName = '';

    // This method display a dialog enabling to select either a file
    // or a directory.
    Map<String, String> selectedDirOrFile =
        await filePickerSelectFileOrDirectory(
      context: context,
      dialogTitle: AppLocalizations.of(context)!.selectFileOrDirTitle,
      dialogQuestion: AppLocalizations.of(context)!.selectQuestion,
      fileButtonText: AppLocalizations.of(context)!.selectZipFile,
      directoryButtonText: AppLocalizations.of(context)!.selectDirectory,
    );

    if (selectedDirOrFile['type'] == 'file') {
      selectedZipFilePathName = selectedDirOrFile['path'] ?? '';
    } else if (selectedDirOrFile['type'] == 'directory') {
      mp3ZipDirectoryPath = selectedDirOrFile['path'];
    } else if (selectedDirOrFile['type'] == 'cancelled') {
      return;
    } else if (selectedDirOrFile['type'] == 'error') {
      String errorPath = selectedDirOrFile['path'] ?? '';

      if (errorPath == 'INSUFFICIENT_STORAGE_SPACE') {
        warningMessageVMlistenFalse.setError(
          errorType: ErrorType.insufficientStorageSpace,
        );
      } else if (errorPath == 'PATH_ERROR') {
        warningMessageVMlistenFalse.setError(
          errorType: ErrorType.pathError,
        );
      } else {
        warningMessageVMlistenFalse.setError(
          errorType: ErrorType.pathError,
          errorArgOne: errorPath,
        );
      }
      return;
    }

    PlaylistListVM playlistListVMlistenFalse = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );

    if (uniquePlaylistIsRestored && playlistsLst.length == 1) {
      if (mp3ZipDirectoryPath != null) {
        // Restore from multiple ZIP files contained in a directory
        await playlistListVMlistenFalse.restoreAndConfirmPlaylistsAudioMp3FilesFromMultipleZips(
          zipDirectoryPath: mp3ZipDirectoryPath,
          listOfPlaylists: playlistsLst,
        );
        return;
      }

      if (selectedZipFilePathName.isEmpty) {
        return;
      }

      // Restore from single ZIP file for one playlist
      List<dynamic> resultLst = await playlistListVMlistenFalse
          .restorePlaylistsAudioMp3FilesFromUniqueZip(
        zipFilePathName: selectedZipFilePathName,
        listOfPlaylists: playlistsLst,
        uniquePlaylistIsRestored: uniquePlaylistIsRestored,
      );

      int restoredAudioCount = resultLst[0];
      int restoredPlaylistCount = resultLst[1];
      bool uniquePlaylistMp3ZipFileWasRestored = resultLst[2];

      warningMessageVMlistenFalse.confirmMp3RestorationFromUniqueZip(
        zipFilePathName: selectedZipFilePathName,
        restoredMp3Number: restoredAudioCount,
        playlistsNumber: restoredPlaylistCount,
        wasIndividualPlaylistMp3ZipUsed: uniquePlaylistMp3ZipFileWasRestored,
      );
    } else {
      // Restoring mp3 files for unique or multiple playlists from a single
      // ZIP file or from multiple mp3 zip files located in a directory.
      if (mp3ZipDirectoryPath != null) {
        await playlistListVMlistenFalse.restoreAndConfirmPlaylistsAudioMp3FilesFromMultipleZips(
          zipDirectoryPath: mp3ZipDirectoryPath,
          listOfPlaylists: playlistsLst,
        );
        return;
      }

      if (selectedZipFilePathName.isEmpty) {
        return;
      }

      // Restore from single ZIP file for one or multiple playlists
      List<dynamic> resultLst = await playlistListVMlistenFalse
          .restorePlaylistsAudioMp3FilesFromUniqueZip(
        zipFilePathName: selectedZipFilePathName,
        listOfPlaylists: playlistsLst,
        uniquePlaylistIsRestored: uniquePlaylistIsRestored,
      );

      int restoredAudioCount = resultLst[0];
      int restoredPlaylistCount = resultLst[1];
      bool uniquePlaylistMp3ZipFileWasRestored = resultLst[2];

      warningMessageVMlistenFalse.confirmMp3RestorationFromUniqueZip(
        zipFilePathName: selectedZipFilePathName,
        restoredMp3Number: restoredAudioCount,
        playlistsNumber: restoredPlaylistCount,
        wasIndividualPlaylistMp3ZipUsed: uniquePlaylistMp3ZipFileWasRestored,
      );
    }
  }

  /// Allows the user to select either a file or a directory.
  /// Shows a dialog first to let the user choose what type to select.
  ///
  /// Returns a Map containing:
  /// {
  ///   'type': 'file' | 'directory' | 'cancelled',
  ///   'path': String (the selected path, or empty if cancelled)
  /// }
  static Future<Map<String, String>> filePickerSelectFileOrDirectory({
    required BuildContext context,
    required String dialogTitle,
    required String dialogQuestion,
    required String fileButtonText,
    required String directoryButtonText,
    List<String>? allowedExtensions, // e.g., ['zip']
  }) async {
    // Show dialog to let user choose
    String? userChoice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            key: const Key('selectFileOrDirDialogTitle'),
            dialogTitle,
          ),
          content: Text(
            key: const Key('selectFileOrDirDialogContent'),
            dialogQuestion,
          ),
          actions: [
            TextButton(
              key: const Key('selectFileButton'),
              onPressed: () => Navigator.of(context).pop('file'),
              child: Text(
                fileButtonText,
                textAlign: TextAlign.right,
              ),
            ),
            TextButton(
              key: const Key('selectDirectoryButton'),
              onPressed: () => Navigator.of(context).pop('directory'),
              child: Text(
                directoryButtonText,
                textAlign: TextAlign.right,
              ),
            ),
            TextButton(
              key: const Key('cancelButton'),
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: Text(AppLocalizations.of(context)!.cancelButton),
            ),
          ],
        );
      },
    );

    // Handle user's choice
    if (userChoice == null || userChoice == 'cancel') {
      return {'type': 'cancelled', 'path': ''};
    }

    if (userChoice == 'directory') {
      // Select directory
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath != null && directoryPath.isNotEmpty) {
        return {'type': 'directory', 'path': directoryPath};
      } else {
        return {'type': 'cancelled', 'path': ''};
      }
    } else {
      // Select file
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: allowedExtensions != null ? FileType.custom : FileType.any,
          allowedExtensions: allowedExtensions,
          allowMultiple: false,
          withData: false,
          initialDirectory: Platform.isAndroid ? '/storage/emulated/0' : null,
        );

        if (result != null && result.files.isNotEmpty) {
          String? filePath = result.files.first.path;
          if (filePath != null && filePath.isNotEmpty) {
            // Verify the file exists
            File selectedFile = File(filePath);
            if (await selectedFile.exists()) {
              return {'type': 'file', 'path': filePath};
            } else {
              logger.e('Selected file does not exist: $filePath');
            }
          }
        }
      } on PlatformException catch (e) {
        if (e.code == 'unknown_path') {
          try {
            Directory tempDir = await getTemporaryDirectory();
            File testFile = File('${tempDir.path}/storage_test.tmp');
            await testFile.writeAsString('test');
            await testFile.delete();
            logger.e('Failed to retrieve file path: ${e.message}');
            return {'type': 'error', 'path': 'PATH_ERROR'};
          } catch (storageError) {
            logger
                .e('Insufficient storage space detected during file selection');
            return {'type': 'error', 'path': 'INSUFFICIENT_STORAGE_SPACE'};
          }
        } else {
          logger.e('Platform exception: ${e.code} - ${e.message}');
        }
      } catch (e) {
        logger.e('Error selecting file: $e');
      }

      return {'type': 'cancelled', 'path': ''};
    }
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

      return [null];
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

  static Future<void> handleDeleteAudioFromPlaylistAsWell({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
    required Audio audioToDelete,
    required AudioLearnAppViewType audioLearnAppViewType,
    required WarningMessageVM warningMessageVM,
  }) async {
    Audio? nextAudio;
    bool wasCancelButtonPressed = false;
    Playlist audioToDeletePlaylist = audioToDelete.enclosingPlaylist!;
    final List<Comment> audioToDeleteCommentLst =
        playlistListVMlistenFalse.getAudioComments(
      audio: audioToDelete,
    );

    // audioLearnAppViewType = AudioLearnAppViewType.playlistDownloadView;

    if (audioToDeletePlaylist.playlistType == PlaylistType.youtube &&
        audioToDelete.audioType == AudioType.downloaded) {
      await showDialog<dynamic>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmActionDialog(
            actionFunction:
                UiUtil.deleteAudioFromPlaylistAsWellIfNoCommentExist,
            actionFunctionArgs: [
              playlistListVMlistenFalse,
              audioToDelete,
              audioToDeleteCommentLst,
              audioLearnAppViewType,
            ],
            dialogTitleOne: AppLocalizations.of(context)!
                .confirmAudioFromPlaylistDeletionTitle(
                    audioToDelete.validVideoTitle),
            dialogContent:
                AppLocalizations.of(context)!.confirmAudioFromPlaylistDeletion(
              audioToDelete.validVideoTitle,
              audioToDeletePlaylist.title,
            ),
          );
        },
      ).then((result) {
        if (result == ConfirmAction.cancel) {
          nextAudio = audioToDelete;
          wasCancelButtonPressed = true;
        } else {
          nextAudio = result as Audio?;
        }
      });

      // Handle commented audio for YouTube playlists
      if (audioToDeleteCommentLst.isNotEmpty && nextAudio != audioToDelete) {
        await showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmActionDialog(
              actionFunction: UiUtil.deleteAudioFromPlaylistAsWell,
              actionFunctionArgs: [
                playlistListVMlistenFalse,
                audioToDelete,
                audioLearnAppViewType,
              ],
              dialogTitleOne: UiUtil.createDeleteCommentedAudioDialogTitle(
                context: context,
                audioToDelete: audioToDelete,
              ),
              dialogContent: AppLocalizations.of(context)!
                  .confirmCommentedAudioDeletionComment(
                      audioToDeleteCommentLst.length),
            );
          },
        ).then((result) {
          if (result == ConfirmAction.cancel) {
            nextAudio = audioToDelete;
            wasCancelButtonPressed = true;
          } else {
            nextAudio = result as Audio?;
          }
        });
      }
    } else if (wasCancelButtonPressed == false) {
      // The playlist is local or the audio is imported or converted
      // text to speech
      if (audioToDeleteCommentLst.isNotEmpty) {
        await showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmActionDialog(
              actionFunction: UiUtil.deleteAudioFromPlaylistAsWell,
              actionFunctionArgs: [
                playlistListVMlistenFalse,
                audioToDelete,
                audioLearnAppViewType,
              ],
              dialogTitleOne: UiUtil.createDeleteCommentedAudioDialogTitle(
                context: context,
                audioToDelete: audioToDelete,
              ),
              dialogContent: AppLocalizations.of(context)!
                  .confirmCommentedAudioDeletionComment(
                      audioToDeleteCommentLst.length),
            );
          },
        ).then((result) {
          if (result == ConfirmAction.cancel) {
            nextAudio = audioToDelete;
          } else {
            nextAudio = result as Audio?;
          }
        });
      } else {
        // For local playlists without comments, handle deletion directly
        nextAudio = UiUtil.deleteAudioFromPlaylistAsWellIfNoCommentExist(
          playlistListVMlistenFalse,
          audioToDelete,
          audioToDeleteCommentLst,
          audioLearnAppViewType,
        );
      }
    }

    if (wasCancelButtonPressed) {
      return;
    }

    await UiUtil.replaceCurrentAudioByNextAudio(
      context: context,
      nextAudio: nextAudio,
    );

    Playlist playlist = audioToDelete.enclosingPlaylist!;

    if (playlist.playlistType == PlaylistType.youtube &&
        audioToDelete.audioType == AudioType.downloaded) {
      warningMessageVM.setDeleteAudioFromPlaylistAswellTitle(
          deleteAudioFromPlaylistAswellTitle: playlist.title,
          deleteAudioFromPlaylistAswellAudioVideoTitle:
              audioToDelete.originalVideoTitle);
    }

    // This method only calls the PlaylistListVM notifyListeners()
    // method so that the playlist download view current audio is
    // updated to the next audio in the playlist playable audio list.
    playlistListVMlistenFalse.updateCurrentAudio();
  }

  /// Replaces the current audio by the next audio in the audio player
  /// view.
  static Future<void> replaceCurrentAudioByNextAudio({
    required BuildContext context,
    required Audio? nextAudio,
  }) async {
    AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    if (nextAudio != null) {
      // Required so that the audio title displayed in the
      // audio player view is updated with the modified title.
      await audioPlayerVMlistenFalse.setCurrentAudio(
        audio: nextAudio,
      );
    } else {
      // Calling handleNoPlayableAudioAvailable() is necessary
      // to update the audio title in the audio player view to
      // "No selected audio"
      await audioPlayerVMlistenFalse.handleNoPlayableAudioAvailable();
    }
  }

  static String createDeleteCommentedAudioDialogTitle({
    required BuildContext context,
    required Audio audioToDelete,
  }) {
    String deleteAudioDialogTitle;

    deleteAudioDialogTitle = AppLocalizations.of(context)!
        .confirmCommentedAudioDeletionTitle(audioToDelete.validVideoTitle);

    return deleteAudioDialogTitle;
  }

  /// Public method passed to the ConfirmActionDialog to be executd
  /// when the Confirm button is pressed. The method deletes the audio
  /// file and its comments.
  static Audio? deleteAudio(
    BuildContext context,
    Audio audio,
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    return Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).deleteAudioFile(
      audioLearnAppViewType: audioLearnAppViewType,
      audio: audio,
    );
  }

  /// Public method passed to the ConfirmActionDialog to be executd
  /// when the Confirm button is pressed. The method deletes the audio
  /// file and its comments as well as the audio reference in the playlist
  /// json file.
  static Audio? deleteAudioFromPlaylistAsWell(
    PlaylistListVM playlistListVMlistenFalse,
    Audio audio,
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    return playlistListVMlistenFalse.deleteAudioFromPlaylistAsWell(
      audioLearnAppViewType: audioLearnAppViewType,
      audio: audio,
    );
  }

  /// Public method passed to the ConfirmActionDialog to be executd
  /// when the Confirm button is pressed. The method deletes the audio
  /// file and its comments as well as the audio reference in the playlist
  /// json file.
  static Audio? deleteAudioFromPlaylistAsWellIfNoCommentExist(
    PlaylistListVM playlistListVMlistenFalse,
    Audio audio,
    List<Comment> audioToDeleteCommentLst,
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    if (audioToDeleteCommentLst.isNotEmpty) {
      // The audio has comments, so it cannot be deleted from the
      // playlist json file without that a user confirmation was
      // obtained.
      return null;
    }
    return playlistListVMlistenFalse.deleteAudioFromPlaylistAsWell(
      audioLearnAppViewType: audioLearnAppViewType,
      audio: audio,
    );
  }

  static String obtainTranslatedDateFormat({
    required BuildContext context,
    required DateFormatVM dateFormatVMlistenFalse,
  }) {
    String selectedDateFormat = dateFormatVMlistenFalse.selectedDateFormat;
    String translatedDateFormatStr = '';

    if (selectedDateFormat == 'dd/MM/yyyy') {
      translatedDateFormatStr =
          AppLocalizations.of(context)!.dateFormatddMMyyyy;
    } else if (selectedDateFormat == 'MM/dd/yyyy') {
      translatedDateFormatStr =
          AppLocalizations.of(context)!.dateFormatMMddyyyy;
    } else if (selectedDateFormat == 'yyyy/MM/dd') {
      translatedDateFormatStr =
          AppLocalizations.of(context)!.dateFormatyyyyMMdd;
    }
    return translatedDateFormatStr;
  }
}
