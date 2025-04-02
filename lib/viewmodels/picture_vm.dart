import 'dart:io';

import 'package:flutter/material.dart';
import 'package:googleapis/networkservices/v1.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import '../utils/dir_util.dart';

class PictureVM extends ChangeNotifier {

  PictureVM();

  /// Method called when the user clicks on the audio item 'Add Audio
  /// Picture ...' menu or on audio player view left appbar 'Add Audio
  /// Picture ...' menu.
  void storeAudioPictureFileInPlaylistPictureDir({
    required Audio audio,
    required String pictureFilePathName,
  }) {
    final String playlistDownloadPath = audio.enclosingPlaylist!.downloadPath;
    final String playlistPicturePath =
        "$playlistDownloadPath${path.separator}$kPictureDirName";

    // Ensure the directory exists, otherwise create it
    Directory targetDirectory = Directory(playlistPicturePath);

    if (!targetDirectory.existsSync()) {
      targetDirectory.createSync();
    }

    final String createdAudioPictureFileName =
        audio.audioFileName.replaceAll('.mp3', '.jpg');

    DirUtil.copyFileToDirectory(
        sourceFilePathName: pictureFilePathName,
        targetDirectoryPath: playlistPicturePath,
        targetFileName: createdAudioPictureFileName);
  }

  /// Method called when the user clicks on the audio item 'Remove Audio Picture'
  /// menu or on audio player view left appbar 'Remove Audio Picture' menu.
  /// Deleting the picture file whose name is the audio file name with the
  /// extension .jpg will cause the audio player to display no picture for
  /// the audio.
  void deleteAudioPictureFileInPlaylistPictureDir({
    required Audio audio,
  }) {
    final String playlistDownloadPath = audio.enclosingPlaylist!.downloadPath;
    final String createdAudioPictureFileName =
        audio.audioFileName.replaceAll('.mp3', '.jpg');

    final String audioPicturePathFileName =
        "$playlistDownloadPath${path.separator}$kPictureDirName${path.separator}$createdAudioPictureFileName";

    DirUtil.deleteFileIfExist(
      pathFileName: audioPicturePathFileName,
    );
  }

  /// Returns the audio picture file if it exists, null otherwise.
  /// 
  /// This method is used to deter4mine if the 'Remove audio picture'
  /// menu item is displayed or not for the audio item and the audio
  /// player view left appbar.
  File? getAudioPictureFile({
    required Audio audio,
  }) {
    String audioPicturePathFileName = _buildAudioPictureFilePathName(
      playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
      audioFileName: audio.audioFileName,
    );

    File file = File(audioPicturePathFileName);

    if (!file.existsSync()) {
      return null;
    }

    // Return the File instance
    return file;
  }

  /// Returns a string which is the combination of the path of the picture directory
  /// and the file name to the maybe not existing audio picture file.
  String _buildAudioPictureFilePathName({
    required String playlistDownloadPath,
    required String audioFileName,
  }) {
    final String playlistPicturePath =
        "$playlistDownloadPath${path.separator}$kPictureDirName";

    final String createdAudioPictureFileName =
        audioFileName.replaceAll('.mp3', '.jpg');

    return "$playlistPicturePath${path.separator}$createdAudioPictureFileName";
  }

  void deleteAudioPictureIfExist({
    required Audio audio,
  }) {
    final String playlistDownloadPath = audio.enclosingPlaylist!.downloadPath;
    final String audioPictureFileName =
        audio.audioFileName.replaceAll('.mp3', '.jpg');
    final String audioPicturePathFileName =
        "$playlistDownloadPath${path.separator}$kPictureDirName${path.separator}$audioPictureFileName";

    DirUtil.deleteFileIfExist(
      pathFileName: audioPicturePathFileName,
    );
  }

  void moveAudioPictureToTargetPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    // Obtaining the potentially existing audio picture file path
    // name

    final String playlistDownloadPath = audio.enclosingPlaylist!.downloadPath;
    final String audioPictureFileName =
        audio.audioFileName.replaceAll('.mp3', '.jpg');
    final String audioPicturePathFileName =
        "$playlistDownloadPath${path.separator}$kPictureDirName${path.separator}$audioPictureFileName";

    if (File(audioPicturePathFileName).existsSync()) {
      // The case if a picture is associated to the audio
      final String targetPlaylistPicturePath =
          "${targetPlaylist.downloadPath}${path.separator}$kPictureDirName";

      // Ensures the target playlist picture directory exists.
      DirUtil.createDirIfNotExistSync(
        pathStr: targetPlaylistPicturePath,
      );
      DirUtil.moveFileToDirectoryIfNotExistSync(
        sourceFilePathName: audioPicturePathFileName,
        targetDirectoryPath: targetPlaylistPicturePath,
      );
    }
  }
}
