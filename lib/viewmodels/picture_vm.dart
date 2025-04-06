import 'dart:io';

import 'package:audiolearn/services/json_data_service.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../models/audio.dart';
import '../models/picture.dart';
import '../models/playlist.dart';
import '../services/settings_data_service.dart';
import '../utils/dir_util.dart';

class PictureVM extends ChangeNotifier {
  late String _applicationPicturePath;
  final SettingsDataService _settingsDataService;

  PictureVM({
    required SettingsDataService settingsDataService,
  }) : _settingsDataService = settingsDataService {
    _applicationPicturePath =
        DirUtil.getApplicationPicturePath(isTest: _settingsDataService.isTest);
  }

  /// Method called when the user clicks on the audio item 'Add Audio
  /// Picture ...' menu or on audio player view left appbar 'Add Audio
  /// Picture ...' menu.
  ///
  /// [pictureFilePathName] was obtained from the file picker dialog.
  void addPictureToAudio({
    required Audio audio,
    required String pictureFilePathName,
  }) {
    List<Picture> pictureLst = _getAudioPicturesLst(
      audio: audio,
    );

    String pictureFileName = DirUtil.getFileNameFromPathFileName(
      pathFileName: pictureFilePathName,
    );

    // If the picture file name already exists in the audio picture
    // json file, it is not added.
    for (Picture picture in pictureLst) {
      if (picture.fileName == pictureFileName) {
        return;
      }
    }

    // Copy the picture file to the application picture directory
    DirUtil.copyFileToDirectory(
      sourceFilePathName: pictureFilePathName,
      targetDirectoryPath: _applicationPicturePath,
    );

    _addPictureToAudioPictureJsonFile(
      pictureFileName: DirUtil.getFileNameFromPathFileName(
        pathFileName: pictureFilePathName,
      ),
      audio: audio,
    );

    notifyListeners();
  }

  void _addPictureToAudioPictureJsonFile({
    required String pictureFileName,
    required Audio audio,
  }) {
    String pictureJsonFilePathName = _buildPictureJsonFilePathName(
      playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
      audioFileName: audio.audioFileName,
    );

    List<Picture> pictureLst = JsonDataService.loadListFromFile(
      jsonPathFileName: pictureJsonFilePathName,
      type: Picture,
    );

    if (pictureLst.isEmpty) {
      // Create the playlist dir so that the picture json file
      // can be created
      DirUtil.createDirIfNotExistSync(
        pathStr: DirUtil.getPathFromPathFileName(
          pathFileName: pictureJsonFilePathName,
        ),
      );
    }

    pictureLst.add(
      Picture(fileName: pictureFileName),
    );

    _sortAndSavePictureLst(
      pictureLst: pictureLst,
      pictureFilePathName: pictureJsonFilePathName,
    );

    notifyListeners();
  }

  /// Returns a string which is the combination of the path of the playlist picture
  /// directory and the file name to the maybe not yet existing picture json file.
  String _buildPictureJsonFilePathName({
    required String playlistDownloadPath,
    required String audioFileName,
  }) {
    final String playlistPicturePath =
        "$playlistDownloadPath${path.separator}$kPictureDirName";

    final String createdPictureFileName =
        audioFileName.replaceAll('.mp3', '.json');

    return "$playlistPicturePath${path.separator}$createdPictureFileName";
  }

  void _sortAndSavePictureLst({
    required List<Picture> pictureLst,
    required String pictureFilePathName,
  }) {
    pictureLst.sort(
      (a, b) => a.lastDisplayDateTime.compareTo(b.lastDisplayDateTime),
    );

    JsonDataService.saveListToFile(
      data: pictureLst,
      jsonPathFileName: pictureFilePathName,
    );
  }

  int getAudioPicturesNumber({
    required Audio audio,
  }) {
    String pictureJsonFilePathName = _buildPictureJsonFilePathName(
      playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
      audioFileName: audio.audioFileName,
    );

    return JsonDataService.loadListFromFile(
      jsonPathFileName: pictureJsonFilePathName,
      type: Picture,
    ).length;
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

    notifyListeners();
  }

  /// Returns the audio picture file if it exists, null otherwise.
  ///
  /// This method is used to deter4mine if the 'Remove audio picture'
  /// menu item is displayed or not for the audio item and the audio
  /// player view left appbar.
  File? getAudioPictureFile({
    required Audio audio,
  }) {
    List<Picture> pictureLst = _getAudioPicturesLst(
      audio: audio,
    );

    if (pictureLst.isEmpty) {
      return null;
    }

    String audioPicturePathFileName =
        "$_applicationPicturePath${path.separator}${pictureLst[0].fileName}";

    File file = File(audioPicturePathFileName);

    if (!file.existsSync()) {
      return null;
    }

    // Return the File instance
    return file;
  }

  List<Picture> _getAudioPicturesLst({
    required Audio audio,
  }) {
    String pictureJsonFilePathName = _buildPictureJsonFilePathName(
      playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
      audioFileName: audio.audioFileName,
    );

    List<Picture> pictureLst = JsonDataService.loadListFromFile(
      jsonPathFileName: pictureJsonFilePathName,
      type: Picture,
    );

    return pictureLst;
  }

  List<String> getPlaylistAudioPicturedFileNamesNoExtLst({
    required Playlist playlist,
  }) {
    String playlistDownloadPath = playlist.downloadPath;
    String playlistPicturePath =
        "$playlistDownloadPath${path.separator}$kPictureDirName";

    List<String> audioPictureFileNamesLst = [];
    Directory dir = Directory(playlistPicturePath);

    if (!dir.existsSync()) {
      // If the playlist has no picture directory, an empty list
      // is returned.
      return audioPictureFileNamesLst;
    }

    final List<FileSystemEntity> files = dir.listSync();

    for (FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.json')) {
        String fileName =
            DirUtil.getFileNameFromPathFileName(pathFileName: file.path);
        audioPictureFileNamesLst
            .add(fileName.substring(0, fileName.length - 5));
      }
    }

    return audioPictureFileNamesLst;
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
