import 'package:audiolearn/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

// importing youtube_explode_dart as yt enables to name the app Model
// playlist class as Playlist so it does not conflict with
// youtube_explode_dart Playlist class name.
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../services/settings_data_service.dart';
import '../services/json_data_service.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/dir_util.dart';
import 'warning_message_vm.dart';

// global variables used by the AudioDownloadVM in order
// to avoid multiple downloads of the same playlist
List<String> downloadingPlaylistUrls = [];

/// This VM (View Model) class is part of the MVVM architecture.
///
/// It is responsible of connecting to Youtube in order to download
/// the audio of the videos referenced in the Youtube playlists.
/// It can also download the audio of a single video.
///
/// It is also responsible of creating and deleting application
/// Playlist's, either Youtube app Playlist's or local app
/// Playlist's.
///
/// Another responsibility of this class is to move or copy
/// audio files from one Playlist to another as well as to
/// rename or delete audio files or update their playing
/// speed.
class AudioDownloadVM extends ChangeNotifier {
  List<Playlist> _listOfPlaylist = [];
  List<Playlist> get listOfPlaylist => _listOfPlaylist;

  yt.YoutubeExplode? _youtubeExplode;
  // setter used by test only !
  set youtubeExplode(yt.YoutubeExplode youtubeExplode) =>
      _youtubeExplode = youtubeExplode;

  late String _playlistsRootPath;

  // used when updating the playlists root path
  set playlistsRootPath(String playlistsRootPath) =>
      _playlistsRootPath = playlistsRootPath;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  int _lastSecondDownloadSpeed = 0;
  int get lastSecondDownloadSpeed => _lastSecondDownloadSpeed;

  late Audio _currentDownloadingAudio;
  Audio get currentDownloadingAudio => _currentDownloadingAudio;

  bool _isHighQuality = false;
  bool get isHighQuality => _isHighQuality;
  set isHighQuality(bool isHighQuality) => _isHighQuality = isHighQuality;

  bool _stopDownloadPressed = false;
  bool get isDownloadStopping => _stopDownloadPressed;

  bool _audioDownloadError = false;
  bool get audioDownloadError => _audioDownloadError;

  final WarningMessageVM warningMessageVM;

  final SettingsDataService settingsDataService;

  /// Passing true for {isTest} has the effect that the windows
  /// test directory is used as playlist root directory. This
  /// directory is located in the test directory of the project.
  ///
  /// Otherwise, the windows or smartphone audio root directory
  /// is used and the value of the kUniquePlaylistTitle constant
  /// is used to load the playlist json file.
  AudioDownloadVM({
    required this.warningMessageVM,
    required this.settingsDataService,
    bool isTest = false,
  }) {
    _playlistsRootPath = settingsDataService.get(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath);

    loadExistingPlaylists();
  }

  void loadExistingPlaylists() {
    // reinitializing the list of playlist is necessary since
    // loadExistingPlaylists() is also called by ExpandablePlaylistVM.
    // updateSettingsAndPlaylistJsonFiles() method.
    _listOfPlaylist = [];

    List<String> playlistPathFileNameLst = DirUtil.listPathFileNamesInSubDirs(
      rootPath: _playlistsRootPath,
      extension: 'json',
      excludeDirName: kCommentDirName,
    );

    try {
      for (String playlistPathFileName in playlistPathFileNameLst) {
        Playlist currentPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName,
          type: Playlist,
        );
        _listOfPlaylist.add(currentPlaylist);

        // if the playlist is selected, the audio quality checkbox will be
        // checked or not according to the selected playlist quality
        if (currentPlaylist.isSelected) {
          _isHighQuality =
              currentPlaylist.playlistQuality == PlaylistQuality.music;
        }
      }
    } catch (e) {
      warningMessageVM.setError(
        errorType: ErrorType.errorInPlaylistJsonFile,
        errorArgOne: e.toString(),
      );

      notifyListeners();
    }

//    notifyListeners(); not necessary since the unique
//                       Consumer<AudioDownloadVM> is not concerned
//                       by the _listOfPlaylist changes
  }

  Future<Playlist?> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    return addPlaylistCallableByMock(
      playlistUrl: playlistUrl,
      localPlaylistTitle: localPlaylistTitle,
      playlistQuality: playlistQuality,
    );
  }

  void deletePlaylist({
    required Playlist playlistToDelete,
  }) {
    _listOfPlaylist
        .removeWhere((playlist) => playlist.id == playlistToDelete.id);

    DirUtil.deleteDirAndSubDirsIfExist(
      rootPath: playlistToDelete.downloadPath,
    );

    notifyListeners();
  }

  /// The MockAudioDownloadVM exists because when
  /// executing integration tests, using YoutubeExplode
  /// to get a Youtube playlist in order to obtain the
  /// playlist title is not possible, the
  /// {mockYoutubePlaylistTitle} is passed to the method if
  /// the method is called by the MockAudioDownloadVM.
  ///
  /// This method has been created in order for the
  /// MockAudioDownloadVM addPlaylist() method to be able
  /// to use the AudioDownloadVM.addPlaylist() logic.
  ///
  /// Additionally, since the method is called by the
  /// AudioDownloadVM, it contains the logic to add a
  /// playlist and so, if this logic is modified, it
  /// will be modified in only one place and will be
  /// applied to the MockAudioDownloadVM as well and so
  /// will tested by the integration test.
  Future<Playlist?> addPlaylistCallableByMock({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
    String? mockYoutubePlaylistTitle,
  }) async {
    Playlist addedPlaylist;

    // those two variables are used by the
    // ExpandablePlaylistListView UI to show a message
    warningMessageVM.updatedPlaylistTitle = '';

    if (localPlaylistTitle.isNotEmpty) {
      // handling creation of a local playlist

      addedPlaylist = Playlist(
        id: localPlaylistTitle, // necessary since the id is used to
        //                         identify the playlist in the list
        //                         of playlist
        title: localPlaylistTitle,
        playlistType: PlaylistType.local,
        playlistQuality: playlistQuality,
      );

      await _setPlaylistPath(
        playlistTitle: localPlaylistTitle,
        playlist: addedPlaylist,
      );

      JsonDataService.saveToFile(
        model: addedPlaylist,
        path: addedPlaylist.getPlaylistDownloadFilePathName(),
      );

      // if the local playlist is not added to the list of
      // playlist, then it will not be displayed at the end
      // of the list of playlist in the UI ! This is because
      // ExpandablePlaylistListVM.getUpToDateSelectablePlaylists()
      // obtains the list of playlist from the AudioDownloadVM.
      _listOfPlaylist.add(addedPlaylist);
      warningMessageVM.setAddPlaylist(
        playlistTitle: localPlaylistTitle,
        playlistQuality: playlistQuality,
      );

      return addedPlaylist;
    } else if (!playlistUrl.contains('list=')) {
      // the case if the url is a video url and the user
      // clicked on the Add button instead of the Download
      // button or if the String pasted to the url text field
      // is not a valid Youtube playlist url.
      warningMessageVM.invalidPlaylistUrl = playlistUrl;

      return null;
    } else {
      // handling creation of a Youtube playlist

      // get Youtube playlist
      String? playlistId;
      yt.Playlist youtubePlaylist;

      _youtubeExplode ??= yt.YoutubeExplode();

      playlistId = yt.PlaylistId.parsePlaylistId(playlistUrl);

      if (playlistId == null) {
        // the case if the String pasted to the url text field
        // is not a valid Youtube playlist url.
        warningMessageVM.invalidPlaylistUrl = playlistUrl;

        return null;
      }

      String playlistTitle;

      if (mockYoutubePlaylistTitle == null) {
        // the method is called by AudioDownloadVM.addPlaylist()
        try {
          youtubePlaylist = await _youtubeExplode!.playlists.get(playlistId);
        } on SocketException catch (e) {
          notifyDownloadError(
            errorType: ErrorType.noInternet,
            errorArgOne: e.toString(),
          );

          return null;
        } catch (e) {
          warningMessageVM.invalidPlaylistUrl = playlistUrl;

          return null;
        }

        playlistTitle = youtubePlaylist.title;
      } else {
        // the method is called by MockAudioDownloadVM.addPlaylist()
        playlistTitle = mockYoutubePlaylistTitle;
      }

      int playlistIndex = _listOfPlaylist
          .indexWhere((playlist) => playlist.title == playlistTitle);

      if (playlistIndex != -1) {
        // This means that the playlist was not added, but
        // that its url was updated. The case when a new
        // playlist with the same title is created in order
        // to replace the old one which contains too many
        // audios.
        Playlist updatedPlaylist = _listOfPlaylist[playlistIndex];
        updatedPlaylist.url = playlistUrl;
        updatedPlaylist.id = playlistId;
        warningMessageVM.updatedPlaylistTitle = playlistTitle;

        JsonDataService.saveToFile(
          model: updatedPlaylist,
          path: updatedPlaylist.getPlaylistDownloadFilePathName(),
        );

        // since the playlist was not added, but updated, null
        // is returned to avoid that the playlist is added to
        // the orderedTitleLst in the SettingsDataService json
        // file, which will cause a bug when filtering audios
        // of a playlist
        return null;
      }

      // Adding the playlist to the application

      addedPlaylist = await _addPlaylistIfNotExist(
        playlistUrl: playlistUrl,
        playlistQuality: playlistQuality,
        playlistTitle: playlistTitle,
        playlistId: playlistId,
      );

      JsonDataService.saveToFile(
        model: addedPlaylist,
        path: addedPlaylist.getPlaylistDownloadFilePathName(),
      );
    }

    warningMessageVM.setAddPlaylist(
      playlistTitle: addedPlaylist.title,
      playlistQuality: playlistQuality,
    );

    return addedPlaylist;
  }

  /// Downloads the audio of the videos referenced in the passed
  /// playlist.
  Future<void> downloadPlaylistAudios({
    required String playlistUrl,
  }) async {
    // if the playlist is already being downloaded, then
    // the method is not executed. This avoids that the
    // audios of the playlist are downloaded multiple times
    // if the user clicks multiple times on the download
    // button.
    if (downloadingPlaylistUrls.contains(playlistUrl)) {
      return;
    } else {
      downloadingPlaylistUrls.add(playlistUrl);
    }

    _stopDownloadPressed = false;
    _youtubeExplode ??= yt.YoutubeExplode();

    // get Youtube playlist
    String? playlistId = yt.PlaylistId.parsePlaylistId(playlistUrl);
    yt.Playlist youtubePlaylist;

    try {
      youtubePlaylist = await _youtubeExplode!.playlists.get(playlistId);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );

      // removing the playlist url from the downloadingPlaylistUrls
      // list since the playlist download has failed
      downloadingPlaylistUrls.remove(playlistUrl);

      return;
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      // removing the playlist url from the downloadingPlaylistUrls
      // list since the playlist download has failed
      downloadingPlaylistUrls.remove(playlistUrl);

      return;
    }

    String playlistTitle = youtubePlaylist.title;

    Playlist currentPlaylist = await _addPlaylistIfNotExist(
      playlistUrl: playlistUrl,
      playlistQuality: PlaylistQuality.voice,
      playlistTitle: playlistTitle,
      playlistId: playlistId!,
    );

    // get already downloaded audio file names
    String playlistDownloadFilePathName =
        currentPlaylist.getPlaylistDownloadFilePathName();

    final List<String> downloadedAudioOriginalVideoTitleLst =
        await _getPlaylistDownloadedAudioOriginalVideoTitleLst(
            currentPlaylist: currentPlaylist);

    await for (yt.Video youtubeVideo
        in _youtubeExplode!.playlists.getVideos(playlistId)) {
      _audioDownloadError = false;
      final Duration? audioDuration = youtubeVideo.duration;

      DateTime? videoUploadDate =
          (await _youtubeExplode!.videos.get(youtubeVideo.id.value)).uploadDate;

      // if the video upload date is not available, then the
      // video upload date is set so it is not null.
      videoUploadDate ??= DateTime(00, 1, 1);

      // using youtubeVideo.description is not correct since it
      // it is empty !
      String videoDescription =
          (await _youtubeExplode!.videos.get(youtubeVideo.id.value))
              .description;

      String compactVideoDescription = _createCompactVideoDescription(
        videoDescription: videoDescription,
        videoAuthor: youtubeVideo.author,
      );

      String youtubeVideoTitle = youtubeVideo.title;

      final bool alreadyDownloaded = downloadedAudioOriginalVideoTitleLst
          .any((originalVideoTitle) => originalVideoTitle == youtubeVideoTitle);

      if (alreadyDownloaded) {
        // avoids that the last downloaded audio download
        // informations remain displayed until all videos referenced
        // in the playlist have been handled.
        if (_isDownloading) {
          _isDownloading = false;

          notifyListeners();
        }

        continue;
      }

      if (_stopDownloadPressed) {
        break;
      }

      Stopwatch stopwatch = Stopwatch()..start();

      if (!_isDownloading) {
        _isDownloading = true;

        notifyListeners();
      }

      // Download the audio file

      final Audio audio = Audio(
        enclosingPlaylist: currentPlaylist,
        originalVideoTitle: youtubeVideoTitle,
        compactVideoDescription: compactVideoDescription,
        videoUrl: youtubeVideo.url,
        audioDownloadDateTime: DateTime.now(),
        videoUploadDate: videoUploadDate,
        audioDuration: audioDuration!,
        audioPlaySpeed: _getAudioPlaySpeed(currentPlaylist),
      );

      try {
        await _downloadAudioFile(
          youtubeVideoId: youtubeVideo.id,
          audio: audio,
        );
      } catch (e) {
        notifyDownloadError(
          errorType: ErrorType.downloadAudioYoutubeError,
          errorArgOne: e.toString(),
        );
        continue;
      }

      stopwatch.stop();

      audio.downloadDuration = stopwatch.elapsed;

      currentPlaylist.addDownloadedAudio(audio);

      JsonDataService.saveToFile(
        model: currentPlaylist,
        path: playlistDownloadFilePathName,
      );

      // should avoid that the last downloaded audio is
      // re-downloaded
      downloadedAudioOriginalVideoTitleLst.add(audio.validVideoTitle);

      notifyListeners();
    }

    _isDownloading = false;
    _youtubeExplode!.close();
    _youtubeExplode = null;

    // removing the playlist url from the downloadingPlaylistUrls
    // list since the playlist download has finished
    downloadingPlaylistUrls.remove(playlistUrl);

    notifyListeners();
  }

  void renameAudioFile({
    required Audio audio,
    required String modifiedAudioFileName,
  }) {
    if (audio.audioFileName == modifiedAudioFileName) {
      return;
    }

    if (!DirUtil.renameFile(
      fileToRenameFilePathName: audio.filePathName,
      newFileName: modifiedAudioFileName,
    )) {
      return;
    }

    Playlist enclosingPlaylist = audio.enclosingPlaylist!;
    enclosingPlaylist.renameDownloadedAndPlayableAudioFile(
      oldFileName: audio.audioFileName,
      newFileName: modifiedAudioFileName,
    );

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();
  }

  /// Since currently only one playlist is selectable, if the playlist
  /// selection status is changed, the playlist json file will be
  /// updated.
  void updatePlaylistSelection({
    required Playlist playlist,
    required bool isPlaylistSelected,
  }) {
    bool isPlaylistSelectionChanged = playlist.isSelected != isPlaylistSelected;

    if (isPlaylistSelectionChanged) {
      playlist.isSelected = isPlaylistSelected;

      // if the playlist is selected, the audio quality checkbox will be
      // checked or not according to the selected playlist quality
      if (isPlaylistSelected) {
        _isHighQuality = playlist.playlistQuality == PlaylistQuality.music;
      }

      // saving the playlist since its isSelected property has been updated
      JsonDataService.saveToFile(
        model: playlist,
        path: playlist.getPlaylistDownloadFilePathName(),
      );
    }
  }

  /// Is not private since it is defined in MockAudioDownloadVM
  notifyDownloadError({
    required ErrorType errorType,
    String? errorArgOne,
    String? errorArgTwo,
    String? errorArgThree,
  }) {
    _isDownloading = false;
    _downloadProgress = 0.0;
    _lastSecondDownloadSpeed = 0;
    _audioDownloadError = true;

    warningMessageVM.setError(
      errorType: errorType,
      errorArgOne: errorArgOne,
      errorArgTwo: errorArgTwo,
      errorArgThree: errorArgThree,
    );

    notifyListeners();
  }

  void stopDownload() {
    _stopDownloadPressed = true;
  }

  Future<Playlist> _addPlaylistIfNotExist({
    required String playlistUrl,
    required PlaylistQuality playlistQuality,
    required String playlistTitle,
    required String playlistId,
  }) async {
    Playlist addedPlaylist;
    int existingPlaylistIndex =
        _listOfPlaylist.indexWhere((element) => element.url == playlistUrl);

    if (existingPlaylistIndex == -1) {
      // playlist was never downloaded or was deleted and recreated, which
      // associates it to a new url

      addedPlaylist = await _createYoutubePlaylist(
        playlistUrl: playlistUrl,
        playlistQuality: playlistQuality,
        playlistTitle: playlistTitle,
        playlistId: playlistId,
      );

      // checking if current playlist was deleted and recreated. The
      // checking must compare the title of the added (recreated)
      // playlist with the title of the playlist in the _listOfPlaylist
      // since the added playlist url or id is different.
      existingPlaylistIndex = _listOfPlaylist
          .indexWhere((element) => element.title == addedPlaylist.title);

      if (existingPlaylistIndex != -1) {
        // current playlist was deleted and recreated since it is referenced
        // in the _listOfPlaylist and has the same title than the recreated
        // polaylist
        Playlist existingPlaylist = _listOfPlaylist[existingPlaylistIndex];
        addedPlaylist.downloadedAudioLst = existingPlaylist.downloadedAudioLst;
        addedPlaylist.playableAudioLst = existingPlaylist.playableAudioLst;
        _listOfPlaylist[existingPlaylistIndex] = addedPlaylist;
      }
    } else {
      // playlist was already downloaded and so is stored in
      // a playlist json file
      addedPlaylist = _listOfPlaylist[existingPlaylistIndex];
    }

    return addedPlaylist;
  }

  void setAudioQuality({
    required bool isHighQuality,
  }) {
    _isHighQuality = isHighQuality;

    notifyListeners();
  }

  /// {singleVideoTargetPlaylist} is the playlist to which the single
  /// video will be added.
  ///
  /// If the audio of the single video is correctly downloaded and
  /// is added to a playlist, then true is returned, false otherwise.
  ///
  /// Returning true will cause the single video url text field to be
  /// cleared.
  Future<bool> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoTargetPlaylist,
  }) async {
    _audioDownloadError = false;
    _stopDownloadPressed = false;
    _youtubeExplode ??= yt.YoutubeExplode();

    final yt.VideoId videoId;

    try {
      videoId = yt.VideoId(videoUrl);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );

      return false;
    } catch (e) {
      warningMessageVM.isSingleVideoUrlInvalid = true;

      return false;
    }

    yt.Video youtubeVideo;

    try {
      youtubeVideo = await _youtubeExplode!.videos.get(videoId);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );

      return false;
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return false;
    }

    final Duration? audioDuration = youtubeVideo.duration;
    DateTime? videoUploadDate = youtubeVideo.uploadDate;

    videoUploadDate ??= DateTime(00, 1, 1);

    String compactVideoDescription = _createCompactVideoDescription(
      videoDescription: youtubeVideo.description,
      videoAuthor: youtubeVideo.author,
    );

    final Audio audio = Audio(
      enclosingPlaylist: singleVideoTargetPlaylist,
      originalVideoTitle: youtubeVideo.title,
      compactVideoDescription: compactVideoDescription,
      videoUrl: youtubeVideo.url,
      audioDownloadDateTime: DateTime.now(),
      videoUploadDate: videoUploadDate,
      audioDuration: audioDuration!,
      audioPlaySpeed: _getAudioPlaySpeed(singleVideoTargetPlaylist),
    );

    final List<String> downloadedAudioFileNameLst = DirUtil.listFileNamesInDir(
      path: singleVideoTargetPlaylist.downloadPath,
      extension: 'mp3',
    );

    try {
      String existingAudioFileName = downloadedAudioFileNameLst
          .firstWhere((fileName) => fileName.contains(audio.validVideoTitle));
      notifyDownloadError(
        errorType: ErrorType.downloadAudioFileAlreadyOnAudioDirectory,
        errorArgOne: audio.validVideoTitle,
        errorArgTwo: existingAudioFileName,
        errorArgThree: singleVideoTargetPlaylist.title,
      );

      return false;
    } catch (_) {
      // file was not found in the downloaded audio directory
    }

    Stopwatch stopwatch = Stopwatch()..start();

    if (!_isDownloading) {
      _isDownloading = true;

      notifyListeners();
    }

    try {
      await _downloadAudioFile(
        youtubeVideoId: youtubeVideo.id,
        audio: audio,
      );
    } catch (e) {
      _youtubeExplode!.close();
      _youtubeExplode = null;

      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return false;
    }

    stopwatch.stop();

    audio.downloadDuration = stopwatch.elapsed;
    _isDownloading = false;
    _youtubeExplode!.close();
    _youtubeExplode = null;

    singleVideoTargetPlaylist.addDownloadedAudio(audio);

    // fixed bug which caused the playlist including the single
    // video audio to be not saved and so the audio was not
    // displayed in the playlist after restarting the app
    JsonDataService.saveToFile(
      model: singleVideoTargetPlaylist,
      path: singleVideoTargetPlaylist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();

    return true;
  }

  double _getAudioPlaySpeed(Playlist currentPlaylist) {
    return (currentPlaylist.audioPlaySpeed != 0)
        ? currentPlaylist.audioPlaySpeed
        : settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType: Playlists.playSpeed,
          );
  }

  /// This method verifies if the user selected a single playlist
  /// to download a single video audio. If the user selected more
  /// than one playlistor if the user did not select any playlist,
  /// then a warning message is displayed.
  Playlist? obtainSingleVideoPlaylist(List<Playlist> selectedPlaylists) {
    if (selectedPlaylists.length == 1) {
      return selectedPlaylists[0];
    } else if (selectedPlaylists.isEmpty) {
      warningMessageVM.isNoPlaylistSelectedForSingleVideoDownload = true;
      return null;
    } else {
      warningMessageVM.isTooManyPlaylistSelectedForSingleVideoDownload = true;
      return null;
    }
  }

  void moveAudioToPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
    required bool keepAudioInSourcePlaylistDownloadedAudioLst,
  }) {
    Playlist fromPlaylist = audio.enclosingPlaylist!;

    bool wasFileMoved = DirUtil.moveFileToDirectoryIfNotExistSync(
      sourceFilePathName: audio.filePathName,
      targetDirectoryPath: targetPlaylist.downloadPath,
    );

    if (!wasFileMoved) {
      warningMessageVM.setAudioNotMovedFromToPlaylistTitles(
        movedAudioValidVideoTitle: audio.validVideoTitle,
        movedFromPlaylistTitle: fromPlaylist.title,
        movedFromPlaylistType: fromPlaylist.playlistType,
        movedToPlaylistTitle: targetPlaylist.title,
        movedToPlaylistType: targetPlaylist.playlistType,
      );

      return;
    }

    if (keepAudioInSourcePlaylistDownloadedAudioLst) {
      // Keeping audio data in source playlist downloadedAudioLst
      // means that the audio will not be redownloaded if the
      // Download All is applyed to the source playlist. But since
      // the audio is moved to the target playlist, it has to
      // be removed from the source playlist playableAudioLst.
      fromPlaylist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: audio,
      );
      fromPlaylist.setMovedAudioToPlaylistTitle(
        movedAudio: audio,
        movedToPlaylistTitle: targetPlaylist.title,
      );
    } else {
      fromPlaylist.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: audio,
      );
    }

    targetPlaylist.addMovedAudio(
      movedAudio: audio,
      movedFromPlaylistTitle: fromPlaylist.title,
    );

    JsonDataService.saveToFile(
      model: fromPlaylist,
      path: fromPlaylist.getPlaylistDownloadFilePathName(),
    );

    JsonDataService.saveToFile(
      model: targetPlaylist,
      path: targetPlaylist.getPlaylistDownloadFilePathName(),
    );

    warningMessageVM.setAudioMovedFromToPlaylistTitles(
        movedAudioValidVideoTitle: audio.validVideoTitle,
        movedFromPlaylistTitle: fromPlaylist.title,
        movedFromPlaylistType: fromPlaylist.playlistType,
        movedToPlaylistTitle: targetPlaylist.title,
        movedToPlaylistType: targetPlaylist.playlistType,
        keepAudioDataInSourcePlaylist:
            keepAudioInSourcePlaylistDownloadedAudioLst);
  }

  void copyAudioToPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    bool wasFileCopied = DirUtil.copyFileToDirectorySync(
      sourceFilePathName: audio.filePathName,
      targetDirectoryPath: targetPlaylist.downloadPath,
    );

    Playlist fromPlaylist = audio.enclosingPlaylist!;
    String fromPlaylistTitle = fromPlaylist.title;

    if (!wasFileCopied) {
      warningMessageVM.setAudioNotCopiedFromToPlaylistTitles(
          copiedAudioValidVideoTitle: audio.validVideoTitle,
          copiedFromPlaylistTitle: fromPlaylistTitle,
          copiedFromPlaylistType: fromPlaylist.playlistType,
          copiedToPlaylistTitle: targetPlaylist.title,
          copiedToPlaylistType: targetPlaylist.playlistType);

      return;
    }

    targetPlaylist.addCopiedAudio(
      copiedAudio: audio,
      copiedFromPlaylistTitle: fromPlaylistTitle,
    );

    fromPlaylist.setCopiedAudioToPlaylistTitle(
      copiedAudio: audio,
      copiedToPlaylistTitle: targetPlaylist.title,
    );

    JsonDataService.saveToFile(
      model: fromPlaylist,
      path: fromPlaylist.getPlaylistDownloadFilePathName(),
    );

    JsonDataService.saveToFile(
      model: targetPlaylist,
      path: targetPlaylist.getPlaylistDownloadFilePathName(),
    );

    warningMessageVM.setAudioCopiedFromToPlaylistTitles(
        copiedAudioValidVideoTitle: audio.validVideoTitle,
        copiedFromPlaylistTitle: fromPlaylistTitle,
        copiedFromPlaylistType: fromPlaylist.playlistType,
        copiedToPlaylistTitle: targetPlaylist.title,
        copiedToPlaylistType: targetPlaylist.playlistType);
  }

  /// Physically deletes the audio file from the audio playlist
  /// directory and removes the audio reference from the playlist
  /// playable audio list.
  void deleteAudioMp3({
    required Audio audio,
  }) {
    DirUtil.deleteFileIfExist(audio.filePathName);

    // since the audio mp3 file has been deleted, the audio is no
    // longer in the playlist playable audio list
    audio.enclosingPlaylist!.removePlayableAudio(
      playableAudio: audio,
    );
  }

  /// User selected the audio menu item "Delete audio from
  /// playlist aswell". This method physically deletes the audio
  /// file from the audio playlist directory as well as deleting
  /// the audio reference from the playlist downloaded audio list
  /// and from the playlist playable audio list. This means that
  /// the playlist json file is modified.
  void deleteAudioFromPlaylistAswell({
    required Audio audio,
  }) {
    DirUtil.deleteFileIfExist(audio.filePathName);

    Playlist? enclosingPlaylist = audio.enclosingPlaylist;

    enclosingPlaylist!.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
      downloadedAudio: audio,
    );

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );

    if (enclosingPlaylist.playlistType == PlaylistType.youtube) {
      if (audio.movedFromPlaylistTitle == null &&
          audio.copiedFromPlaylistTitle == null) {
        // the case if the audio was not moved or copied from
        // another playlist, but was downloaded from the
        // Youtube playlist
        warningMessageVM.setDeleteAudioFromPlaylistAswellTitle(
            deleteAudioFromPlaylistAswellTitle: enclosingPlaylist.title,
            deleteAudioFromPlaylistAswellAudioVideoTitle:
                audio.originalVideoTitle);
      }
    }
  }

  /// Method called by PlaylistListVM when the user selects the update
  /// playlist JSON files menu item.
  void updatePlaylistJsonFiles() {
    List<Playlist> copyOfList = List<Playlist>.from(_listOfPlaylist);

    for (Playlist playlist in copyOfList) {
      bool isPlaylistDownloadPathUpdated = false;
      Playlist correspondingOriginalPlaylist =
          _listOfPlaylist.firstWhere((element) => element == playlist);

      String currentPlaylistDownloadHomePath =
          path.dirname(playlist.downloadPath);

      if (currentPlaylistDownloadHomePath != _playlistsRootPath) {
        // the case if the playlist dir obtained from another audio
        // dir was copied on the app audio dir. Then, it must be
        // updated to the app audio dir
        correspondingOriginalPlaylist.downloadPath =
            _playlistsRootPath + path.separator + playlist.title;
        isPlaylistDownloadPathUpdated = true;
      }

      if (!Directory(playlist.downloadPath).existsSync()) {
        // the case if the playlist dir has been deleted by the user
        // or by another app
        _listOfPlaylist.remove(playlist);
        continue;
      }

      // remove the audios from the playlable audio list which are no
      // longer in the playlist directory
      int removedPlayableAudioNumber =
          correspondingOriginalPlaylist.updatePlayableAudioLst();

      // update validVideoTitle of the playlists audios. This is useful
      // when the method computing the validVideoTitle has been improved
      bool isAnAudioValidVideoTitleChanged = false;

      for (Audio audio in correspondingOriginalPlaylist.downloadedAudioLst) {
        String reCreatedValidVideoTitle =
            Audio.createValidVideoTitle(audio.originalVideoTitle);

        if (reCreatedValidVideoTitle != audio.validVideoTitle) {
          audio.validVideoTitle = reCreatedValidVideoTitle;
          isAnAudioValidVideoTitleChanged = true;
        }
      }

      if (isPlaylistDownloadPathUpdated ||
          removedPlayableAudioNumber > 0 ||
          isAnAudioValidVideoTitleChanged) {
        JsonDataService.saveToFile(
          model: playlist,
          path: playlist.getPlaylistDownloadFilePathName(),
        );
      }
    }
  }

  int getPlaylistJsonFileSize({
    required Playlist playlist,
  }) {
    return File(playlist.getPlaylistDownloadFilePathName()).lengthSync();
  }

  String _createCompactVideoDescription({
    required String videoDescription,
    required String videoAuthor,
  }) {
    // Extraire les 3 premières lignes de la description
    List<String> videoDescriptionLinesLst = videoDescription.split('\n');
    String firstThreeLines = videoDescriptionLinesLst.take(3).join('\n');

    // Extraire les noms propres qui ne se trouvent pas dans les 3 premières lignes
    String linesAfterFirstThreeLines =
        videoDescriptionLinesLst.skip(3).join('\n');
    linesAfterFirstThreeLines =
        _removeTimestampLines('$linesAfterFirstThreeLines\n');
    final List<String> linesAfterFirstThreeLinesWordsLst =
        linesAfterFirstThreeLines.split(RegExp(r'[ \n]'));

    // Trouver les noms propres consécutifs (au moins deux)
    List<String> consecutiveProperNames = [];

    for (int i = 0; i < linesAfterFirstThreeLinesWordsLst.length - 1; i++) {
      if (linesAfterFirstThreeLinesWordsLst[i].isNotEmpty &&
          _isEnglishOrFrenchUpperCaseLetter(
              linesAfterFirstThreeLinesWordsLst[i][0]) &&
          linesAfterFirstThreeLinesWordsLst[i + 1].isNotEmpty &&
          _isEnglishOrFrenchUpperCaseLetter(
              linesAfterFirstThreeLinesWordsLst[i + 1][0])) {
        consecutiveProperNames.add(
            '${linesAfterFirstThreeLinesWordsLst[i]} ${linesAfterFirstThreeLinesWordsLst[i + 1]}');
        i++; // Pour ne pas prendre en compte les noms propres suivants qui font déjà partie d'une paire consécutive
      }
    }

    // Combiner firstThreeLines et consecutiveProperNames en une seule chaîne
    final String compactVideoDescription;

    if (consecutiveProperNames.isEmpty) {
      compactVideoDescription = '$videoAuthor\n\n$firstThreeLines ...';
    } else {
      compactVideoDescription =
          '$videoAuthor\n\n$firstThreeLines ...\n\n${consecutiveProperNames.join(', ')}';
    }

    return compactVideoDescription;
  }

  bool _isEnglishOrFrenchUpperCaseLetter(String letter) {
    // Expression régulière pour vérifier si la lettre est une lettre
    // majuscule valide en anglais ou en français
    RegExp validLetterRegex = RegExp(r'[A-ZÀ-ÿ]');
    // Expression régulière pour vérifier si le caractère n'est pas
    // un chiffre
    RegExp notDigitRegex = RegExp(r'\D');

    return validLetterRegex.hasMatch(letter) && notDigitRegex.hasMatch(letter);
  }

  String _removeTimestampLines(String text) {
    // Expression régulière pour identifier les lignes de texte de la vidéo formatées comme les timestamps
    RegExp timestampRegex = RegExp(r'^\d{1,2}:\d{2} .+\n', multiLine: true);

    // Supprimer les lignes correspondantes
    return text.replaceAll(timestampRegex, '').trim();
  }

  Future<Playlist> _createYoutubePlaylist({
    required String playlistUrl,
    required PlaylistQuality playlistQuality,
    required String playlistTitle,
    required String playlistId,
  }) async {
    Playlist playlist = Playlist(
      url: playlistUrl,
      id: playlistId,
      title: playlistTitle,
      playlistType: PlaylistType.youtube,
      playlistQuality: playlistQuality,
    );

    _listOfPlaylist.add(playlist);

    return await _setPlaylistPath(
      playlistTitle: playlistTitle,
      playlist: playlist,
    );
  }

  Future<Playlist> _setPlaylistPath({
    required String playlistTitle,
    required Playlist playlist,
  }) async {
    final String playlistDownloadPath =
        '$_playlistsRootPath${Platform.pathSeparator}$playlistTitle';

    // ensure playlist audio download dir exists
    await DirUtil.createDirIfNotExist(pathStr: playlistDownloadPath);

    playlist.downloadPath = playlistDownloadPath;

    return playlist;
  }

  /// Returns an empty list if the passed playlist was created or
  /// recreated.
  Future<List<String>> _getPlaylistDownloadedAudioOriginalVideoTitleLst({
    required Playlist currentPlaylist,
  }) async {
    List<Audio> playlistDownloadedAudioLst = currentPlaylist.downloadedAudioLst;

    return playlistDownloadedAudioLst
        .map((downloadedAudio) => downloadedAudio.originalVideoTitle)
        .toList();
  }

  Future<void> _downloadAudioFile({
    required yt.VideoId youtubeVideoId,
    required Audio audio,
  }) async {
    _currentDownloadingAudio = audio;
    final yt.StreamManifest streamManifest;

    try {
      streamManifest = await _youtubeExplode!.videos.streamsClient.getManifest(
        youtubeVideoId,
      );
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return;
    }

    final yt.AudioOnlyStreamInfo audioStreamInfo;

    if (_isHighQuality) {
      audioStreamInfo = streamManifest.audioOnly.withHighestBitrate();
    } else {
      audioStreamInfo = streamManifest.audioOnly.first;
    }

    if (_isHighQuality) {
      audio.setAudioToMusicQuality;
    }

    final int audioFileSize = audioStreamInfo.size.totalBytes;
    audio.audioFileSize = audioFileSize;

    await _youtubeDownloadAudioFile(
      audio,
      audioStreamInfo,
      audioFileSize,
    );
  }

  Future<void> _youtubeDownloadAudioFile(
    Audio audio,
    yt.AudioOnlyStreamInfo audioStreamInfo,
    int audioFileSize,
  ) async {
    final File file = File(audio.filePathName);
    final IOSink audioFileSink = file.openWrite();
    final Stream<List<int>> audioStream =
        _youtubeExplode!.videos.streamsClient.get(audioStreamInfo);
    int totalBytesDownloaded = 0;
    int previousSecondBytesDownloaded = 0;

    Duration updateInterval = const Duration(seconds: 1);
    DateTime lastUpdate = DateTime.now();
    Timer timer = Timer.periodic(updateInterval, (timer) {
      if (DateTime.now().difference(lastUpdate) >= updateInterval) {
        _updateDownloadProgress(totalBytesDownloaded / audioFileSize,
            totalBytesDownloaded - previousSecondBytesDownloaded);
        previousSecondBytesDownloaded = totalBytesDownloaded;
        lastUpdate = DateTime.now();
      }
    });

    await for (var byteChunk in audioStream) {
      totalBytesDownloaded += byteChunk.length;

      // Vérifiez si le délai a été dépassé avant de mettre à jour la
      // progression
      if (DateTime.now().difference(lastUpdate) >= updateInterval) {
        _updateDownloadProgress(totalBytesDownloaded / audioFileSize,
            totalBytesDownloaded - previousSecondBytesDownloaded);
        previousSecondBytesDownloaded = totalBytesDownloaded;
        lastUpdate = DateTime.now();
      }

      audioFileSink.add(byteChunk);
    }

    // Assurez-vous de mettre à jour la progression une dernière fois
    // à 100% avant de terminer
    _updateDownloadProgress(1.0, 0);

    // Annulez le Timer pour éviter les appels inutiles
    timer.cancel();

    await audioFileSink.flush();
    await audioFileSink.close();
  }

  void _updateDownloadProgress(double progress, int lastSecondDownloadSpeed) {
    _downloadProgress = progress;
    _lastSecondDownloadSpeed = lastSecondDownloadSpeed;

    notifyListeners();
  }

  /// Returns a map containing the chapters names and their HH:mm:ss
  /// time position in the audio.
  Map<String, String> getVideoDescriptionChapters({
    required String videoDescription,
  }) {
    // Extract the "TIME CODE" section from the description.
    String timeCodeSection = videoDescription.split('TIME CODE :').last;

    // Define a pattern to match time codes and chapter names.
    RegExp pattern = RegExp(r'(\d{1,2}:\d{2}(?::\d{2})?)\s+(.+)');

    // Use the pattern to find matches in the time code section.
    Iterable<RegExpMatch> matches = pattern.allMatches(timeCodeSection);

    // Create a map to hold the time codes and chapter names.
    Map<String, String> chapters = <String, String>{};

    for (var match in matches) {
      var timeCode = match.group(1)!;
      var chapterName = match.group(2)!;
      chapters[chapterName] = timeCode;
    }

    return chapters;
  }
}

Future<void> main() async {
  WarningMessageVM warningMessageVM = WarningMessageVM();
  AudioDownloadVM audioDownloadVM = AudioDownloadVM(
      warningMessageVM: warningMessageVM,
      settingsDataService: SettingsDataService(
        sharedPreferences: await SharedPreferences.getInstance(),
      ));

  String videoDescription = '''Ma chaîne YouTube principale
  https://www.youtube.com/@LeFuturologue


  ME SOUTENIR FINANCIÈREMENT :

  Sur Tipeee
  https://fr.tipeee.com/le-futurologue
  Sur PayPal
  https://www.paypal.com/donate/?hosted_button_id=BBXFGSM5D5WQS
  Sur Patreon
  https://patreon.com/LeFuturologue


  MES VIDÉOS COURTES :

  Sur YouTube 
  https://youtube.com/@LeFuturologue/shorts
  Sur Instagram
  https://www.instagram.com/le.futurologue/
  Sur TikTok
  https://www.tiktok.com/@le.futurologue


  TIME CODE :

  0:00 Introduction
  1:37 Qui es-tu ?
  3:29 Les IA vont-elles tous nous mettre au chômage ?
  21:01 Faut-il mettre les IA en open source ? 
  48:05 Comment fonctionne les agents ?
  1:14:31 Définition de l’IA autonome, de l’IA générale et de la super IA
  1:41:23 Que manque-t-il pour avoir une AGI ?
  1:57:23 À quel point faut-il avoir peur de L’IA ?
  2:04:36 Les meilleurs arguments de ceux qui ne croient pas aux risques existentiels des AGI 
  2:11:48 Y aura-t-il plusieurs AGI ?
  2:14:06 Est-ce que l’explosion d’intelligence sera rapide ? 
  2:22:37 Quels impacts aurait une IA qui devient consciente ?
  2:53:18 Quelle est la probabilité qu’on arrive à aligner une AGI avant qu’on en crée une ?
  3:09:54 Ressources pour aller plus loin
  3:11:57 Un message pour l’humanité 


  RESSOURCES MENTIONNÉES :

  La chaîne YouTube de Jérémy
  https://youtube.com/@suboptimalchannel9704
  Le Twitter de Jérémy
  https://twitter.com/suboptimalc?s=21&t=KiEIZQwoZSOhseL0LUGLpg
  L’organisation « EffiSciences »
  https://www.effisciences.org/

  ChatGPT''';

  Map<String, String> chapters = audioDownloadVM.getVideoDescriptionChapters(
    videoDescription: videoDescription,
  );

  // Print the chapters.
  for (var chapter in chapters.entries) {
    print('${chapter.key}: ${chapter.value}');
  }
}
