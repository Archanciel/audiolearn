import 'dart:io';

import 'package:flutter/material.dart';
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
}
