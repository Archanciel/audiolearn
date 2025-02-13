import 'package:audiolearn/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

// importing youtube_explode_dart as yt enables to name the app Model
// playlist class as Playlist so it does not conflict with
// youtube_explode_dart Playlist class name.
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../services/settings_data_service.dart';
import '../services/json_data_service.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/dir_util.dart';
import 'comment_vm.dart';
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

  bool isHighQuality = false;

  bool _stopDownloadPressed = false;
  bool get isDownloadStopping => _stopDownloadPressed;

  bool _audioDownloadError = false;
  bool get audioDownloadError => _audioDownloadError;

  final WarningMessageVM warningMessageVM;

  final SettingsDataService _settingsDataService;

  /// Passing true for {isTest} has the effect that the windows
  /// test directory is used as playlist root directory. This
  /// directory is located in the test directory of the project.
  ///
  /// Otherwise, the windows or smartphone audio root directory
  /// is used.
  AudioDownloadVM({
    required this.warningMessageVM,
    required SettingsDataService settingsDataService,
    bool isTest = false,
  }) : _settingsDataService = settingsDataService {
    _playlistsRootPath = _settingsDataService.get(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath);

    loadExistingPlaylists();
  }

  void loadExistingPlaylists() {
    // reinitializing the list of playlist is necessary since
    // loadExistingPlaylists() is also called by PlaylistListVM.
    // updateSettingsAndPlaylistJsonFiles() method.
    _listOfPlaylist = [];

    List<String> playlistPathFileNameLst = DirUtil.listPathFileNamesInSubDirs(
      rootPath: _playlistsRootPath,
      fileExtension: 'json',
      excludeDirName: kCommentDirName,
    );

    playlistPathFileNameLst.removeWhere(
      (filePath) => filePath.contains(kSettingsFileName),
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
          isHighQuality =
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

    //  notifyListeners(); not necessary since the unique
    //                     Consumer<AudioDownloadVM> is not concerned
    //                     by the _listOfPlaylist changes
  }

  Future<Playlist?> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    return addPlaylistCallableAlsoByMock(
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
  /// will be tested by the integration test.
  Future<Playlist?> addPlaylistCallableAlsoByMock({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
    String? mockYoutubePlaylistTitle,
  }) async {
    Playlist addedPlaylist;

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

      if (playlistQuality == PlaylistQuality.music) {
        addedPlaylist.audioPlaySpeed = 1.0;
      } else {
        addedPlaylist.audioPlaySpeed = _settingsDataService.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
        );
      }

      await setPlaylistPath(
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

      warningMessageVM.annoncePlaylistAddition(
        playlistTitle: localPlaylistTitle,
        playlistQuality: playlistQuality,
        playlistType: PlaylistType.local,
      );

      return addedPlaylist;
    } else if (!playlistUrl.contains('list=')) {
      // the case if the url is a video url and the user
      // clicked on the Add button instead of the Download
      // single video audio button or if the String pasted to
      // the url text field is not a valid Youtube playlist url.
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

      if (playlistTitle.contains(',')) {
        // A playlist title containing one or several commas can not
        // be handled by the application due to the fact that when
        // this playlist title will be added in the  playlist ordered
        // title list of the SettingsDataService, since the elements
        // of this list are separated by a comma, the playlist title
        // containing on or more commas will be divided in two or more
        // titles which will then not be findable in the playlist
        // directory. For this reason, adding such a playlist is refused
        // by the method.
        warningMessageVM.invalidYoutubePlaylistTitle = playlistTitle;

        return null;
      } else if (playlistTitle == '') {
        // The case if the Youtube playlist is private
        warningMessageVM.signalPrivatePlaylistAddition();

        return null;
      }

      int playlistIndex = _listOfPlaylist
          .indexWhere((playlist) => playlist.title == playlistTitle);

      if (playlistIndex != -1) {
        // This means that the playlist was not added, but
        // that its url was updated. The case when a new
        // playlist with the same title is created in order
        // to replace the old one which contains too many
        // videos.
        _updateYoutubePlaylisrUrl(
          playlistIndex: playlistIndex,
          playlistId: playlistId,
          playlistUrl: playlistUrl,
          playlistTitle: playlistTitle,
        );

        // since the playlist was not added, but updated, null
        // is returned to avoid that the playlist is added to
        // the orderedTitleLst in the SettingsDataService json
        // file, which will cause a bug when filtering audio
        // of a playlist
        return null;
      }

      // Adding the Youtube playlist to the application

      addedPlaylist = await _addYoutubePlaylistIfNotExist(
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

    warningMessageVM.annoncePlaylistAddition(
      playlistTitle: addedPlaylist.title,
      playlistQuality: playlistQuality,
      playlistType: PlaylistType.youtube,
    );

    return addedPlaylist;
  }

  /// This method handles the case where the user wants to update
  /// the url of a Youtube playlist.
  ///
  /// After having been used a lot by the user, the Youtube playlist
  /// may contain too many videos. Removing manually the already listened
  /// videos from the Youtube playlist takes too much time. Instead, the
  /// too big Youtube playlist is deleted or is renamed and a new Youtube
  /// playlist with the same title is created. The new Youtube playlist is
  /// then added in the application. The method is called by the
  /// AudioDownloadVM.addPlaylistCallableAlsoByMock() method in the case
  /// where the new Youtube playlist has the same title than the deleted
  /// or renamed Youtube playlist. In this case, the existing application
  /// playlist is updated with the new Youtube playlist url and id.
  void _updateYoutubePlaylisrUrl({
    required int playlistIndex,
    required String playlistId,
    required String playlistUrl,
    required String playlistTitle,
  }) {
    Playlist updatedPlaylist = _listOfPlaylist[playlistIndex];
    updatedPlaylist.url = playlistUrl;
    updatedPlaylist.id = playlistId;
    warningMessageVM.updatedPlaylistTitle = playlistTitle;

    JsonDataService.saveToFile(
      model: updatedPlaylist,
      path: updatedPlaylist.getPlaylistDownloadFilePathName(),
    );
  }

  /// Method called once in order to set the channel value of all already
  /// downloaded audio files of all playlists. This is necessary since
  /// the channel value of the audio files was not set when those audio files
  /// were downloaded.
  ///
  /// This functionality is no longer used since now the Youtube channel
  /// is set when the audio is downloaded from the Youtube playlist.
  Future<void> ensureAllAudioYoutubeChannelOfAllPlaylistsAreSet() async {
    int numberOfModifiedDownloadedAudio = 0;
    int numberOfModifiedPlayableAudio = 0;

    for (Playlist playlist in _listOfPlaylist) {
      if (playlist.playlistType == PlaylistType.local) {
        continue;
      }

      List<int> modifiedAudioNumberLst =
          await obtainPlaylistAudioYoutubeChannelAlt(
        playlist: playlist,
      );

      numberOfModifiedDownloadedAudio += modifiedAudioNumberLst[0];
      numberOfModifiedPlayableAudio += modifiedAudioNumberLst[1];

      JsonDataService.saveToFile(
        model: playlist,
        path: playlist.getPlaylistDownloadFilePathName(),
      );
    }

    warningMessageVM.confirmYoutubeChannelModifications(
      numberOfModifiedDownloadedAudio: numberOfModifiedDownloadedAudio,
      numberOfModifiedPlayableAudio: numberOfModifiedPlayableAudio,
    );

    notifyListeners();
  }

  /// Downloads the audio of the videos referenced in the passed
  /// playlist url. If the audio of a video has already been
  /// downloaded, it will not be downloaded again.
  Future<List<int>> obtainPlaylistAudioYoutubeChannel({
    required Playlist playlist,
  }) async {
    String playlistUrl = playlist.url;
    _youtubeExplode ??= yt.YoutubeExplode();

    // get the Youtube playlist
    String? playlistId = yt.PlaylistId.parsePlaylistId(playlistUrl);

    int numberOfModifiedDownloadedAudio = 0;
    int numberOfModifiedPlayableAudio = 0;

    Stream<yt.Video> videoStream =
        _youtubeExplode!.playlists.getVideos(playlistId).asBroadcastStream();

    try {
      // try / catch necessary due to possible youtube explode errors
      await for (yt.Video youtubeVideo in videoStream) {
        final String youtubeVideoTitle = youtubeVideo.title;
        final String youtubeVideoChannel = youtubeVideo.author;

        try {
          Audio downloadedAudio = playlist.downloadedAudioLst.firstWhere(
            (audio) => audio.originalVideoTitle == youtubeVideoTitle,
          );

          if (downloadedAudio.youtubeVideoChannel == youtubeVideoChannel) {
            continue;
          } else {
            downloadedAudio.youtubeVideoChannel = youtubeVideoChannel;
            numberOfModifiedDownloadedAudio++;
          }

          try {
            Audio correspondingPlayableAudio = playlist.playableAudioLst
                .firstWhere((audio) => audio == downloadedAudio);
            correspondingPlayableAudio.youtubeVideoChannel =
                youtubeVideoChannel;
            numberOfModifiedPlayableAudio++;
          } catch (_) {
            // If the downloaded audio is not in the playable audio list of the enclosing playlist
            continue;
          }
        } catch (_) {
          // The audio of the video has not been downloaded
          continue;
        }
      }
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );
    }

    _youtubeExplode!.close();
    _youtubeExplode = null;

    return [
      numberOfModifiedDownloadedAudio,
      numberOfModifiedPlayableAudio,
    ];
  }

  /// Downloads the audio of the videos referenced in the passed
  /// playlist url. If the audio of a video has already been
  /// downloaded, it will not be downloaded again.
  Future<List<int>> obtainPlaylistAudioYoutubeChannelAlt({
    required Playlist playlist,
  }) async {
    _youtubeExplode ??= yt.YoutubeExplode();
    List<Audio> downloadedAudioLst = playlist.downloadedAudioLst;

    int numberOfModifiedDownloadedAudio = 0;
    int numberOfModifiedPlayableAudio = 0;
    yt.VideoId videoId;
    yt.Video youtubeVideo;
    String youtubeVideoChannel;

    try {
      // try / catch necessary due to possible youtube explode errors
      for (Audio audio in downloadedAudioLst) {
        String videoUrl = audio.videoUrl;
        videoId = yt.VideoId(videoUrl);
        youtubeVideo = await _youtubeExplode!.videos.get(videoId);
        youtubeVideoChannel = youtubeVideo.author;

        if (audio.youtubeVideoChannel == youtubeVideoChannel) {
          continue;
        } else {
          audio.youtubeVideoChannel = youtubeVideoChannel;
          numberOfModifiedDownloadedAudio++;
        }

        try {
          Audio correspondingPlayableAudio = playlist.playableAudioLst
              .firstWhere((playableAudio) => playableAudio == audio);
          correspondingPlayableAudio.youtubeVideoChannel = youtubeVideoChannel;
          numberOfModifiedPlayableAudio++;
        } catch (_) {
          // If the downloaded audio is not in the playable audio list of the enclosing playlist
          continue;
        }
      }
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );
    }

    _youtubeExplode!.close();
    _youtubeExplode = null;

    return [
      numberOfModifiedDownloadedAudio,
      numberOfModifiedPlayableAudio,
    ];
  }

  /// Downloads the audio of the videos referenced in the passed
  /// playlist url. If the audio of a video has already been
  /// downloaded, it will not be downloaded again.
  Future<void> downloadPlaylistAudio({
    required String playlistUrl,
  }) async {
    // if the playlist is already being downloaded, then
    // the method is not executed. This avoids that the
    // audio of the playlist are downloaded multiple times
    // if the user clicks multiple times on the download
    // button.
    if (downloadingPlaylistUrls.contains(playlistUrl)) {
      return;
    } else {
      downloadingPlaylistUrls.add(playlistUrl);
    }

    _stopDownloadPressed = false;
    _youtubeExplode ??= yt.YoutubeExplode();

    // get the Youtube playlist
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

    // Handling the case where the Youtube playlist was deleted or
    // renamed and a new playlist with the same title was created.
    Playlist currentPlaylist;
    int existingPlaylistIndex =
        _listOfPlaylist.indexWhere((element) => element.url == playlistUrl);

    if (existingPlaylistIndex > -1) {
      currentPlaylist = _listOfPlaylist[existingPlaylistIndex];
    } else {
      currentPlaylist = await _addYoutubePlaylistIfNotExist(
        playlistUrl: playlistUrl,
        playlistQuality: PlaylistQuality.voice,
        playlistTitle: playlistTitle,
        playlistId: playlistId!,
      );
    }

    String downloadedPlaylistFilePathName =
        currentPlaylist.getPlaylistDownloadFilePathName();

    final List<String> downloadedAudioOriginalVideoTitleLst =
        await _getPlaylistDownloadedAudioOriginalVideoTitleLst(
            currentPlaylist: currentPlaylist);

    // AudioPlayer is used to get the audio duration of the
    // downloaded audio files
    final AudioPlayer audioPlayer = AudioPlayer();

    await for (yt.Video youtubeVideo
        in _youtubeExplode!.playlists.getVideos(playlistId)) {
      _audioDownloadError = false;

      DateTime? videoUploadDate =
          (await _youtubeExplode!.videos.get(youtubeVideo.id.value)).uploadDate;

      // if the video upload date is not available, then the
      // video upload date is set so it is not null.
      videoUploadDate ??= DateTime(00, 1, 1);

      // using youtubeVideo.description is not correct since it
      // it is empty !
      final String videoDescription =
          (await _youtubeExplode!.videos.get(youtubeVideo.id.value))
              .description;

      final String compactVideoDescription = _createCompactVideoDescription(
        videoDescription: videoDescription,
        videoAuthor: youtubeVideo.author,
      );

      final String youtubeVideoChannel = youtubeVideo.author;
      final String youtubeVideoTitle = youtubeVideo.title;

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

      // Download the audio file

      Stopwatch stopwatch = Stopwatch()..start();

      if (!_isDownloading) {
        _isDownloading = true;

        notifyListeners();
      }

      final Audio audio = Audio(
        youtubeVideoChannel: youtubeVideoChannel,
        enclosingPlaylist: currentPlaylist,
        originalVideoTitle: youtubeVideoTitle,
        compactVideoDescription: compactVideoDescription,
        videoUrl: youtubeVideo.url,
        audioDownloadDateTime: DateTime.now(),
        videoUploadDate: videoUploadDate,
        audioDuration: Duration.zero, // will be set by AudioPlayer after
        //                               the download audio file is created
        audioPlaySpeed: _determineNewAudioPlaySpeed(currentPlaylist),
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
      audio.audioDuration = await getMp3DurationWithAudioPlayer(
        audioPlayer: audioPlayer,
        filePathName: audio.filePathName,
      );

      currentPlaylist.addDownloadedAudio(audio);

      JsonDataService.saveToFile(
        model: currentPlaylist,
        path: downloadedPlaylistFilePathName,
      );

      // should avoid that the last downloaded audio is
      // re-downloaded
      downloadedAudioOriginalVideoTitleLst.add(audio.validVideoTitle);

      notifyListeners();
    }

    audioPlayer.dispose();

    _isDownloading = false;
    _youtubeExplode!.close();
    _youtubeExplode = null;

    // removing the playlist url from the downloadingPlaylistUrls
    // list since the playlist download has finished
    downloadingPlaylistUrls.remove(playlistUrl);

    notifyListeners();
  }

  /// Rename the passed audio file as well as the associated comment file
  /// if it exists.
  void renameAudioFile({
    required Audio audio,
    required String audioModifiedFileName,
  }) {
    String audioOldFileName = audio.audioFileName;
    String playlistDownloadPath = audio.enclosingPlaylist!.downloadPath;

    if (audioOldFileName == audioModifiedFileName) {
      // the case if the user clicked on modify button without
      // having modified the audio file name
      return;
    }

    // Ensuring the new audio file name has the .mp3 extension
    if (!audioModifiedFileName.endsWith('.mp3')) {
      warningMessageVM.renameFileNameIsInvalid(
        invalidRenameFileName: audioModifiedFileName,
      );

      return;
    }

    // Verifying if the new audio file name is already used
    if (File(
            '$playlistDownloadPath${Platform.pathSeparator}$audioModifiedFileName')
        .existsSync()) {
      warningMessageVM.renameFileNameIsAlreadyUsed(
        invalidRenameFileName: audioModifiedFileName,
      );

      return;
    }

    String newCommentFilePathName = CommentVM.buildCommentFilePathName(
      playlistDownloadPath: playlistDownloadPath,
      audioFileName: audioModifiedFileName,
    );

    String commentNewFileName =
        newCommentFilePathName.split(Platform.pathSeparator).last;

    // Verifying if the new comment file name is already used
    if (File(newCommentFilePathName).existsSync()) {
      warningMessageVM.renameCommentFileNameIsAlreadyUsed(
        invalidRenameFileName: DirUtil.getFileNameWithoutMp3Extension(
          mp3FileName: audioModifiedFileName,
        ),
      );

      return;
    }

    // renaming the audio file

    if (!DirUtil.renameFile(
      fileToRenameFilePathName: audio.filePathName,
      newFileName: audioModifiedFileName,
    )) {
      return;
    }

    Playlist enclosingPlaylist = audio.enclosingPlaylist!;
    String oldCommentFilePathName = CommentVM.buildCommentFilePathName(
      playlistDownloadPath: playlistDownloadPath,
      audioFileName: audioOldFileName,
    );

    enclosingPlaylist.renameDownloadedAndPlayableAudioFile(
      oldFileName: audioOldFileName,
      newFileName: audioModifiedFileName,
    );

    // renaming the comment file if it exists

    if (File(oldCommentFilePathName).existsSync()) {
      DirUtil.renameFile(
        fileToRenameFilePathName: oldCommentFilePathName,
        newFileName: commentNewFileName,
      );

      // Displaying a warning message to confirm that the audio
      // file and its associated comments file were renamed
      warningMessageVM.confirmRenameAudioAndCommentFile(
        oldFileName: DirUtil.getFileNameWithoutMp3Extension(
          mp3FileName: audioOldFileName,
        ),
        newFileName: DirUtil.getFileNameWithoutMp3Extension(
          mp3FileName: audioModifiedFileName,
        ),
      );
    } else {
      // Displaying a warning message to confirm that the
      // audio file was renamed
      warningMessageVM.confirmRenameAudioFile(
        oldFileName: DirUtil.getFileNameWithoutMp3Extension(
          mp3FileName: audioOldFileName,
        ),
        newFileName: DirUtil.getFileNameWithoutMp3Extension(
          mp3FileName: audioModifiedFileName,
        ),
      );
    }

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();
  }

  /// Method called by the AudioModificationDialog when the user clicks on the
  /// modify button in order to modify the audio title.
  void modifyAudioTitle({
    required Audio audio,
    required String modifiedAudioTitle,
  }) {
    Playlist enclosingPlaylist = audio.enclosingPlaylist!;

    Audio playlistAudio = enclosingPlaylist.playableAudioLst.firstWhere(
      (entry) => entry == audio,
    );

    playlistAudio.validVideoTitle = modifiedAudioTitle;

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
        isHighQuality = playlist.playlistQuality == PlaylistQuality.music;
      }

      // saving the playlist since its isSelected property has been updated
      JsonDataService.saveToFile(
        model: playlist,
        path: playlist.getPlaylistDownloadFilePathName(),
      );
    }
  }

  /// Is not private since it is defined in MockAudioDownloadVM
  void notifyDownloadError({
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

  /// This method handles the case where the Youtube playlist was never
  /// downloaded or the case where the Youtube playlist was deleted or was
  /// renamed and then recreated with the same name, which associates the
  /// application existing playlist to a new url.
  ///
  /// Why would the user delete or rename a Youtube playlist and then recreate
  /// a Youtiube playlist with the same name ? The reason is that the Youtube
  /// playlist may contain too many videos. Removing manually the already
  /// listened videos from the Youtube playlist takes too much time. Instead,
  /// the too big Youtube playlist is deleted or is renamed and a new Youtube
  /// playlist with the same title is created. The new Youtube playlist is then
  /// added to the application, which in this case creates a new playlist and
  /// then integrates to it the data of the replaced playlist.
  Future<Playlist> _addYoutubePlaylistIfNotExist({
    required String playlistUrl,
    required PlaylistQuality playlistQuality,
    required String playlistTitle,
    required String playlistId,
  }) async {
    Playlist addedPlaylist = await _createYoutubePlaylist(
      playlistUrl: playlistUrl,
      playlistQuality: playlistQuality,
      playlistTitle: playlistTitle,
      playlistId: playlistId,
    );

    // checking if current Youtube playlist was deleted and recreated
    // on Youtube.
    //
    // The checking must compare the title of the added (recreated)
    // Youtube playlist with the title of the playlist in the
    // _listOfPlaylist since the added playlist url and id are
    // different from their value in the existing playlist.
    int existingPlaylistIndex = _listOfPlaylist
        .indexWhere((element) => element.title == addedPlaylist.title);

    if (existingPlaylistIndex != -1) {
      // current Youtube playlist was deleted and recreated on Youtube
      // since it is referenced in the _listOfPlaylist and has the same
      // title than the recreated playlist
      Playlist existingPlaylist = _listOfPlaylist[existingPlaylistIndex];

      addedPlaylist.integrateReplacedPlaylistData(
        replacedPlaylist: existingPlaylist,
      );

      _listOfPlaylist[existingPlaylistIndex] = addedPlaylist;
    }

    return addedPlaylist;
  }

  void setAudioQuality({
    required bool isAudioDownloadHighQuality,
  }) {
    isHighQuality = isAudioDownloadHighQuality;

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
  Future<ErrorType> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoTargetPlaylist,
    bool downloadAtMusicQuality = false,
    bool displayWarningIfAudioAlreadyExists = true,
  }) async {
    isHighQuality = downloadAtMusicQuality;
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

      return ErrorType.noInternet;
    } catch (e) {
      warningMessageVM.isSingleVideoUrlInvalid = true;

      return ErrorType.downloadAudioYoutubeError;
    }

    yt.Video youtubeVideo;

    try {
      youtubeVideo = await _youtubeExplode!.videos.get(videoId);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );

      return ErrorType.noInternet;
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return ErrorType.downloadAudioYoutubeError;
    }

    DateTime? videoUploadDate = youtubeVideo.uploadDate;

    videoUploadDate ??= DateTime(00, 1, 1);

    final String compactVideoDescription = _createCompactVideoDescription(
      videoDescription: youtubeVideo.description,
      videoAuthor: youtubeVideo.author,
    );

    final Audio audio = Audio(
      youtubeVideoChannel: youtubeVideo.author,
      enclosingPlaylist: singleVideoTargetPlaylist,
      originalVideoTitle: youtubeVideo.title,
      compactVideoDescription: compactVideoDescription,
      videoUrl: youtubeVideo.url,
      audioDownloadDateTime: DateTime.now(),
      videoUploadDate: videoUploadDate,
      audioDuration: Duration.zero, // will be set by AudioPlayer after
      //                               the download audio file is created
      audioPlaySpeed: _determineNewAudioPlaySpeed(singleVideoTargetPlaylist),
    );

    final List<String> downloadedAudioFileNameLst = DirUtil.listFileNamesInDir(
      directoryPath: singleVideoTargetPlaylist.downloadPath,
      fileExtension: 'mp3',
    );

    String validVideoTitle = audio.validVideoTitle;

    if (validVideoTitle.isNotEmpty) {
      try {
        String existingAudioFileName = downloadedAudioFileNameLst
            .firstWhere((fileName) => fileName.contains(validVideoTitle));
        if (displayWarningIfAudioAlreadyExists) {
          notifyDownloadError(
            errorType: ErrorType.downloadAudioFileAlreadyOnAudioDirectory,
            errorArgOne: audio.validVideoTitle,
            errorArgTwo: existingAudioFileName,
            errorArgThree: singleVideoTargetPlaylist.title,
          );
        }

        return ErrorType.downloadAudioFileAlreadyOnAudioDirectory;
      } catch (_) {
        // file was not found in the downloaded audio directory
      }
    } else {
      warningMessageVM.videoTitleNotWrittenInOccidentalLetters();
    }

    // The Stopwatch class in Dart is used to measure elapsed time.
    Stopwatch stopwatch = Stopwatch()..start();

    if (!_isDownloading) {
      _isDownloading = true;

      notifyListeners();
    }

    try {
      if (!await _downloadAudioFile(
        youtubeVideoId: youtubeVideo.id,
        audio: audio,
      )) {
        // Before this improvement, the failed downloaded audio was
        // added to the target playlist.
        //
        // notifyDownloadError() was called in _downloadAudioFile()
        return ErrorType.downloadAudioYoutubeError;
      }
    } catch (e) {
      _youtubeExplode!.close();
      _youtubeExplode = null;

      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return ErrorType.downloadAudioYoutubeError;
    }

    stopwatch.stop();

    audio.downloadDuration = stopwatch.elapsed;
    _isDownloading = false;
    _youtubeExplode!.close();
    _youtubeExplode = null;

    AudioPlayer audioPlayer = AudioPlayer();

    audio.audioDuration = await getMp3DurationWithAudioPlayer(
      audioPlayer: audioPlayer,
      filePathName: audio.filePathName,
    );

    audioPlayer.dispose();

    singleVideoTargetPlaylist.addDownloadedAudio(audio);

    // fixed bug which caused the playlist including the single
    // video audio to be not saved and so the audio was not
    // displayed in the playlist after restarting the app
    JsonDataService.saveToFile(
      model: singleVideoTargetPlaylist,
      path: singleVideoTargetPlaylist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();

    return ErrorType.noError;
  }

  /// Returns the play speed value to set to the created audio instance.
  double _determineNewAudioPlaySpeed(Playlist currentPlaylist) {
    return (currentPlaylist.audioPlaySpeed != 0)
        ? currentPlaylist.audioPlaySpeed
        : _settingsDataService.get(
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
      warningMessageVM.isNoPlaylistSelectedForSingleVideoDownload();
      return null;
    } else {
      warningMessageVM.isTooManyPlaylistSelectedForSingleVideoDownload = true;
      return null;
    }
  }

  /// This method is called by the PlaylistListVM when the user
  /// selects the "Move audio to playlist" menu item.
  ///
  /// The method physicaly moves the audio file to the target
  /// playlist directory and adds the moved audio data to the target
  /// playlist download audio list and playable audio list.
  ///
  /// The source playlist download list audio data is updated to
  /// reflect that the audio has been moved to the target playlist.
  ///
  /// The source playlist playable audio data is deleted since the
  /// the audio no longer exist in the playlist dir.
  ///
  /// True is returned if the audio file was moved to the target
  /// playlist directory, false otherwise. If the audio file already
  /// exist in the target playlist directory, the move operation does
  /// not happen and false is returned.
  bool moveAudioToPlaylist({
    required Audio audioToMove,
    required Playlist targetPlaylist,
    required bool keepAudioInSourcePlaylistDownloadedAudioLst,
    bool displayWarningIfAudioAlreadyExists = true,
    bool displayWarningWhenAudioWasMoved = true,
  }) {
    Playlist fromPlaylist = audioToMove.enclosingPlaylist!;
    String fromPlaylistTitle = fromPlaylist.title;
    String targetPlaylistTitle = targetPlaylist.title;

    bool wasFileMoved = DirUtil.moveFileToDirectoryIfNotExistSync(
      sourceFilePathName: audioToMove.filePathName,
      targetDirectoryPath: targetPlaylist.downloadPath,
    );

    if (!wasFileMoved) {
      if (displayWarningIfAudioAlreadyExists) {
        // the case if the moved audio file already exist in the target
        // playlist directory or not exist in the source playlist directory
        warningMessageVM.setAudioNotMovedFromToPlaylistTitles(
          movedAudioValidVideoTitle: audioToMove.validVideoTitle,
          movedFromPlaylistTitle: fromPlaylistTitle,
          movedFromPlaylistType: fromPlaylist.playlistType,
          movedToPlaylistTitle: targetPlaylistTitle,
          movedToPlaylistType: targetPlaylist.playlistType,
        );

        return false;
      }

      return false;
    }

    if (keepAudioInSourcePlaylistDownloadedAudioLst) {
      // Keeping audio data in source playlist downloadedAudioLst
      // means that the audio will not be redownloaded if the
      // Download All is applyed to the source playlist. But since
      // the audio is moved to the target playlist, it has to
      // be removed from the source playlist playableAudioLst.
      fromPlaylist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: audioToMove,
      );

      // The moved to playlist title information is set in the
      // the audio in the source playlist downloadedAudioLst.
      fromPlaylist.setMovedAudioToPlaylistTitle(
        movedAudio: audioToMove,
        movedToPlaylistTitle: targetPlaylistTitle,
      );
    } else {
      fromPlaylist.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: audioToMove,
      );
    }

    targetPlaylist.addMovedAudioToDownloadAndPlayableLst(
      movedAudio: audioToMove,
      movedFromPlaylistTitle: fromPlaylistTitle,
    );

    // saving source playlist
    JsonDataService.saveToFile(
      model: fromPlaylist,
      path: fromPlaylist.getPlaylistDownloadFilePathName(),
    );

    // saving target playlist
    JsonDataService.saveToFile(
      model: targetPlaylist,
      path: targetPlaylist.getPlaylistDownloadFilePathName(),
    );

    if (displayWarningWhenAudioWasMoved) {
      warningMessageVM.setAudioMovedFromToPlaylistTitles(
        movedAudioValidVideoTitle: audioToMove.validVideoTitle,
        movedFromPlaylistTitle: fromPlaylistTitle,
        movedFromPlaylistType: fromPlaylist.playlistType,
        movedToPlaylistTitle: targetPlaylistTitle,
        movedToPlaylistType: targetPlaylist.playlistType,
        keepAudioDataInSourcePlaylist:
            keepAudioInSourcePlaylistDownloadedAudioLst,
      );
    }

    return true;
  }

  /// This method is called by the PlaylistListVM when the user
  /// selects the "Copy audio to playlist" menu item.
  ///
  /// The method physicaly copies the audio file to the target
  /// playlist directory and adds the copied audio data to the target
  /// playlist download audio list and playable audio list.
  ///
  /// The source playlist download and playable audio data is also
  /// updated to reflect that the audio has been copied to the target
  /// playlist.
  ///
  /// True is returned if the audio file was copied to the target
  /// playlist directory, false otherwise. If the audio file already
  /// exist in the target playlist directory, the copy does not happen
  /// and false is returned.
  bool copyAudioToPlaylist({
    required Audio audioToCopy,
    required Playlist targetPlaylist,
    bool displayWarningIfAudioAlreadyExists = true,
    bool displayWarningWhenAudioWasCopied = true,
  }) {
    Playlist fromPlaylist = audioToCopy.enclosingPlaylist!;
    String fromPlaylistTitle = fromPlaylist.title;
    String targetPlaylistTitle = targetPlaylist.title;

    bool wasFileCopied = DirUtil.copyFileToDirectorySync(
      sourceFilePathName: audioToCopy.filePathName,
      targetDirectoryPath: targetPlaylist.downloadPath,
    );

    if (!wasFileCopied) {
      if (displayWarningIfAudioAlreadyExists) {
        // the case if the moved audio file already exist in the target
        // playlist directory
        warningMessageVM.setAudioNotCopiedFromToPlaylistTitles(
            copiedAudioValidVideoTitle: audioToCopy.validVideoTitle,
            copiedFromPlaylistTitle: fromPlaylistTitle,
            copiedFromPlaylistType: fromPlaylist.playlistType,
            copiedToPlaylistTitle: targetPlaylistTitle,
            copiedToPlaylistType: targetPlaylist.playlistType);

        return false;
      }

      return false;
    }

    targetPlaylist.addCopiedAudioToDownloadAndPlayableLst(
      copiedAudio: audioToCopy,
      copiedFromPlaylistTitle: fromPlaylistTitle,
    );

    fromPlaylist.setCopiedAudioToPlaylistTitle(
      copiedAudio: audioToCopy,
      copiedToPlaylistTitle: targetPlaylistTitle,
    );

    // saving source playlist
    JsonDataService.saveToFile(
      model: fromPlaylist,
      path: fromPlaylist.getPlaylistDownloadFilePathName(),
    );

    // saving target playlist
    JsonDataService.saveToFile(
      model: targetPlaylist,
      path: targetPlaylist.getPlaylistDownloadFilePathName(),
    );

    if (displayWarningWhenAudioWasCopied) {
      warningMessageVM.setAudioCopiedFromToPlaylistTitles(
          copiedAudioValidVideoTitle: audioToCopy.validVideoTitle,
          copiedFromPlaylistTitle: fromPlaylistTitle,
          copiedFromPlaylistType: fromPlaylist.playlistType,
          copiedToPlaylistTitle: targetPlaylistTitle,
          copiedToPlaylistType: targetPlaylist.playlistType);
    }

    return true;
  }

  /// This method is called by the PlaylistListVM when the user selects the
  /// "Download URLs from text file" playlist menu item. False is returned in case
  /// a download problen happens or if the file already exists in the target
  /// playlist directory.
  ///
  /// {existingAudioFilesNotRedownloadedCount} is the number of audio files
  /// which were not redownloaded since they already exist in the target
  /// playlist directory.
  ///
  /// The way to create a text file containing the video urls obtained from
  /// a Youtube location (not a Youtube playlist) is to execute the following
  /// ChatGPT app: chatgpt_list_video_uploaded.dart.
  Future<int> downloadAudioFromVideoUrlsToPlaylist({
    required Playlist targetPlaylist,
    required List<String> videoUrls,
  }) async {
    int existingAudioFilesNotRedownloadedCount = 0;

    for (String videoUrl in videoUrls) {
      ErrorType errorType = await downloadSingleVideoAudio(
        videoUrl: videoUrl,
        singleVideoTargetPlaylist: targetPlaylist,
        displayWarningIfAudioAlreadyExists: false,
      );

      if (errorType == ErrorType.downloadAudioFileAlreadyOnAudioDirectory) {
        existingAudioFilesNotRedownloadedCount++;
      }
    }

    return existingAudioFilesNotRedownloadedCount;
  }

  /// This method is called when the user selects the "Import audio files ..."
  /// playlist menu item.
  Future<void> importAudioFilesInPlaylist({
    required Playlist targetPlaylist,
    required List<String> filePathNameToImportLst,
  }) async {
    List<String> filePathNameToImportLstCopy = List<String>.from(
        filePathNameToImportLst); // necessary since the filePathNameToImportLst
    //                               may modified
    String rejectedImportedFileNames = '';
    String acceptableImportedFileNames = '';

    for (String filePathName in filePathNameToImportLstCopy) {
      String fileName = filePathName.split(path.separator).last;
      File targetFile =
          File('${targetPlaylist.downloadPath}${path.separator}$fileName');

      if (targetFile.existsSync()) {
        // the case if the imported audio file already exist in the target
        // playlist directory
        rejectedImportedFileNames += "\"$fileName\",\n";
        filePathNameToImportLst.remove(filePathName);

        continue;
      }

      acceptableImportedFileNames += "\"$fileName\",\n";
    }

    // Displaying a warning which lists the audio files which won't be
    // imported to the playlist since they already exist in the playlist
    // directory.
    if (rejectedImportedFileNames.isNotEmpty) {
      warningMessageVM.setAudioNotImportedToPlaylistTitles(
          rejectedImportedAudioFileNames: rejectedImportedFileNames.substring(
              0, rejectedImportedFileNames.length - 2),
          importedToPlaylistTitle: targetPlaylist.title,
          importedToPlaylistType: targetPlaylist.playlistType);
    }

    // Displaying a warning which lists the audio files which will be
    // imported to the playlist.
    if (acceptableImportedFileNames.isNotEmpty) {
      warningMessageVM.setAudioImportedToPlaylistTitles(
          importedAudioFileNames: acceptableImportedFileNames.substring(
              0, acceptableImportedFileNames.length - 2),
          importedToPlaylistTitle: targetPlaylist.title,
          importedToPlaylistType: targetPlaylist.playlistType);
    }

    // AudioPlayer is used to get the audio duration of the
    // imported audio files
    final AudioPlayer? audioPlayer = instanciateAudioPlayer();

    for (String filePathName in filePathNameToImportLst) {
      String fileName = filePathName.split(path.separator).last;
      File sourceFile = File(filePathName);
      String targetFilePathName =
          "${targetPlaylist.downloadPath}${path.separator}$fileName";

      // Physically copying the audio file to the target playlist directory
      sourceFile.copySync(targetFilePathName);

      // Instantiating the imported audio and adding it to the target
      // playlist downloaded audio list and playable audio list.

      Audio importedAudio = await _createImportedAudio(
        targetPlaylist: targetPlaylist,
        audioPlayer: audioPlayer,
        targetFilePathName: targetFilePathName,
        importedFileName: fileName,
      );

      targetPlaylist.addDownloadedAudio(
        importedAudio,
      );

      notifyListeners();
    }

    if (audioPlayer != null) {
      audioPlayer.dispose();
    }

    JsonDataService.saveToFile(
      model: targetPlaylist,
      path: targetPlaylist.getPlaylistDownloadFilePathName(),
    );
  }

  /// This method is redifined in the MockAudioDownloadVM in a version which
  /// returns null. This enable the unit test audio_download_vm_test.dart
  /// to be executed without the need of the AudioPlayer package which is
  /// usable only in integration tests, mot in a unit tests.
  AudioPlayer? instanciateAudioPlayer() {
    return AudioPlayer();
  }

  Future<Audio> _createImportedAudio({
    required Playlist targetPlaylist,
    required AudioPlayer? audioPlayer,
    required String targetFilePathName,
    required String importedFileName,
  }) async {
    Duration? importedAudioDuration = await getMp3DurationWithAudioPlayer(
      audioPlayer: audioPlayer,
      filePathName: targetFilePathName,
    );

    DateTime dateTimeNow = DateTime.now();

    final String audioTitle = importedFileName.replaceFirst('.mp3', '');

    Audio importedAudio = Audio(
      enclosingPlaylist: targetPlaylist,
      originalVideoTitle: audioTitle,
      compactVideoDescription: '',
      videoUrl: '',
      audioDownloadDateTime: dateTimeNow,
      audioDownloadDuration: const Duration(microseconds: 0),
      videoUploadDate: dateTimeNow,
      audioDuration: importedAudioDuration,
      audioPlaySpeed: _determineNewAudioPlaySpeed(targetPlaylist),
    );

    importedAudio.downloadDuration = const Duration(microseconds: 0);
    importedAudio.fileSize = File(targetFilePathName).lengthSync();

    // Since the Audio file name is set in the Audio constructor with
    // adding to it the audio download date time and the video upload
    // date, the constructor audio file name will not correspond to the
    // physical imported audio file name.
    importedAudio.audioFileName = importedFileName;
    importedAudio.isAudioImported = true;

    return importedAudio;
  }

  /// This method is not private since it is redifined in the
  /// MockAudioDownloadVM so that the importAudioFilesInPlaylist()
  /// method can be tested by the unit test.
  Future<Duration> getMp3DurationWithAudioPlayer({
    required AudioPlayer? audioPlayer,
    required String filePathName,
  }) async {
    Duration? duration;

    // Load audio file into audio player
    await audioPlayer!.setSource(DeviceFileSource(filePathName));

    // Get duration
    duration = await audioPlayer.getDuration();

    return duration ?? Duration.zero;
  }

  /// Physically deletes the audio file from the audio playlist
  /// directory and removes the Audio from the playlist playable
  /// audio list.
  ///
  /// The playlist json file is of course updated.
  void deleteAudioPhysicallyAndFromPlayableAudioListOnly({
    required Audio audio,
  }) {
    DirUtil.deleteFileIfExist(pathFileName: audio.filePathName);

    // since the audio mp3 file has been deleted, the audio is no
    // longer in the playlist playable audio list
    Playlist enclosingPlaylist = audio.enclosingPlaylist!;

    enclosingPlaylist.removePlayableAudio(
      playableAudio: audio,
    );

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );
  }

  /// Physically deletes the audio files of the audio contained in the passed
  /// Audio list from the audio playlist directory and removes the Audio from
  /// the playlist playable audio list.
  ///
  /// The playlist json file is of course updated.
  void deleteAudioLstPhysicallyAndFromPlayableAudioLstOnly({
    required List<Audio> audioToDeleteLst,
  }) {
    for (Audio audio in audioToDeleteLst) {
      DirUtil.deleteFileIfExist(pathFileName: audio.filePathName);
    }

    // since the audio mp3 files has been deleted, the audio are no
    // longer in the playlist playable audio list
    Playlist enclosingPlaylist = audioToDeleteLst[0].enclosingPlaylist!;

    enclosingPlaylist.removePlayableAudioLst(
      playableAudioToRemoveLst: audioToDeleteLst,
    );

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );
  }

  /// Physically deletes the audio files of the audio contained in the passed
  /// Audio list from the audio playlist directory and removes the Audio from
  /// the playlist playable audio list.
  ///
  /// The playlist json file is of course updated.
  void deleteAudioLstPhysicallyAndFromDownloadedAndPlayableLst({
    required List<Audio> audioToDeleteLst,
  }) {
    for (Audio audio in audioToDeleteLst) {
      DirUtil.deleteFileIfExist(pathFileName: audio.filePathName);
    }

    // since the audio mp3 files has been deleted, the audio are no
    // longer in the playlist playable audio list
    Playlist enclosingPlaylist = audioToDeleteLst[0].enclosingPlaylist!;

    enclosingPlaylist.removeDownloadedAndPlayableAudioLst(
      audioToRemoveLst: audioToDeleteLst,
    );

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );
  }

  /// User selected the audio menu item "Delete audio from
  /// playlist aswell". This method physically deletes the audio
  /// file from the audio playlist directory as well as deleting
  /// the Audio from the playlist downloaded audio list and from
  /// the playlist playable audio list.
  ///
  /// The playlist json file is of course updated.
  void deleteAudioPhysicallyAndFromAllAudioLists({
    required Audio audio,
  }) {
    DirUtil.deleteFileIfExist(pathFileName: audio.filePathName);

    Playlist? enclosingPlaylist = audio.enclosingPlaylist;

    enclosingPlaylist!.removeDownloadedAudioFromDownloadAndPlayableAudioLst(
      downloadedAudio: audio,
    );

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );

    if (enclosingPlaylist.playlistType == PlaylistType.youtube &&
        !audio.isAudioImported) {
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
  void updatePlaylistJsonFiles({
    bool unselectAddedPlaylist = true,
  }) {
    // Loading again the list of playlists since the list of playlists
    // existing in the application playlist directory may have been
    // manually modified: playlist(s) suppression or playlist(s) addition.
    loadExistingPlaylists();

    // Obtaining the ordered list of playlist titles from the application
    // settings. The ordered list of playlist titles contains the playlists
    // title of the playlists existing before the update.
    List<dynamic> orderedPlaylistTitleLst = _settingsDataService.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ) ??
        [];

    if (unselectAddedPlaylist) {
      // Ensure that the playlist(s) added to the application directory are
      // not selected. Otherwise, more than one playlist may be selected
      // after updating the available list of playlists.
      for (Playlist playlist in _listOfPlaylist) {
        if (!orderedPlaylistTitleLst.contains(playlist.title)) {
          playlist.isSelected = false;
        }
      }
    }

    // Creating a copy of the private list of playlists is necessary since
    // the private list of playlists may be modified - playlist suppression -
    // during the iteration over the private list of playlists.
    List<Playlist> listOfPlaylistCopy = List<Playlist>.from(_listOfPlaylist);

    for (Playlist playlistCopy in listOfPlaylistCopy) {
      bool isPlaylistDownloadPathUpdated = false;
      Playlist correspondingOriginalPlaylist =
          _listOfPlaylist.firstWhere((element) => element == playlistCopy);

      String playlistCopyDownloadHomePath =
          path.dirname(playlistCopy.downloadPath);

      if (playlistCopyDownloadHomePath != _playlistsRootPath) {
        // The case if the playlist dir obtained from another AudioLearn
        // app playlist root dir was copied on the app playlist root dir.
        // Then, the playlist download path in the json file must be updated
        // to correspond to the app playlist root dir.
        //
        // Example:
        //
        // Copying /storage/emulated/0/Download/audiolearn/playlists/math
        // directory containing the math playlist json file as well as its
        // audio files to C:\Users\Jean-Pierre\Documents\audio dir will
        // replace /storage/emulated/0/Download/audiolearn/playlists/math
        // playlist download path by C:\Users\Jean-Pierre\Documents\audio\math
        // playlist download path in the playlist json file.
        correspondingOriginalPlaylist.downloadPath =
            _playlistsRootPath + path.separator + playlistCopy.title;
        isPlaylistDownloadPathUpdated = true;
      }

      if (!Directory(playlistCopy.downloadPath).existsSync()) {
        // The case if the playlist dir has been deleted by the user
        // or by another app. In this case, the playlist is removed
        // from the list of playlists.
        _listOfPlaylist.remove(playlistCopy);
        continue;
      }

      // Remove the audio from the playable audio list which are no
      // longer in the playlist directory
      int removedPlayableAudioNumber =
          correspondingOriginalPlaylist.updatePlayableAudioLst();

      if (isPlaylistDownloadPathUpdated || removedPlayableAudioNumber > 0) {
        JsonDataService.saveToFile(
          model: playlistCopy,
          path: playlistCopy.getPlaylistDownloadFilePathName(),
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

    if (playlistQuality == PlaylistQuality.music) {
      playlist.audioPlaySpeed = 1.0;
    } else {
      playlist.audioPlaySpeed = _settingsDataService.get(
        settingType: SettingType.playlists,
        settingSubType: Playlists.playSpeed,
      );
    }

    _listOfPlaylist.add(playlist);

    return await setPlaylistPath(
      playlistTitle: playlistTitle,
      playlist: playlist,
    );
  }

  /// Private method defined as public since it is used by the mock
  /// audio download VM.
  Future<Playlist> setPlaylistPath({
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

  /// Downloads the audio file from the Youtube video and saves it
  /// to the enclosing playlist directory. Returns true if the audio
  /// file was successfully downloaded, false otherwise.
  Future<bool> _downloadAudioFile({
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

      return false;
    }

    final yt.AudioOnlyStreamInfo audioStreamInfo;

    if (isHighQuality) {
      audioStreamInfo = streamManifest.audioOnly.withHighestBitrate();
      audio.setAudioToMusicQuality();
    } else {
      audioStreamInfo = streamManifest.audioOnly.reduce(
          (a, b) => a.bitrate.bitsPerSecond < b.bitrate.bitsPerSecond ? a : b);
    }

    final int audioFileSize = audioStreamInfo.size.totalBytes;
    audio.audioFileSize = audioFileSize;

    await _youtubeDownloadAudioFile(
      audio,
      audioStreamInfo,
      audioFileSize,
    );

    return true;
  }

  /// Downloads the audio file from the Youtube video and saves it
  /// to the enclosing playlist directory.
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
        _updateDownloadProgress(
          progress: totalBytesDownloaded / audioFileSize,
          lastSecondDownloadSpeed:
              totalBytesDownloaded - previousSecondBytesDownloaded,
        );
        previousSecondBytesDownloaded = totalBytesDownloaded;
        lastUpdate = DateTime.now();
      }
    });

    await for (var byteChunk in audioStream) {
      totalBytesDownloaded += byteChunk.length;

      // Check if the deadline has been exceeded before updating the
      // progress
      if (DateTime.now().difference(lastUpdate) >= updateInterval) {
        _updateDownloadProgress(
            progress: totalBytesDownloaded / audioFileSize,
            lastSecondDownloadSpeed:
                totalBytesDownloaded - previousSecondBytesDownloaded);
        previousSecondBytesDownloaded = totalBytesDownloaded;
        lastUpdate = DateTime.now();
      }

      audioFileSink.add(byteChunk);
    }

    // Make sure to update the progress one last time to 100% before
    // finishing
    _updateDownloadProgress(
      progress: 1.0,
      lastSecondDownloadSpeed: 0,
    );

    // Annulez le Timer pour éviter les appels inutiles
    timer.cancel();

    await audioFileSink.flush();
    await audioFileSink.close();
  }

  void _updateDownloadProgress({
    required double progress,
    required int lastSecondDownloadSpeed,
  }) {
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
