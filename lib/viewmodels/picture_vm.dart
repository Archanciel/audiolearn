import 'dart:convert';
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
    List<Picture> pictureLst = _getAudioPicturesLstInAudioPictureJsonFile(
      audio: audio,
    );

    String pictureFileName = DirUtil.getFileNameFromPathFileName(
      pathFileName: pictureFilePathName,
    );

    // If the picture file name already exists in the audio picture
    // json file, it is not added.
    if (pictureLst.any((picture) => picture.fileName == pictureFileName)) {
      return;
    }

    // Copy the picture file to the application picture directory.
    // If the picture file already exists in the application picture
    // directory, it is not copied again.
    // Add as well the association between the picture file name and the
    // audio file name in the pictureAudio.json file.
    _copyPictureFileToAppPictureDir(
      pictureFilePathName: pictureFilePathName,
      pictureFileName: pictureFileName,
      forAudioFileName: audio.audioFileName,
      audioPlaylistTitle: audio.enclosingPlaylist!.title,
    );

    _addPictureToAudioPictureJsonFile(
      pictureFileName: DirUtil.getFileNameFromPathFileName(
        pathFileName: pictureFilePathName,
      ),
      audio: audio,
    );

    notifyListeners();
  }

  /// Copy the picture file to the application picture directory.
  /// If the picture file already exists in the application picture
  /// directory, it is not copied again.
  ///
  /// Add as well the association between the picture file name and the
  /// audio file name in the pictureAudio.json file.
  void _copyPictureFileToAppPictureDir({
    required String pictureFilePathName,
    required String pictureFileName,
    required String forAudioFileName,
    required String audioPlaylistTitle,
  }) {
    DirUtil.copyFileToDirectoryIfNotExistSync(
      sourceFilePathName: pictureFilePathName,
      targetDirectoryPath: _applicationPicturePath,
    );

    _addPictureAudioAssociation(
      pictureFileName: pictureFileName,
      audioFileName: forAudioFileName,
      audioPlaylistTitle: audioPlaylistTitle,
    );
  }

  /// Associates a picture with an audio file name. If the picture is not in the map, adds it with
  /// the audio file name. If the picture is already in the map, adds the audio file name to its list
  /// if it isn't already present.
  void _addPictureAudioAssociation({
    required String pictureFileName,
    required String audioFileName,
    required String audioPlaylistTitle,
  }) {
    // Remove .mp3 extension if present
    final String playListTitleAndAudioFileNameWithoutExtension =
        "$audioPlaylistTitle|${DirUtil.getFileNameWithoutMp3Extension(mp3FileName: audioFileName)}";

    final Map<String, List<String>> pictureAudioMap = _readPictureAudioMap();

    if (pictureAudioMap.containsKey(pictureFileName)) {
      final List<String> audioList = pictureAudioMap[pictureFileName]!;
      if (!audioList.contains(playListTitleAndAudioFileNameWithoutExtension)) {
        audioList.add(playListTitleAndAudioFileNameWithoutExtension);
        pictureAudioMap[pictureFileName] = audioList;
      }
    } else {
      pictureAudioMap[pictureFileName] = [
        playListTitleAndAudioFileNameWithoutExtension
      ];
    }

    _savePictureAudioMap(pictureAudioMap);
  }

  /// Reads the pictureAudio.json file if it exists, otherwise returns an empty map
  Map<String, List<String>> _readPictureAudioMap() {
    final File jsonFile = _createJsonFile();

    if (!jsonFile.existsSync()) {
      return {};
    }

    try {
      final String content = jsonFile.readAsStringSync();
      final Map<String, dynamic> jsonMap = json.decode(content);

      // Convert the dynamic values back to List<String>
      final Map<String, List<String>> typedMap = {};
      jsonMap.forEach((key, value) {
        if (value is List) {
          typedMap[key] = value.cast<String>();
        }
      });

      return typedMap;
    } catch (e) {
      // ignore: avoid_print
      print('Error reading pictureAudio.json: $e');
      return {};
    }
  }

  File _createJsonFile() => File(
      "$_applicationPicturePath${path.separator}$kPictureAudioMapFileName");

  /// Saves the pictureAudio map to the JSON file
  void _savePictureAudioMap(Map<String, List<String>> pictureAudioMap) {
    final File jsonFile = _createJsonFile();

    final String jsonContent = json.encode(pictureAudioMap);
    jsonFile.writeAsStringSync(jsonContent);
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
  void removeAudioPicture({
    required Audio audio,
  }) {
    List<Picture> pictureLst = _getAudioPicturesLstInAudioPictureJsonFile(
      audio: audio,
    );

    _removeAudioPictureFromAudioPictureJsonFile(
      audio: audio,
      pictureLst: pictureLst,
      pictureToRemove: pictureLst.last,
    );

    notifyListeners();
  }

  void _removeAudioPictureFromAudioPictureJsonFile({
    required Audio audio,
    required List<Picture> pictureLst,
    required Picture pictureToRemove,
  }) {
    String audioFileName = audio.audioFileName;
    String pictureJsonFilePathName = _buildPictureJsonFilePathName(
      playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
      audioFileName: audioFileName,
    );

    _removePictureAudioAssociation(
      pictureFileName: pictureToRemove.fileName,
      audioFileName: audioFileName,
      audioPlaylistTitle: audio.enclosingPlaylist!.title,
    );

    pictureLst.remove(pictureToRemove);

    if (pictureLst.isEmpty) {
      // If the json file is empty, it is deleted.
      DirUtil.deleteFileIfExist(
        pathFileName: pictureJsonFilePathName,
      );

      return;
    }

    _sortAndSavePictureLst(
      pictureLst: pictureLst,
      pictureFilePathName: pictureJsonFilePathName,
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
    List<Picture> pictureLst = _getAudioPicturesLstInAudioPictureJsonFile(
      audio: audio,
    );

    if (pictureLst.isEmpty) {
      return null;
    }

    String audioPicturePathFileName =
        "$_applicationPicturePath${path.separator}${pictureLst.last.fileName}";

    File file = File(audioPicturePathFileName);

    if (!file.existsSync()) {
      return null;
    }

    // Return the File instance
    return file;
  }

  /// Returns the list of Picture objects associated to the passed audio and
  /// listed in the json file whose name is the audio file name with the
  /// extension .json.
  List<Picture> _getAudioPicturesLstInAudioPictureJsonFile({
    required Audio audio,
  }) {
    String pictureJsonFilePathName = _buildPictureJsonFilePathName(
      playlistDownloadPath: audio.enclosingPlaylist!.downloadPath,
      audioFileName: audio.audioFileName,
    );

    List<Picture> pictureLst = JsonDataService.loadListFromFile(
      jsonPathFileName: pictureJsonFilePathName,
      type: Picture,
    ).map((dynamic item) => item as Picture).toList();

    return pictureLst;
  }

  /// Method called by SortFilterSService
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

  /// Method called by PlaylistListVM.
  void deleteAudioPictureIfExist({
    required Audio audio,
  }) {
    final String playlistDownloadPath = audio.enclosingPlaylist!.downloadPath;
    final String audioPictureJsonFileName =
        audio.audioFileName.replaceAll('.mp3', '.json');
    final String audioPictureJsonPathFileName =
        "$playlistDownloadPath${path.separator}$kPictureDirName${path.separator}$audioPictureJsonFileName";

    List<Picture> audioPictureLst =
        _getAudioPicturesLstInAudioPictureJsonFile(audio: audio);

    DirUtil.deleteFileIfExist(
      pathFileName: audioPictureJsonPathFileName,
    );

    for (Picture picture in audioPictureLst) {
      _removePictureAudioAssociation(
        pictureFileName: picture.fileName,
        audioFileName: audio.audioFileName,
        audioPlaylistTitle: audio.enclosingPlaylist!.title,
      );
    }
  }

  /// Removes an association between a picture and an audio file
  void _removePictureAudioAssociation({
    required String pictureFileName,
    required String audioFileName,
    required String audioPlaylistTitle,
  }) {
    final String playListTitleAndAudioFileNameWithoutExtension =
        "$audioPlaylistTitle|${DirUtil.getFileNameWithoutMp3Extension(mp3FileName: audioFileName)}";

    final Map<String, List<String>> pictureAudioMap = _readPictureAudioMap();

    if (pictureAudioMap.containsKey(pictureFileName)) {
      final List<String> audioList = pictureAudioMap[pictureFileName]!;

      audioList.remove(playListTitleAndAudioFileNameWithoutExtension);

      // If no more audios are associated with this picture, remove the picture entry
      if (audioList.isEmpty) {
        pictureAudioMap.remove(pictureFileName);
      } else {
        pictureAudioMap[pictureFileName] = audioList;
      }

      _savePictureAudioMap(pictureAudioMap);
    }
  }

  /// Method called by PlaylistListVM.
  void moveAudioPictureJsonFileToTargetPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    final String playlistPictureJsonSourcePathFileName =
        "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kPictureDirName${path.separator}${audio.audioFileName.replaceAll('.mp3', '.json')}";
    final String playlistPicturesTargetPath =
        "${targetPlaylist.downloadPath}${path.separator}$kPictureDirName";

    DirUtil.moveFileToDirectoryIfNotExistSync(
      sourceFilePathName: playlistPictureJsonSourcePathFileName,
      targetDirectoryPath: playlistPicturesTargetPath,
    );
  }

  /// Method called by PlaylistListVM.
  void copyAudioPictureJsonFileToTargetPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    final String playlistPictureJsonSourcePathFileName =
        "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kPictureDirName${path.separator}${audio.audioFileName.replaceAll('.mp3', '.json')}";
    final String playlistPicturesTargetPath =
        "${targetPlaylist.downloadPath}${path.separator}$kPictureDirName";

    DirUtil.copyFileToDirectoryIfNotExistSync(
      sourceFilePathName: playlistPictureJsonSourcePathFileName,
      targetDirectoryPath: playlistPicturesTargetPath,
    );
  }
}
