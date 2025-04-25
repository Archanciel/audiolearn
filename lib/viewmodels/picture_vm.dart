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
    //
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

    _addPictureAudioAssociationToAppPictureAudioMap(
      pictureFileName: pictureFileName,
      audioFileName: forAudioFileName,
      audioPlaylistTitle: audioPlaylistTitle,
    );
  }

  /// Associates a picture with an audio file name. If the picture is not in the map, adds it with
  /// the audio file name. If the picture is already in the map, adds the audio file name to its list
  /// if it isn't already present.
  void _addPictureAudioAssociationToAppPictureAudioMap({
    required String pictureFileName,
    required String audioFileName,
    required String audioPlaylistTitle,
  }) {
    // Remove .mp3 extension if present
    final String playListTitleAndAudioFileNameWithoutExtension =
        "$audioPlaylistTitle|${DirUtil.getFileNameWithoutMp3Extension(mp3FileName: audioFileName)}";

    final Map<String, List<String>> pictureAudioMap = _readAppPictureAudioMap();

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

  /// Reads the application picture audio map json file if it exists, otherwise returns
  /// an empty map.
  Map<String, List<String>> _readAppPictureAudioMap() {
    final File jsonFile = _createAppPictureAudioMapJsonFile();

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

  File _createAppPictureAudioMapJsonFile() => File(
      "$_applicationPicturePath${path.separator}$kPictureAudioMapFileName");

  /// Saves the pictureAudio map to the JSON file
  void _savePictureAudioMap(Map<String, List<String>> pictureAudioMap) {
    final File jsonFile = _createAppPictureAudioMapJsonFile();

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
  ///
  /// The method removes the last added picture to the audio. If there is no
  /// picture associated to the audio, nothing happens.
  void removeLastAddedAudioPicture({
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

    if (!_removePictureAudioAssociationInApplicationPictureAudioMap(
      pictureFileName: pictureToRemove.fileName,
      audioFileName: audioFileName,
      audioPlaylistTitle: audio.enclosingPlaylist!.title,
    )) {
      // The picture was not associated with the audio file name,
      // so the applicationn of the rest of the method is not
      // necessary.
      return;
    }

    pictureLst.remove(pictureToRemove);

    if (pictureLst.isEmpty) {
      // If the json file is empty, it is deleted.
      DirUtil.deleteFileIfExist(
        pathFileName: pictureJsonFilePathName,
      );

      // Delete the picture directory if it is empty

      final String playlistPicturePath =
          "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kPictureDirName";

      DirUtil.deleteDirIfEmpty(
        pathStr: playlistPicturePath,
      );

      return;
    }

    _sortAndSavePictureLst(
      pictureLst: pictureLst,
      pictureFilePathName: pictureJsonFilePathName,
    );
  }

  /// Returns the picture file last added to the audio if it exists,
  /// null otherwise. This picture will be displayed in the audio
  /// player view.
  ///
  /// This method is also used to determine if the 'Remove audio picture'
  /// menu item is displayed or not for the audio item and the audio
  /// player view left appbar.
  File? getLastAddedAudioPictureFile({
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
  /// extension .json. If the json file does not exist, an empty list is returned.
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

  /// Method called by SortFilterService
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
        audioPictureFileNamesLst.add(fileName.substring(
            0, fileName.length - 5)); // Remove .json extension
      }
    }

    return audioPictureFileNamesLst;
  }

  /// Method called by PlaylistListVM when the audio is deleted.
  void deleteAudioPictureJsonFileIfExist({
    required Audio audio,
  }) {
    final String playlistDownloadPath = audio.enclosingPlaylist!.downloadPath;
    final String audioPictureJsonFileName =
        audio.audioFileName.replaceAll('.mp3', '.json');
    final String playlistPicturePath =
        '$playlistDownloadPath${path.separator}$kPictureDirName';
    final String audioPictureJsonPathFileName =
        "$playlistPicturePath${path.separator}$audioPictureJsonFileName";

    List<Picture> audioPictureLst =
        _getAudioPicturesLstInAudioPictureJsonFile(audio: audio);

    DirUtil.deleteFileIfExist(
      pathFileName: audioPictureJsonPathFileName,
    );

    // Delete the picture directory if it is empty
    DirUtil.deleteDirIfEmpty(
      pathStr: playlistPicturePath,
    );

    for (Picture picture in audioPictureLst) {
      _removePictureAudioAssociationInApplicationPictureAudioMap(
        pictureFileName: picture.fileName,
        audioFileName: audio.audioFileName,
        audioPlaylistTitle: audio.enclosingPlaylist!.title,
      );
    }
  }

  /// Removes an association between a picture and an audio in the application
  /// picture audio map json file.
  ///
  /// Returns true if the picture audio association was removed,
  /// false otherwise.
  bool _removePictureAudioAssociationInApplicationPictureAudioMap({
    required String pictureFileName,
    required String audioFileName,
    required String audioPlaylistTitle,
  }) {
    final String playListTitleAndAudioFileNameWithoutExtension =
        "$audioPlaylistTitle|${DirUtil.getFileNameWithoutMp3Extension(mp3FileName: audioFileName)}";
    final Map<String, List<String>> applicationPictureAudioMap =
        _readAppPictureAudioMap();
    bool wasPictureRemoved = false;

    if (applicationPictureAudioMap.containsKey(pictureFileName)) {
      final List<String> audioList =
          applicationPictureAudioMap[pictureFileName]!;

      wasPictureRemoved =
          audioList.remove(playListTitleAndAudioFileNameWithoutExtension);

      if (!wasPictureRemoved) {
        return wasPictureRemoved;
      }

      // If no more audios are associated with this picture, remove the picture entry
      if (audioList.isEmpty) {
        applicationPictureAudioMap.remove(pictureFileName);
      } else {
        applicationPictureAudioMap[pictureFileName] = audioList;
      }

      _savePictureAudioMap(applicationPictureAudioMap);
    }

    return wasPictureRemoved;
  }

  /// Method called by PlaylistListVM.
  void moveAudioPictureJsonFileToTargetPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    Playlist sourcePlaylist = audio.enclosingPlaylist!;
    final String playlistPictureJsonSourcePathFileName =
        "${sourcePlaylist.downloadPath}${path.separator}$kPictureDirName${path.separator}${audio.audioFileName.replaceAll('.mp3', '.json')}";
    final String playlistPicturesTargetPath =
        "${targetPlaylist.downloadPath}${path.separator}$kPictureDirName";

    List<Picture> pictureLst = _getAudioPicturesLstInAudioPictureJsonFile(
      audio: audio,
    );

    if (pictureLst.isEmpty) {
      // The moved audio has no picture associated with it, so the
      // application picture audio map json file is not modified.
      return;
    }

    DirUtil.moveFileToDirectoryIfNotExistSync(
      sourceFilePathName: playlistPictureJsonSourcePathFileName,
      targetDirectoryPath: playlistPicturesTargetPath,
    );

    // All pictures of the source audio are deleted and added in the
    // application pictureAudioMap.json file for the moved audio.
    //
    // Example: the first line references the source audio file name,
    //          the second line references the target audio file name.
    //
    // "winter.jpg": [
    //    "MaValTest|250407-150507-morning _ cinematic video 23-07-01",
    //    "a_local|250407-150507-morning _ cinematic video 23-07-01"
    // ],

    // "chateau.jpg": [
    //    "MaValTest|250407-150507-morning _ cinematic video 23-07-01",
    //    "a_local|250407-150507-morning _ cinematic video 23-07-01"
    // ]
    for (Picture picture in pictureLst) {
      String pictureFileName = picture.fileName;
      String audioFileName = audio.audioFileName;

      _removePictureAudioAssociationInApplicationPictureAudioMap(
        pictureFileName: pictureFileName,
        audioFileName: audioFileName,
        audioPlaylistTitle: sourcePlaylist.title,
      );
      _addPictureAudioAssociationToAppPictureAudioMap(
        pictureFileName: pictureFileName,
        audioFileName: audioFileName,
        audioPlaylistTitle: targetPlaylist.title,
      );
    }

    notifyListeners();
  }

  /// Method called by PlaylistListVM.
  void copyAudioPictureJsonFileToTargetPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    final String audioPictureJsonSourcePathFileName =
        "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kPictureDirName${path.separator}${audio.audioFileName.replaceAll('.mp3', '.json')}";
    final String playlistPicturesTargetPath =
        "${targetPlaylist.downloadPath}${path.separator}$kPictureDirName";

    List<Picture> pictureLst = _getAudioPicturesLstInAudioPictureJsonFile(
      audio: audio,
    );

    if (pictureLst.isEmpty) {
      // The copied audio has no picture associated with it, so the
      // application picture audio map json file is not modified.
      return;
    }

    DirUtil.copyFileToDirectoryIfNotExistSync(
      sourceFilePathName: audioPictureJsonSourcePathFileName,
      targetDirectoryPath: playlistPicturesTargetPath,
    );

    // All pictures of the source audio are added in the application
    // picture audio map json file for the audio copy.
    //
    // Example: the first line references the source audio file name,
    //          the second line references the target audio file name.
    //
    // "winter.jpg": [
    //    "MaValTest|250407-150507-morning _ cinematic video 23-07-01",
    //    "a_local|250407-150507-morning _ cinematic video 23-07-01"
    // ],

    // "chateau.jpg": [
    //    "MaValTest|250407-150507-morning _ cinematic video 23-07-01",
    //    "a_local|250407-150507-morning _ cinematic video 23-07-01"
    // ]
    for (Picture picture in pictureLst) {
      _addPictureAudioAssociationToAppPictureAudioMap(
        pictureFileName: picture.fileName,
        audioFileName: audio.audioFileName,
        audioPlaylistTitle: targetPlaylist.title,
      );
    }

    notifyListeners();
  }

  /// Method called by PlaylistListVM. Returns the number of picture files saved to the
  /// target directory.
  int savePictureJpgFilesToTargetDirectory({
    required String targetDirectoryPath,
  }) {
    List<String> pictureJpgPathFileNamesLst = DirUtil.listPathFileNamesInDir(
      directoryPath: _applicationPicturePath,
      fileExtension: 'jpg',
    );

    int savedPictureNumber = 0;

    for (String pictureJpgPathFileName in pictureJpgPathFileNamesLst) {
      if (DirUtil.copyFileToDirectoryIfNotExistSync(
        sourceFilePathName: pictureJpgPathFileName,
        targetDirectoryPath: "$targetDirectoryPath${path.separator}$kPictureDirName",
      )) {
        savedPictureNumber++;
      }
    }

    return savedPictureNumber;
  }
}
