// audio_download_vm.dart
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:audiolearn/constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

// importing youtube_explode_dart as yt enables to name the app
// Model playlist class as Playlist so it does not conflict with
// youtube_explode_dart Playlist class name.
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

// NEW: FFmpegKit fork (mobile) — conversion on Android/iOS
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';

import '../models/text_to_mp3_audio_file.dart';
import '../models/comment.dart';
import '../services/settings_data_service.dart';
import '../services/json_data_service.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/dir_util.dart';
import 'comment_vm.dart';
import 'picture_vm.dart';
import 'warning_message_vm.dart';

// global variables used by the AudioDownloadVM in order
// to avoid multiple downloads of the same playlist
List<String> downloadingPlaylistUrls = [];

/// FFmpeg facade (platform-aware). Convert input audio (m4a/webm/…) to MP3 (CBR) using
/// libmp3lame.
///
/// Mobile (Android/iOS): uses FFmpegKit; Desktop: uses system ffmpeg.
/// The [bitrate], [sampleRate] and [channels] parameters allow using
/// a “music profile” (high quality stereo) or a “speech profile”
/// (lower bitrate mono) depending on the caller needs.
class _FfmpegFacade {
  static Future<bool> convertToMp3({
    required String inputPath,
    required String outputPath,
    String bitrate = '192k',
    int sampleRate = 44100,
    int channels = 2,
  }) async {
    final args = [
      '-y',
      '-i',
      inputPath,
      '-vn',
      '-ar',
      sampleRate.toString(),
      '-ac',
      channels.toString(),
      '-c:a',
      'libmp3lame',
      '-b:a',
      bitrate,
      outputPath,
    ];

    if (_isMobile) {
      final cmd = args.map(_q).join(' ');
      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();
      return ReturnCode.isSuccess(rc);
    } else {
      try {
        final ProcessResult result = await Process.run('ffmpeg', args);
        return result.exitCode == 0;
      } catch (_) {
        return false;
      }
    }
  }

  static bool get _isMobile => Platform.isAndroid || Platform.isIOS;

  static String _q(String s) => s.contains(' ') ? '"$s"' : s;
}

/// Container for audio attributes.
class AudioAttributes {
  /// Audio bitrate in bits per second (e.g. 128000) or null if unknown.
  final int? bitrateBps;

  /// Sample rate in Hz (e.g. 44100) or null if unknown.
  final int? sampleRate;

  /// Number of audio channels (1 = mono, 2 = stereo) or null if unknown.
  final int? channels;

  /// Duration in seconds or null if unknown.
  final double? durationSeconds;

  const AudioAttributes({
    this.bitrateBps,
    this.sampleRate,
    this.channels,
    this.durationSeconds,
  });
}

/// This VM (View Model) class is part of the MVVM architecture.
/// It was posted on Github on 12-04-2023.
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

  // used when updating the playlists root path using the
  // playlist download view left appbar 'Application Settings ...'
  // menu item.
  set playlistsRootPath(String playlistsRootPath) =>
      _playlistsRootPath = playlistsRootPath;

  // While the audio is downloading, the download progression is
  // displayed on the playlist download view.

  bool _isAudioDownloading = false;
  bool get isAudioDownloading => _isAudioDownloading;

  double _audioDownloadProgress = 0.0;
  double get audioDownloadProgress => _audioDownloadProgress;

  int _lastSecondAudioDownloadSpeed = 0;
  int get lastSecondAudioDownloadSpeed => _lastSecondAudioDownloadSpeed;

  late Audio _currentDownloadingAudio;
  Audio get currentDownloadingAudio => _currentDownloadingAudio;

  // After the audio was downloaded, it must be converted to MP3.
  // This takes time and so the conversion progression is displayed
  // on the playlist download view.
  bool _isDownloadedAudioConvertingToMp3 = false;
  bool get isDownloadedAudioConvertingToMp3 =>
      _isDownloadedAudioConvertingToMp3;

  // If a mp4 is imported, it must be converted to MP3. This
  // takes time and so the conversion progression is displayed
  // on the playlist download view.
  bool _isImportedMp4ConvertingToMp3 = false;
  bool get isImportedMp4ConvertingToMp3 => _isImportedMp4ConvertingToMp3;

  String _mp4ConvertingToMp3FileName = '';
  String get mp4ConvertingToMp3FileName => _mp4ConvertingToMp3FileName;

  bool isHighQuality = false;

  bool _stopDownloadPressed = false;
  bool get isDownloadStopping => _stopDownloadPressed;

  // setter used by MockAudioDownloadVM in integration test only !
  set isDownloadStopping(bool isDownloadStopping) =>
      _stopDownloadPressed = isDownloadStopping;

  bool _audioDownloadError = false;
  bool get audioDownloadError => _audioDownloadError;

  final WarningMessageVM warningMessageVM;
  final SettingsDataService _settingsDataService;

  /// {settingsDataService} determine that in test mode the windows
  /// test directory is used as playlist root directory. This
  /// directory is located in the test directory of the project.
  ///
  /// Otherwise, the windows or smartphone audio root directory
  /// is used.
  AudioDownloadVM({
    required this.warningMessageVM,
    required SettingsDataService settingsDataService,
  }) : _settingsDataService = settingsDataService {
    _playlistsRootPath = _settingsDataService.get(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath);

    loadExistingPlaylists();
  }

  /// This method is used by ConvertTextToAudioDialog in order to update the
  /// playlist download view playlist audio list so that the audio added by
  /// the text to speech conversion is immediately visible in its playlist.
  ///
  /// This method is necessary since the AudioDownloadVM.importAudioFilesInPlaylist
  /// method does not call notifyListeners() if the audio files are imported
  /// from text to speech conversion.
  void doNotifyListeners() {
    notifyListeners();
  }

  /// [restoringPlaylistsCommentsAndSettingsJsonFilesFromZip] is true if the
  /// method is called in order to restore the playlists, comments and settings
  /// json files from a zip file. In this case, the playlists root path is
  /// updated if necessary.
  void loadExistingPlaylists({
    List<Playlist> initialListOfPlaylist = const [],
    bool restoringPlaylistsCommentsAndSettingsJsonFilesFromZip = false,
  }) {
    // reinitializing the list of playlist is necessary since
    // loadExistingPlaylists() is also called by PlaylistListVM.
    // updateSettingsAndPlaylistJsonFiles() method.
    _listOfPlaylist = [];

    List<String> playlistPathFileNamesLst = DirUtil.getPlaylistPathFileNamesLst(
      baseDir: _playlistsRootPath,
    );

    bool arePlaylistsRestoredFromAndroidToWindows = false;
    bool arePlaylistsRestoredFromWindowsToAndroid = false;
    String playlistWindowsDownloadRootPath = '';

    try {
      for (String playlistPathFileName in playlistPathFileNamesLst) {
        if (playlistPathFileName.contains(kPictureAudioMapFileName)) {
          // This file is not a playlist json file and so must be
          // ignored.
          // The second condition fix a problem happening in case the
          // playlists are in dir audio or dir audiolearn ((not in
          // playlists dir) and kPictureAudioMapFileName exist in
          // audio\pictures dir or audiolearn/picture dir.
          continue;
        }

        Playlist currentPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: playlistPathFileName,
          type: Playlist,
        );

        if (restoringPlaylistsCommentsAndSettingsJsonFilesFromZip) {
          if (!arePlaylistsRestoredFromAndroidToWindows) {
            // If arePlaylistsRestoredFromAndroidToWindows is false,
            // then the playlists root path is the same as the one
            // used on Android. The playlists root path must be
            // updated only if the playlists are restored from Android
            // to Windows.
            arePlaylistsRestoredFromAndroidToWindows = _playlistsRootPath
                    .contains('C:\\') &&
                currentPlaylist.downloadPath.contains('/storage/emulated/0');

            arePlaylistsRestoredFromWindowsToAndroid =
                _playlistsRootPath.contains('/storage/emulated/0') &&
                    currentPlaylist.downloadPath.contains('C:\\');

            if (arePlaylistsRestoredFromAndroidToWindows) {
              // This test avoids that the playlists root path is
              // determined for each playlist since the playlists
              // root path is the same for all playlists restored
              // from Android.
              List<String> playlistRootPathElementsLst =
                  currentPlaylist.downloadPath.split('/');

              // This name may have been changed by the user on Android
              // using the 'Application Settings ...' menu.
              String androidAppPlaylistDirName = playlistRootPathElementsLst[
                  playlistRootPathElementsLst.length - 2];

              _playlistsRootPath =
                  "$kApplicationPathWindowsTest${path.separator}$androidAppPlaylistDirName";
              _settingsDataService.set(
                  settingType: SettingType.dataLocation,
                  settingSubType: DataLocation.playlistRootPath,
                  value: _playlistsRootPath);

              _settingsDataService.saveSettings();

              playlistWindowsDownloadRootPath =
                  "$_playlistsRootPath${path.separator}";
            }
          }

          _updatePlaylistRootPathIfNecessary(
            playlist: currentPlaylist,
            isPlaylistRestoredFromAndroidToWindows:
                arePlaylistsRestoredFromAndroidToWindows,
            isPlaylistRestoredFromWindowsToAndroid:
                arePlaylistsRestoredFromWindowsToAndroid,
            playlistWindowsDownloadRootPath: playlistWindowsDownloadRootPath,
          );

          _renameExistingPlaylistAudioAndCommentAndPictureFilesIfNecessary(
            initialListOfPlaylist: initialListOfPlaylist,
            restoredPlaylist: currentPlaylist,
          );
        }

        _listOfPlaylist.add(currentPlaylist);

        // if the playlist is selected, the audio quality checkbox will be
        // checked or not according to the selected playlist quality
        updatePlaylistAudioQuality(playlist: currentPlaylist);
      }
    } catch (e) {
      warningMessageVM.setError(
        errorType: ErrorType.errorInPlaylistJsonFile,
        errorArgOne: e.toString(),
      );
      notifyListeners();
    }
  }

  /// This method is called when the user change a playlist audio quality
  /// as well when the application is launched.
  void updatePlaylistAudioQuality({
    required Playlist playlist,
  }) {
    if (playlist.isSelected) {
      isHighQuality = playlist.playlistQuality == PlaylistQuality.music;

      // Necessary in order to update the playlist quality
      // checkbox in the playlist download view.
      notifyListeners();
    }
  }

  /// This is the case if the playlist restored from the zip file corresponds to
  /// a playlist which was recreated with redownloading same or all its videos.
  ///
  /// This method checks if the playlist directory contains audio files whose name
  /// contains the audio title. If yes, the file is renamed to the original file
  /// name. So, the file will be playable and will correspond to a restored existing
  /// comment.
  void _renameExistingPlaylistAudioAndCommentAndPictureFilesIfNecessary({
    required List<Playlist> initialListOfPlaylist,
    required Playlist restoredPlaylist,
  }) {
    Playlist? initialPlaylist = initialListOfPlaylist.firstWhereOrNull(
      (playlist) => playlist.id == restoredPlaylist.id,
    );
    String playlistDownloadPath = restoredPlaylist.downloadPath;
    List<String> audioFilePathNameLst = DirUtil.listPathFileNamesInDir(
      directoryPath: playlistDownloadPath,
      fileExtension: 'mp3',
    );

    if (audioFilePathNameLst.isEmpty) {
      // In this case, the redownloaded playlist was not created before
      // the redownload and so has no audio files to rename.
      return;
    }

    final RegExp regex = RegExp(
      r'^\d{6}-\d{6}-(.+?)\s+\d{2}-\d{2}-\d{2}\.mp3$',
      caseSensitive: false,
    );

    for (String audioToRenameFilePathName in audioFilePathNameLst) {
      String audioToRenameFileName =
          audioToRenameFilePathName.split(Platform.pathSeparator).last;

      final match = regex.firstMatch(audioToRenameFileName);
      String audioTitleInAudioToRenameFileName = '';

      if (match != null && match.groupCount >= 1) {
        // Extract the title part
        audioTitleInAudioToRenameFileName = match.group(1)!;
      }

      Audio? audio;

      if (audioTitleInAudioToRenameFileName != '') {
        audio = restoredPlaylist.playableAudioLst.firstWhereOrNull(
          (audio) => audio.validVideoTitle == audioTitleInAudioToRenameFileName,
        );
      }

      if (audio != null) {
        String originalAudioFileName = audio.audioFileName;
        if (audioToRenameFileName == originalAudioFileName) {
          // This is the case if the audio file has not been
          // redownloaded before the playlist was restored from
          // the zip file.
          continue;
        }

        // Renaming the existing audio file to the original audio
        // file name.
        DirUtil.renameFile(
          fileToRenameFilePathName: audioToRenameFilePathName,
          newFileName: originalAudioFileName,
        );

        // Renaming the existing comment file to the original comment
        // file name
        final String commentToRenameFilePathName =
            CommentVM.buildCommentFilePathName(
          playlistDownloadPath: playlistDownloadPath,
          audioFileName: audioToRenameFileName,
        );
        final String originalCommentFileName =
            originalAudioFileName.replaceAll('mp3', 'json');

        DirUtil.renameFile(
          fileToRenameFilePathName: commentToRenameFilePathName,
          newFileName: originalCommentFileName,
        );

        // Renaming the existing picture file to the original picture
        // file name
        final String playlistPicturePath =
            "$playlistDownloadPath${path.separator}$kPictureDirName";
        final String pictureToRenameFileName =
            audioToRenameFileName.replaceAll('.mp3', '.jpg');
        final String originalPictureFileName =
            audio.audioFileName.replaceAll('.mp3', '.jpg');
        final String pictureToRenameFilePathName =
            "$playlistPicturePath${path.separator}$pictureToRenameFileName";

        DirUtil.renameFile(
          fileToRenameFilePathName: pictureToRenameFilePathName,
          newFileName: originalPictureFileName,
        );
      } else if (initialPlaylist != null) {
        // The case if the audio file does not correspond to an audio
        // file of the restored playlist. This is the case if the user
        // has downloaded an audio before restoring the playlist from
        // the zip file. In this case, the Audio contained in the initial
        // playlist which corresponds to the audio file is added to the
        // restored playlist.
        Audio? audio = initialPlaylist.playableAudioLst.firstWhereOrNull(
          (audio) => audio.validVideoTitle == audioTitleInAudioToRenameFileName,
        );
        if (audio != null) {
          restoredPlaylist.addDownloadedAudio(audio);
          JsonDataService.saveToFile(
            path: restoredPlaylist.getPlaylistDownloadFilePathName(),
            model: restoredPlaylist,
          );
        }
      }
    }
  }

  /// This method is only called in the situation of restoring from
  /// a zip file.
  void _updatePlaylistRootPathIfNecessary({
    required Playlist playlist,
    required bool isPlaylistRestoredFromAndroidToWindows,
    required bool isPlaylistRestoredFromWindowsToAndroid,
    required String playlistWindowsDownloadRootPath,
  }) {
    if (isPlaylistRestoredFromAndroidToWindows) {
      if (playlist.downloadPath.contains(kPlaylistDownloadRootPath)) {
        playlist.downloadPath = playlist.downloadPath
            .replaceFirst(
              "$kPlaylistDownloadRootPath/",
              playlistWindowsDownloadRootPath,
            )
            .trim(); // trim() is necessary since the path is used in
        //              the JsonDataService.saveToFile constructor and
        //              the path must not contain any trailing spaces
        //              on Windows or Android.
      }
    } else if (isPlaylistRestoredFromWindowsToAndroid) {
      if (playlist.downloadPath.contains(kApplicationPathWindowsTest)) {
        playlist.downloadPath = playlist.downloadPath
            .replaceFirst(
              kApplicationPathWindowsTest,
              kApplicationPath,
            )
            .replaceAll('\\', '/')
            .trim(); // trim() is necessary since the path is used in
        //              the JsonDataService.saveToFile constructor and
        //              the path must not contain any trailing spaces
        //              on Windows or Android.
      } else {
        playlist.downloadPath = playlist.downloadPath
            .trim(); // trim() is necessary since the path is used in
        //              the JsonDataService.saveToFile constructor and
        //              the path must not contain any trailing spaces
        //              on Windows or Android.
      }
    }

    JsonDataService.saveToFile(
      model: playlist,
      path: playlist.getPlaylistDownloadFilePathName(),
    );
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
    _listOfPlaylist.removeWhere((playlist) => playlist == playlistToDelete);

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

    // Will contain the Youtube playlist title which will have to be
    // corrected
    String youtubePlaylistTitleToCorrect = '';

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

      if (playlistTitle.contains('/') ||
          playlistTitle.contains(':') ||
          playlistTitle.contains('\\')) {
        // The case if the Youtube playlist title contains a '/'
        // character. This character is used to separate the
        // directories in a path and so can not be used in a
        // playlist title. For this reason, '/' is replaced by
        // '-' in the playlist title.
        youtubePlaylistTitleToCorrect = playlistTitle;
        playlistTitle = playlistTitle.replaceAll('/', '-');
        playlistTitle = playlistTitle.replaceAll(':', '-');
        playlistTitle = playlistTitle.replaceAll('\\', '-');
      }

      int playlistIndex = _listOfPlaylist
          .indexWhere((playlist) => playlist.title == playlistTitle);

      if (playlistIndex != -1) {
        // This means that the playlist was not added, but
        // that its url was updated. The case when a new
        // playlist with the same title is created in order
        // to replace the old one which contains too many
        // videos.
        Playlist updatedPlaylist = _updateYoutubePlaylisrUrl(
          playlistIndex: playlistIndex,
          playlistId: playlistId,
          playlistUrl: playlistUrl,
          playlistTitle: playlistTitle,
        );
        // since the updated playlist is returned. Since its title
        // is not new, it will not be added to the orderedTitleLst
        // in the SettingsDataService json file, which would cause
        // a bug when filtering audio's of a playlist
        return updatedPlaylist;
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

    if (youtubePlaylistTitleToCorrect.isEmpty) {
      warningMessageVM.annoncePlaylistAddition(
        playlistTitle: addedPlaylist.title,
        playlistQuality: playlistQuality,
        playlistType: PlaylistType.youtube,
      );
    } else {
      warningMessageVM.signalCorrectedYoutubePlaylistTitle(
        originalPlaylistTitle: youtubePlaylistTitleToCorrect,
        playlistQuality: playlistQuality,
        correctedPlaylistTitle: addedPlaylist.title,
      );
    }

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
  ///
  /// The updated playlist is returned by the method.
  Playlist _updateYoutubePlaylisrUrl({
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

    return updatedPlaylist;
  }

  /// Downloads all audios of a YouTube playlist (skips already-downloaded).
  Future<void> downloadPlaylistAudio({
    required String playlistUrl,
  }) async {
    if (downloadingPlaylistUrls.contains(playlistUrl)) {
      // if the playlist is already being downloaded, then
      // the method is not executed. This avoids that the
      // audio of the playlist are downloaded multiple times
      // if the user clicks multiple times on the download
      // playlist text button.
      return;
    } else {
      // If another playlist is being downloaded, then the
      // the previously added playlist url is removed from the
      // downloadingPlaylistUrls list. This will enable the user
      // to restart downloading the previously added playlist.
      downloadingPlaylistUrls = [];
      downloadingPlaylistUrls.add(playlistUrl);
    }

    _stopDownloadPressed = false;
    _youtubeExplode ??= yt.YoutubeExplode();

    // get the YouTube playlist
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
      // is empty !
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
        if (_isAudioDownloading) {
          _isAudioDownloading = false;
          notifyListeners();
        }
        continue;
      }

      if (_stopDownloadPressed) break;

      // Download the audio file
      Stopwatch stopwatch = Stopwatch()..start();

      if (!_isAudioDownloading) {
        _isAudioDownloading = true;

        // This avoid that when downloading a next audio file, the displayed
        // download progress starts at 100 % !
        _audioDownloadProgress = 0.0;
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
        final ok = await _downloadAudioFile(
          youtubeVideoId: youtubeVideo.id,
          audio: audio,
        );
        if (!ok) {
          // notifyDownloadError already done in _downloadAudioFile
          continue;
        }
      } catch (e) {
        notifyDownloadError(
          errorType: ErrorType.downloadAudioYoutubeError,
          errorArgOne: e.toString(),
          errorArgTwo: youtubeVideoTitle,
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

    _isAudioDownloading = false;
    _youtubeExplode!.close();
    _youtubeExplode = null;

    // removing the playlist url from the downloadingPlaylistUrls
    // list since the playlist download has finished
    downloadingPlaylistUrls.remove(playlistUrl);
    notifyListeners();
  }

  /// Rename the passed audio file as well as the associated comment file
  /// if it exists and the associated picture file if it exists.
  void renameAudioFile({
    required Audio audio,
    required String audioModifiedFileName,
  }) {
    final Audio audioBeforeFileRename = audio.copy();

    if (!audioModifiedFileName.endsWith('.mp3')) {
      // adding the .mp3 extension if the user did not add it
      audioModifiedFileName = '$audioModifiedFileName.mp3';
    }

    String audioOldFileName = audio.audioFileName;
    String playlistDownloadPath = audio.enclosingPlaylist!.downloadPath;

    if (audioOldFileName == audioModifiedFileName) {
      // the case if the user clicked on modify button without
      // having modified the audio file name
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

    // building the new comment file path name

    final String newCommentFilePathName = CommentVM.buildCommentFilePathName(
      playlistDownloadPath: playlistDownloadPath,
      audioFileName: audioModifiedFileName,
    );

    final String newCommentFileName =
        newCommentFilePathName.split(Platform.pathSeparator).last;
    final String audioModifiedFileNameWithoutMp3Extension =
        DirUtil.getFileNameWithoutMp3Extension(
      mp3FileName: audioModifiedFileName,
    );

    // Verifying if the new comment file name is already used
    if (File(newCommentFilePathName).existsSync()) {
      warningMessageVM.renameCommentFileNameIsAlreadyUsed(
        invalidRenameFileName: audioModifiedFileNameWithoutMp3Extension,
      );

      return;
    }

    PictureVM pictureVM = PictureVM(
      settingsDataService: _settingsDataService,
    );

    // building the new picture file path name

    final String newPictureFilePathName = pictureVM.buildPictureFilePathName(
      playlistDownloadPath: playlistDownloadPath,
      audioFileName: audioModifiedFileName,
    );

    final String newPictureFileName =
        newPictureFilePathName.split(Platform.pathSeparator).last;

    // Verifying if the new picture file name is already used
    if (File(newPictureFilePathName).existsSync()) {
      warningMessageVM.renamePictureFileNameIsAlreadyUsed(
        invalidRenameFileName: audioModifiedFileNameWithoutMp3Extension,
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

    enclosingPlaylist.renameDownloadedAndPlayableAudioFile(
      oldFileName: audioOldFileName,
      newFileName: audioModifiedFileName,
    );

    bool isCommentFileRenamed = false;
    bool isPictureFileRenamed = false;

    // renaming the comment file if it exists

    final String oldCommentFilePathName = CommentVM.buildCommentFilePathName(
      playlistDownloadPath: playlistDownloadPath,
      audioFileName: audioOldFileName,
    );

    if (File(oldCommentFilePathName).existsSync()) {
      DirUtil.renameFile(
        fileToRenameFilePathName: oldCommentFilePathName,
        newFileName: newCommentFileName,
      );

      isCommentFileRenamed = true;
    }

    // renaming the picture file if it exists

    final String oldPictureFilePathName = pictureVM.buildPictureFilePathName(
      playlistDownloadPath: playlistDownloadPath,
      audioFileName: audioOldFileName,
    );

    final String oldFileNameWithoutMp3Extension =
        DirUtil.getFileNameWithoutMp3Extension(
      mp3FileName: audioOldFileName,
    );
    final String newFileNameWithoutMp3Extension =
        DirUtil.getFileNameWithoutMp3Extension(
      mp3FileName: audioModifiedFileName,
    );

    if (File(oldPictureFilePathName).existsSync()) {
      pictureVM.applyPictureFileRenamedToAppPictureAudioMap(
        audioBeforeFileRename: audioBeforeFileRename,
        audioOldFileNameWithoutExtension: oldFileNameWithoutMp3Extension,
        audioModifiedFileNameWithoutExtension: newFileNameWithoutMp3Extension,
      );

      DirUtil.renameFile(
        fileToRenameFilePathName: oldPictureFilePathName,
        newFileName: newPictureFileName,
      );

      isPictureFileRenamed = true;
    }

    if (isCommentFileRenamed || isPictureFileRenamed) {
      // Displaying a warning message to confirm that the
      // audio file as well as the comment and/or picture
      // files were renamed
      warningMessageVM.confirmRenameAudioAndAssociatedFiles(
        oldFileName: oldFileNameWithoutMp3Extension,
        newFileName: newFileNameWithoutMp3Extension,
        isCommentFileRenamed: isCommentFileRenamed,
        isPictureFileRenamed: isPictureFileRenamed,
      );
    } else {
      // Displaying a warning message to confirm that the
      // audio file was renamed
      warningMessageVM.confirmRenameAudioFile(
        oldFileName: oldFileNameWithoutMp3Extension,
        newFileName: newFileNameWithoutMp3Extension,
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

      if (isPlaylistSelected) {
        // if the playlist is selected, the audio quality checkbox will be
        // checked or not according to the selected playlist quality
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
    _isAudioDownloading = false;
    _audioDownloadProgress = 0.0;
    _lastSecondAudioDownloadSpeed = 0;
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
  /// is added to a playlist, then ErrorType.noError is returned.
  Future<ErrorType> downloadSingleVideoAudio({
    required Playlist singleVideoTargetPlaylist,
    required String videoUrl,
    bool downloadAtMusicQuality = false,
    bool displayWarningIfAudioAlreadyExists = true,
  }) async {
    isHighQuality = downloadAtMusicQuality;
    _audioDownloadError = false;
    _stopDownloadPressed = false;
    _youtubeExplode ??= yt.YoutubeExplode();

    // emptying the downloadingPlaylistUrls list will enable the
    // user to download the previously downloaded playlist
    downloadingPlaylistUrls = [];

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

    if (!_isAudioDownloading) {
      _isAudioDownloading = true;
      notifyListeners();
    }

    try {
      final ok = await _downloadAudioFile(
        youtubeVideoId: youtubeVideo.id,
        audio: audio,
      );

      if (!ok) {
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
        errorArgTwo: youtubeVideo.title,
      );

      return ErrorType.downloadAudioYoutubeError;
    }

    stopwatch.stop();

    audio.downloadDuration = stopwatch.elapsed;
    _isAudioDownloading = false;
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

  /// This method is based on the downloadSingleVideoAudio() method.
  ///
  /// If the audio which is already in its enclosing playlist is correctly
  /// redownloaded, then ErrorType.noError is returned.
  ///
  /// Is not private since it is redefined by the MockAudioDownloadVM.
  Future<ErrorType> redownloadSingleVideoAudio({
    bool displayWarningIfAudioAlreadyExists = false,
  }) async {
    isHighQuality = _currentDownloadingAudio.isAudioMusicQuality;
    _audioDownloadError = false;
    _stopDownloadPressed = false;
    _youtubeExplode ??= yt.YoutubeExplode();

    final yt.VideoId videoId;

    try {
      videoId = yt.VideoId(_currentDownloadingAudio.videoUrl);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
        errorArgTwo: _currentDownloadingAudio.originalVideoTitle,
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
        errorArgTwo: _currentDownloadingAudio.originalVideoTitle,
      );
      return ErrorType.downloadAudioYoutubeError;
    }

    // The Stopwatch class in Dart is used to measure elapsed time.
    Stopwatch stopwatch = Stopwatch()..start();

    if (!_isAudioDownloading) {
      _isAudioDownloading = true;
      notifyListeners();
    }

    try {
      // the _currentDownloadingAudio which is passed below to the
      // _downloadAudioFile() method was set in the AudioDownloadVM.
      // redownloadPlaylistFilteredAudio() method which calls this
      // method.
      final ok = await _downloadAudioFile(
        youtubeVideoId: youtubeVideo.id,
        audio: _currentDownloadingAudio,
        redownloading: true,
      );
      if (!ok) {
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
        errorArgTwo: _currentDownloadingAudio.originalVideoTitle,
      );

      return ErrorType.downloadAudioYoutubeError;
    }

    stopwatch.stop();

    _isAudioDownloading = false;
    _youtubeExplode!.close();
    _youtubeExplode = null;

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
  /// not happen and false is returned. Same happens if the audio file
  /// does not exist in the source playlist directory.
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

    CopyOrMoveFileResult moveFileResult =
        DirUtil.moveFileToDirectoryIfNotExistSync(
      sourceFilePathName: audioToMove.filePathName,
      targetDirectoryPath: targetPlaylist.downloadPath,
    );

    if (moveFileResult == CopyOrMoveFileResult.targetFileAlreadyExists) {
      if (displayWarningIfAudioAlreadyExists) {
        // the case if the moved audio file already exist in the target
        // playlist directory or not exist in the source playlist directory
        warningMessageVM.audioCopiedOrMovedFromToPlaylist(
            audioValidVideoTitle: audioToMove.validVideoTitle,
            wasOperationSuccessful: false,
            isAudioCopied: false,
            fromPlaylistTitle: fromPlaylistTitle,
            fromPlaylistType: fromPlaylist.playlistType,
            toPlaylistTitle: targetPlaylistTitle,
            toPlaylistType: targetPlaylist.playlistType,
            copyOrMoveFileResult: moveFileResult);
        return false;
      }
      return false;
    } else if (moveFileResult == CopyOrMoveFileResult.sourceFileNotExist) {
      // the case if the moved audio file does not exist in the source
      // playlist directory
      warningMessageVM.audioCopiedOrMovedFromToPlaylist(
          audioValidVideoTitle: audioToMove.validVideoTitle,
          wasOperationSuccessful: false,
          isAudioCopied: false,
          fromPlaylistTitle: fromPlaylistTitle,
          fromPlaylistType: fromPlaylist.playlistType,
          toPlaylistTitle: targetPlaylistTitle,
          toPlaylistType: targetPlaylist.playlistType,
          copyOrMoveFileResult: moveFileResult);
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
      fromPlaylist.removeAudioFromDownloadAndPlayableAudioLst(
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
      if (!keepAudioInSourcePlaylistDownloadedAudioLst &&
          fromPlaylist.playlistType == PlaylistType.youtube &&
          audioToMove.audioType == AudioType.downloaded) {
        warningMessageVM.audioCopiedOrMovedFromToPlaylist(
          audioValidVideoTitle: audioToMove.validVideoTitle,
          wasOperationSuccessful: true,
          isAudioCopied: false,
          fromPlaylistTitle: fromPlaylistTitle,
          fromPlaylistType: fromPlaylist.playlistType,
          toPlaylistTitle: targetPlaylistTitle,
          toPlaylistType: targetPlaylist.playlistType,
          copyOrMoveFileResult:
              CopyOrMoveFileResult.audioNotKeptInSourcePlaylist,
        );
      } else {
        warningMessageVM.audioCopiedOrMovedFromToPlaylist(
          audioValidVideoTitle: audioToMove.validVideoTitle,
          wasOperationSuccessful: true,
          isAudioCopied: false,
          fromPlaylistTitle: fromPlaylistTitle,
          fromPlaylistType: fromPlaylist.playlistType,
          toPlaylistTitle: targetPlaylistTitle,
          toPlaylistType: targetPlaylist.playlistType,
          copyOrMoveFileResult: CopyOrMoveFileResult.copiedOrMoved,
        );
      }
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

    CopyOrMoveFileResult copyFileResult = DirUtil.copyFileToDirectorySync(
      sourceFilePathName: audioToCopy.filePathName,
      targetDirectoryPath: targetPlaylist.downloadPath,
    );

    if (copyFileResult == CopyOrMoveFileResult.targetFileAlreadyExists) {
      if (displayWarningIfAudioAlreadyExists) {
        // the case if the copied audio file already exist in the target
        // playlist directory
        warningMessageVM.audioCopiedOrMovedFromToPlaylist(
            audioValidVideoTitle: audioToCopy.validVideoTitle,
            wasOperationSuccessful: false,
            isAudioCopied: true,
            fromPlaylistTitle: fromPlaylistTitle,
            fromPlaylistType: fromPlaylist.playlistType,
            toPlaylistTitle: targetPlaylistTitle,
            toPlaylistType: targetPlaylist.playlistType,
            copyOrMoveFileResult: copyFileResult);
        return false;
      }
      return false;
    } else if (copyFileResult == CopyOrMoveFileResult.sourceFileNotExist) {
      // the case if the copied audio file does not exist in the source
      // playlist directory
      warningMessageVM.audioCopiedOrMovedFromToPlaylist(
          audioValidVideoTitle: audioToCopy.validVideoTitle,
          wasOperationSuccessful: false,
          isAudioCopied: true,
          fromPlaylistTitle: fromPlaylistTitle,
          fromPlaylistType: fromPlaylist.playlistType,
          toPlaylistTitle: targetPlaylistTitle,
          toPlaylistType: targetPlaylist.playlistType,
          copyOrMoveFileResult: copyFileResult);
      return false;
    }

    targetPlaylist.addCopiedAudioToDownloadAndPlayableLst(
      audioToCopy: audioToCopy,
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
      warningMessageVM.audioCopiedOrMovedFromToPlaylist(
        audioValidVideoTitle: audioToCopy.validVideoTitle,
        wasOperationSuccessful: true,
        isAudioCopied: true,
        fromPlaylistTitle: fromPlaylistTitle,
        fromPlaylistType: fromPlaylist.playlistType,
        toPlaylistTitle: targetPlaylistTitle,
        toPlaylistType: targetPlaylist.playlistType,
        copyOrMoveFileResult: CopyOrMoveFileResult.copiedOrMoved,
      );
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
    required List<String> videoUrlsLst,
    required bool downloadAtMusicQuality,
  }) async {
    int existingAudioFilesNotRedownloadedCount = 0;

    for (String videoUrl in videoUrlsLst) {
      ErrorType errorType = await downloadSingleVideoAudio(
        singleVideoTargetPlaylist: targetPlaylist,
        videoUrl: videoUrl,
        displayWarningIfAudioAlreadyExists: false,
        downloadAtMusicQuality: downloadAtMusicQuality,
      );

      if (errorType == ErrorType.downloadAudioFileAlreadyOnAudioDirectory) {
        existingAudioFilesNotRedownloadedCount++;
      }
    }

    return existingAudioFilesNotRedownloadedCount;
  }

  /// This method is called by the PlaylistListVM when the user executes the playlist
  /// submenu 'Redownload filtered Audio's' after having selected (and defined)
  /// a named Sort/Filter parameters. The mrthod is also called when the user
  /// executes the audio list item menu 'Redownload deleted Audio' or the audio
  /// player view left appbar menu of the same name.
  ///
  /// The returned List dynamic contains the number of audio files which were not
  /// redownloaded since they already exist in the target playlist directory. If
  /// internet is not accessible or another youtube download error happened, the
  /// second element of the list is the ErrorType.
  Future<List<dynamic>> redownloadPlaylistFilteredAudio({
    required Playlist targetPlaylist,
    required List<Audio> filteredAudioToRedownload,
  }) async {
    _stopDownloadPressed = false;
    int existingAudioFilesNotRedownloadedCount = 0;
    final List<String> downloadedAudioFileNameLst = DirUtil.listFileNamesInDir(
      directoryPath: targetPlaylist.downloadPath,
      fileExtension: 'mp3',
    );

    for (Audio audio in filteredAudioToRedownload) {
      if (downloadedAudioFileNameLst
          .any((fileName) => fileName == audio.audioFileName)) {
        existingAudioFilesNotRedownloadedCount++;
        continue;
      }

      if (_stopDownloadPressed) break;

      _currentDownloadingAudio = audio;

      // This avoid that when downloading a next audio file, the displayed
      // download progress starts at 100 % !
      _audioDownloadProgress = 0.0;
      notifyListeners();

      ErrorType errorType = await redownloadSingleVideoAudio();

      if (errorType == ErrorType.downloadAudioFileAlreadyOnAudioDirectory) {
        existingAudioFilesNotRedownloadedCount++;
      } else if (errorType != ErrorType.noError) {
        return [
          existingAudioFilesNotRedownloadedCount,
          errorType,
        ];
      }
    }

    return [
      existingAudioFilesNotRedownloadedCount,
    ];
  }

  /// This method is called when the user selects the "Import Audio Files ..."
  /// playlist menu item. In this case, a filepicker dialog is displayed
  /// which allows the user to select one or everal audio files to import.
  Future<void> importAudioFilesInPlaylist({
    required Playlist targetPlaylist,
    required List<String> filePathNameToImportLst,
  }) async {
    List<String> filePathNameToImportLstCopy =
        List<String>.from(filePathNameToImportLst); // necessary since the
    //                                                 filePathNameToImportLst
    //                                                 may be modified
    String rejectedImportedFileNamesLst = '';
    String acceptableImportedFileNames = '';
    bool isImportedMp4ConvertedToMp3InMusicQuality = false;

    for (String filePathName in filePathNameToImportLstCopy) {
      String fileName = filePathName.split(path.separator).last;
      String targetMp4ToMp3FileName = '';

      if (fileName.toLowerCase().endsWith('.mp4')) {
        File tmpMp4File = File(filePathName);
        targetMp4ToMp3FileName = fileName.replaceFirst('mp4', 'mp3');
        File targetMp4ToMp3File = File(
            '${targetPlaylist.downloadPath}${path.separator}$targetMp4ToMp3FileName');

        if (targetMp4ToMp3File.existsSync()) {
          // the case if the imported audio file already exist in the target
          // playlist directory
          rejectedImportedFileNamesLst += "\"$targetMp4ToMp3FileName\",\n";
          filePathNameToImportLst.remove(filePathName);
          continue;
        }

        _mp4ConvertingToMp3FileName = fileName;
        _isImportedMp4ConvertingToMp3 = true;
        notifyListeners();

        // 1) get attributes (bitrate, sampleRate, channels)
        final attrs = await _getAudioAttributesWithFfprobe(
          filePath: tmpMp4File.path,
        );

        // 2) choose target bitrate (kbps string)
        final int? sourceBps = attrs?.bitrateBps;
        final int chosenKbps = _chooseTargetKbpsFromSourceBps(
          sourceBps: sourceBps,
        );
        final String targetBitrate = '${chosenKbps}k';

        // 3) choose sampleRate and channels if not known
        final int finalSampleRate = 44100;

        final finalChannels = _chooseChannels(
          sourceChannels: attrs?.channels,
          chosenKbps: chosenKbps,
        );

        isImportedMp4ConvertedToMp3InMusicQuality = _isMusicQuality(
          bitrate: targetBitrate,
          channels: finalChannels,
        );

        // 4) convert
        final bool ok = await _FfmpegFacade.convertToMp3(
          inputPath: tmpMp4File.path,
          outputPath: targetMp4ToMp3File.path,
          bitrate: targetBitrate,
          sampleRate: finalSampleRate,
          channels: finalChannels,
        );

        _isImportedMp4ConvertingToMp3 = false;
        notifyListeners();

        if (!ok) {
          notifyDownloadError(
            errorType: ErrorType.importingMp4Error,
            errorArgOne: 'FFmpeg conversion failed',
            errorArgTwo: fileName,
          );

          return;
        }

        acceptableImportedFileNames += "\"$targetMp4ToMp3FileName\",\n";
      } else {
        File targetFile =
            File('${targetPlaylist.downloadPath}${path.separator}$fileName');

        if (targetFile.existsSync()) {
          // the case if the imported audio file already exist in the target
          // playlist directory
          rejectedImportedFileNamesLst += "\"$fileName\",\n";
          filePathNameToImportLst.remove(filePathName);
          continue;
        }

        acceptableImportedFileNames += "\"$fileName\",\n";
      }
    }

    // Displaying a warning which lists the audio files which won't be
    // imported to the playlist since they already exist in the playlist
    // directory.
    if (rejectedImportedFileNamesLst.isNotEmpty) {
      warningMessageVM.setAudioNotImportedToPlaylistTitles(
          rejectedImportedAudioFileNames:
              rejectedImportedFileNamesLst.substring(
                  0,
                  rejectedImportedFileNamesLst.length -
                      2), // removing the last comma
          //                                               and the last line break
          importedToPlaylistTitle: targetPlaylist.title,
          importedToPlaylistType: targetPlaylist.playlistType);
    }

    // Displaying a confirmation which lists the audio files which will be
    // imported to the playlist.
    if (acceptableImportedFileNames.isNotEmpty) {
      warningMessageVM.setAudioImportedToPlaylistTitles(
          importedAudioFileNames: acceptableImportedFileNames.substring(
              0,
              acceptableImportedFileNames.length -
                  2), // removing the last comma and the last line break
          importedToPlaylistTitle: targetPlaylist.title,
          importedToPlaylistType: targetPlaylist.playlistType);
    }

    // AudioPlayer is used to get the audio duration of the
    // imported audio files
    final AudioPlayer? audioPlayer = instanciateAudioPlayer();

    for (String filePathName in filePathNameToImportLst) {
      // Now, the filePathNameToImportLst does not contain the audio
      // files which already exist in the target playlist directory !

      // Physically copying the audio file to the target playlist
      // directory. If the audio file already exist in the
      // target playlist directory due to the fact it was created
      // from the text to speech operation, the copy must not be
      // executed, otherwise _createImportedAudio will fail.
      String fileName = filePathName.split(path.separator).last;
      String targetFilePathName =
          "${targetPlaylist.downloadPath}${path.separator}$fileName";

      Audio? existingAudio;

      if (!fileName.endsWith('.mp4')) {
        // the case if the audio file was not converted from mp4 to mp3
        File(filePathName).copySync(targetFilePathName);

        existingAudio = targetPlaylist.getAudioByFileNameNoExt(
          audioFileNameNoExt: fileName.replaceFirst('.mp3', ''),
        );
      } else {
        existingAudio = targetPlaylist.getAudioByFileNameNoExt(
          audioFileNameNoExt: fileName.replaceFirst('.mp4', ''),
        );
      }

      // Instantiating the imported audio and adding it to the target
      // playlist downloaded audio list and playable audio list.

      if (existingAudio == null) {
        String mp3FileName = fileName.replaceFirst('mp4', 'mp3');
        Audio importedAudio = await _createImportedAudio(
          targetPlaylist: targetPlaylist,
          audioPlayer: audioPlayer,
          targetFilePathName: (targetFilePathName.contains('mp4'))
              ? '${targetPlaylist.downloadPath}${path.separator}$mp3FileName'
              : targetFilePathName,
          importedFileName:
              (targetFilePathName.contains('mp4')) ? mp3FileName : fileName,
        );

        importedAudio.isAudioMusicQuality =
            isImportedMp4ConvertedToMp3InMusicQuality;

        targetPlaylist.addImportedAudio(
          importedAudio,
        );
      } else {
        Duration? importedAudioDuration = await getMp3DurationWithAudioPlayer(
          audioPlayer: audioPlayer,
          filePathName: targetFilePathName,
        );

        existingAudio.audioDuration = importedAudioDuration;
        existingAudio.fileSize = File(targetFilePathName).lengthSync();
      }

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

  /// This method is called when the user wish to add the extracted audio
  /// to an existing playlist.
  Future<void> addExtractedAudioFileToPlaylist({
    required Audio currentAudio,
    required Playlist targetPlaylist,
    required String filePathNameToAdd,
    required bool inMusicQuality,
    required double totalDuration,
  }) async {
    String fileName = filePathNameToAdd.split(path.separator).last;

    // Physically copying the extracted audio file to the target
    // playlist directory.
    String targetFilePathName =
        "${targetPlaylist.downloadPath}${path.separator}$fileName";

    // Instantiating the extracted audio and adding it to the target
    // playlist downloaded audio list and playable audio list.
    Audio extractedAudio = await _createExtractedAudio(
      currentAudio: currentAudio,
      targetPlaylist: targetPlaylist,
      totalDuration: totalDuration,
      targetFilePathName: targetFilePathName,
      extractedFileName: fileName,
    );

    extractedAudio.isAudioMusicQuality = inMusicQuality;

    targetPlaylist.addImportedAudio(
      extractedAudio,
    );

    CommentVM commentVM = CommentVM();
    PictureVM pictureVM = PictureVM(
      settingsDataService: _settingsDataService,
    );

    // Copying the audio comment file if it exists
    commentVM.copyAudioCommentFileToTargetPlaylist(
      audio: currentAudio,
      targetPlaylistPath: targetPlaylist.downloadPath,
    );

    // Copying the audio picture file if it exists
    pictureVM.copyAudioPictureJsonFileToTargetPlaylist(
      audio: currentAudio,
      targetPlaylist: targetPlaylist,
    );

    notifyListeners();

    JsonDataService.saveToFile(
      model: targetPlaylist,
      path: targetPlaylist.getPlaylistDownloadFilePathName(),
    );
  }

  /// Returns audio attributes extracted via ffprobe (desktop) or FFprobeKit (mobile).
  /// Returns null on fatal error.
  Future<AudioAttributes?> _getAudioAttributesWithFfprobe({
    required String filePath,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      // Desktop (Windows/Linux/macOS) -> call external ffprobe binary
      if (!Platform.isAndroid && !Platform.isIOS) {
        final result = await Process.run('ffprobe', [
          '-v',
          'error',
          '-select_streams',
          'a:0',
          '-show_entries',
          'stream=bit_rate,sample_rate,channels,duration',
          '-of',
          'json',
          filePath,
        ]).timeout(timeout);

        if (result.exitCode != 0) {
          return null;
        }

        final Map jsonMap = jsonDecode(result.stdout as String) as Map;
        final List<dynamic> streams =
            (jsonMap['streams'] as List<dynamic>?) ?? [];

        if (streams.isEmpty) {
          return null;
        }

        final stream = streams.first as Map<String, dynamic>;

        final int? bitRate = stream['bit_rate'] != null
            ? int.tryParse(stream['bit_rate'].toString())
            : null;

        final int? sampleRate = stream['sample_rate'] != null
            ? int.tryParse(stream['sample_rate'].toString())
            : null;

        final int? channels = stream['channels'] != null
            ? int.tryParse(stream['channels'].toString())
            : null;

        // duration may be within stream or top-level format
        final String? durationStr = stream['duration']?.toString() ??
            jsonMap['format']?['duration']?.toString();
        final double? duration =
            durationStr != null ? double.tryParse(durationStr) : null;

        // fallback: if bitrate unknown but duration available, estimate from file size
        int? finalBitrate = bitRate;

        if ((finalBitrate == null || finalBitrate == 0) &&
            duration != null &&
            duration > 0) {
          final file = File(filePath);
          final size = await file.length();
          finalBitrate = ((size * 8) / duration).round();
        }

        return AudioAttributes(
          bitrateBps: finalBitrate,
          sampleRate: sampleRate,
          channels: channels,
          durationSeconds: duration,
        );
      }

      // Mobile (Android/iOS): use FFprobeKit async API
      final Completer completer = Completer<AudioAttributes?>();
      final Timer timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      FFprobeKit.getMediaInformationAsync(
        filePath,
        (session) async {
          try {
            final mediaInfo = (session).getMediaInformation();

            if (mediaInfo == null) {
              if (!completer.isCompleted) {
                completer.complete(null);
              }

              return;
            }

            final List<dynamic> streams = mediaInfo.getStreams();
            Map<String, dynamic>? audioStream;

            if (streams.isNotEmpty) {
              for (final s in streams) {
                try {
                  final map = Map<String, dynamic>.from(s as Map);

                  if ((map['codec_type']?.toString() ?? '') == 'audio') {
                    audioStream = map;
                    break;
                  }
                } catch (_) {
                  // ignore malformed stream
                }
              }
            }

            int? bitRate =
                audioStream != null && audioStream.containsKey('bit_rate')
                    ? int.tryParse(audioStream['bit_rate'].toString())
                    : null;

            final int? sampleRate =
                audioStream != null && audioStream.containsKey('sample_rate')
                    ? int.tryParse(audioStream['sample_rate'].toString())
                    : null;

            final int? channels =
                audioStream != null && audioStream.containsKey('channels')
                    ? int.tryParse(audioStream['channels'].toString())
                    : null;

            // fallback for duration
            final String? durationStr = mediaInfo.getDuration();
            final double? duration =
                durationStr != null ? double.tryParse(durationStr) : null;

            // fallback: estimate bitrate from file size and duration if needed
            if ((bitRate == null || bitRate == 0) &&
                duration != null &&
                duration > 0) {
              final file = File(filePath);
              final size = await file.length();
              bitRate = ((size * 8) / duration).round();
            }

            if (!completer.isCompleted) {
              completer.complete(AudioAttributes(
                bitrateBps: bitRate,
                sampleRate: sampleRate,
                channels: channels,
                durationSeconds: duration,
              ));
            }
          } catch (_) {
            if (!completer.isCompleted) completer.complete(null);
          } finally {
            timer.cancel();
          }
        },
      );

      final attrs = await completer.future;
      return attrs;
    } catch (e) {
      return null;
    }
  }

  /// Choose the target kbps given the source bitrate in bits/s.
  /// Conservative policy: do not increase quality above source.
  /// Returns integer kbps (e.g. 128).
  int _chooseTargetKbpsFromSourceBps({
    required int? sourceBps,
    int defaultKbps = 128,
  }) {
    if (sourceBps == null || sourceBps <= 0) {
      return defaultKbps;
    }

    final int srcKbps = (sourceBps / 1000).round();

    if (srcKbps <= 96) return 64;
    if (srcKbps <= 128) return 128;
    if (srcKbps <= 192) return 192;
    if (srcKbps <= 256) return 256;

    return 320; // allow higher for high-bitrate sources
  }

  /// Converts "128k" into 128.
  /// Returns null if the string is malformed.
  bool _isMusicQuality({
    required String bitrate,
    required int channels,
  }) {
    final cleaned = bitrate.trim().toLowerCase().replaceAll('k', '');
    int? kNumber = int.tryParse(cleaned);

    if (kNumber == null) {
      return false;
    } else {
      return kNumber >= 128 && channels >= 2;
    }
  }

  /// Decide channels to use for encoding.
  /// If sourceChannels provided, reuse it. Otherwise pick mono for very low kbps, stereo otherwise.
  int _chooseChannels({
    int? sourceChannels,
    required int chosenKbps,
  }) {
    if (sourceChannels != null && sourceChannels > 0) {
      return sourceChannels;
    }

    if (chosenKbps <= 64) {
      return 1; // mono for low bitrate targets
    }

    return 2; // stereo otherwise
  }

  /// The method is called  when the user selects the "Convert Text to
  /// Audio ..." playlist menu item. After the text was converted to audio,
  /// the audio file is imported to the target playlist. In this case,
  /// {doesImportedFileResultFromTextToSpeech} is set to true.
  Future<void> importConvertedAudioFileInPlaylist({
    required CommentVM commentVMlistenFalse,
    required Playlist targetPlaylist,
    required TextToMp3AudioFile currentAudioFile,
    required String commentTitle,
    required bool wasConvertedAudioAdded,
  }) async {
    String filePathNameToImportStr = currentAudioFile.filePath;
    String fileName = filePathNameToImportStr.split(path.separator).last;

    // Displaying a confirmation of the converted text to audio file imported
    // in the playlist.
    warningMessageVM.setAudioCreatedFromTextToSpeechOperation(
      convertedAudioFileName: '"$fileName"',
      targetPlaylistTitle: targetPlaylist.title,
      targetPlaylistType: targetPlaylist.playlistType,
      wasConvertedAudioAdded: wasConvertedAudioAdded,
    );

    // AudioPlayer is used to get the audio duration of  the
    // imported audio files
    final AudioPlayer? audioPlayer = instanciateAudioPlayer();

    // The case if the imported audio file was created from the text to
    // speech operation. If the MP3 file already existed in the target
    // playlist directory, it was replaced by the new created MP3 file
    // and the corresponding Audio is modified. The Audio creation date
    // time is not modified in order to avoid to modify the order of
    // playing the audio if their order depends of the default SF parms.
    Duration? importedAudioDuration = await getMp3DurationWithAudioPlayer(
      audioPlayer: audioPlayer,
      filePathName: filePathNameToImportStr,
    );

    Audio? existingAudio = targetPlaylist.getAudioByFileNameNoExt(
      audioFileNameNoExt: fileName.replaceFirst('.mp3', ''),
    );

    if (existingAudio == null) {
      Audio importedAudio = await _createImportedAudio(
        targetPlaylist: targetPlaylist,
        audioPlayer: audioPlayer,
        targetFilePathName: filePathNameToImportStr,
        importedFileName: fileName,
      );

      importedAudio.audioType = AudioType.textToSpeech;

      targetPlaylist.addImportedAudio(
        importedAudio,
      );

      existingAudio = importedAudio;
    } else {
      existingAudio.audioDuration = importedAudioDuration;
      existingAudio.fileSize = File(filePathNameToImportStr).lengthSync();

      // Usefull if you replace an existing audio by a text to speech
      // generated audio file.
      existingAudio.audioType = AudioType.textToSpeech;
    }

    if (audioPlayer != null) {
      audioPlayer.dispose();
    }

    commentVMlistenFalse.addComment(
      addedComment: Comment(
        title: commentTitle,
        content: currentAudioFile.text,
        commentStartPositionInTenthOfSeconds: 0,
        commentEndPositionInTenthOfSeconds:
            existingAudio.audioDuration.inMilliseconds ~/ 100,
      ),
      audioToComment: existingAudio,
    );

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
    importedAudio.audioType = AudioType.imported;

    return importedAudio;
  }

  Future<Audio> _createExtractedAudio({
    required Audio currentAudio,
    required Playlist targetPlaylist,
    required double totalDuration,
    required String targetFilePathName,
    required String extractedFileName,
  }) async {
    Duration importedAudioDuration =
        Duration(milliseconds: (totalDuration * 1000).round());
    DateTime dateTimeNow = DateTime.now();
    final String audioTitle = extractedFileName.replaceFirst('.mp3', '');

    Audio extractedAudio = Audio(
      enclosingPlaylist: targetPlaylist,
      originalVideoTitle: audioTitle,
      compactVideoDescription: '',
      videoUrl: currentAudio.videoUrl,
      audioDownloadDateTime: dateTimeNow,
      audioDownloadDuration: const Duration(microseconds: 0),
      videoUploadDate: dateTimeNow,
      audioDuration: importedAudioDuration,
      audioPlaySpeed: _determineNewAudioPlaySpeed(targetPlaylist),
    );

    extractedAudio.downloadDuration = const Duration(microseconds: 0);
    extractedAudio.fileSize = File(targetFilePathName).lengthSync();
    extractedAudio.validVideoTitle = _cleanAudioFileName(
      fileName: audioTitle,
    );

    // Since the Audio file name is set in the Audio constructor with
    // adding to it the audio download date time and the video upload
    // date, the constructor audio file name will not correspond to the
    // physical extracted audio file name.
    extractedAudio.audioFileName = extractedFileName;
    extractedAudio.audioType = AudioType.extracted;
    extractedAudio.extractedFromPlaylistTitle = currentAudio.enclosingPlaylist!.title;

    return extractedAudio;
  }

  String _cleanAudioFileName({
    required String fileName,
  }) {
    return fileName
        // Remove leading timestamp: yymmdd-hhmmss-
        .replaceFirst(RegExp(r'^\d{6}-\d{6}-'), '')
        // Remove trailing date: yy-mm-dd
        .replaceFirst(RegExp(r'\s\d{2}-\d{2}-\d{2}$'), '')
        .trim();
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

    duration = await audioPlayer.getDuration();
    return duration ?? Duration.zero;
  }

  /// This method is return a list containing
  /// [
  ///   0 - the audio mp3 duration
  ///   1 - the audio mp3 file size in bytes
  /// ]
  Future<List<dynamic>> getAudioMp3DurationAndSize({
    required ArchiveFile audioMp3ArchiveFile,
    required String playlistDownloadPath,
  }) async {
    // AudioPlayer is used to get the audio duration of the
    // imported audio files
    final AudioPlayer? audioPlayer = instanciateAudioPlayer();
    try {
      // Create a temporary file from the ArchiveFile data
      final Directory tempDir = Directory(_settingsDataService.get(
          settingType: SettingType.dataLocation,
          settingSubType: DataLocation.playlistRootPath));

      // Use path.basename to extract filename cross-platform
      final String tempFileName = path.basename(audioMp3ArchiveFile.name);

      // Use path.join for cross-platform path joining
      final File tempFile = File(path.join(tempDir.path, tempFileName));

      // Write the archive file content to the temporary file
      await tempFile.writeAsBytes(audioMp3ArchiveFile.content as List<int>);

      // Get the duration using the temporary file path
      Duration audioMp3Duration = await getMp3DurationWithAudioPlayer(
        audioPlayer: audioPlayer,
        filePathName: tempFile.path,
      );

      int fileSize = await tempFile.length();

      // Clean up the temporary file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return [
        audioMp3Duration,
        fileSize,
      ];
    } catch (e) {
      // Handle any errors during file operations
      return [
        Duration.zero,
        0,
      ];
    }
  }

  /// Physically deletes the audio file from the audio playlist
  /// directory and removes the Audio from the playlist playable
  /// audio list. The deleted audio's remain in the downloaded
  /// audio list.
  ///
  /// The playlist json file is of course updated.
  void deleteAudioPhysicallyAndFromPlayableAudioListOnly({
    required Audio audio,
  }) {
    DirUtil.deleteFileIfExist(pathFileName: audio.filePathName);

    // Since the audio mp3 file has been deleted, the audio is no
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

    enclosingPlaylist.removeAudioLstFromPlayableAudioLstOnly(
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

    // Since the audio mp3 files has been deleted, the audio are no
    // longer in the playlist playable audio list

    Playlist enclosingPlaylist = audioToDeleteLst[0].enclosingPlaylist!;

    enclosingPlaylist.removeAudioLstFromDownloadedAndPlayableAudioLsts(
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

    enclosingPlaylist!.removeAudioFromDownloadAndPlayableAudioLst(
      downloadedAudio: audio,
    );

    JsonDataService.saveToFile(
      model: enclosingPlaylist,
      path: enclosingPlaylist.getPlaylistDownloadFilePathName(),
    );
  }

  /// Method called by PlaylistListVM when the user selects the update playlist
  /// JSON files menu item.
  ///
  /// The method is also called when the user selects the 'Restore Playlist, Comments
  /// and Settings from Zip File' menu item of the playlist download view left
  /// appbar leading popup menu. This executes the PlaylistListVM method
  /// restorePlaylistsCommentsAndSettingsJsonFilesFromZip() which calls this method.
  /// In this case, [restoringPlaylistsCommentsAndSettingsJsonFilesFromZip] is set
  /// to true.
  void updatePlaylistJsonFiles({
    bool unselectAddedPlaylist = true,
    required updatePlaylistPlayableAudioList,
    bool restoringPlaylistsCommentsAndSettingsJsonFilesFromZip = false,
  }) {
    List<Playlist> initialListOfPlaylistCopy = [];

    if (restoringPlaylistsCommentsAndSettingsJsonFilesFromZip) {
      // The case if the user selects the 'Restore Playlist, Comments
      // and Settings from Zip File' menu item of the playlist download
      // view left appbar leading popup menu. In this case, the list
      // of playlists is restored from the zip file. It can happen that
      // a playlist existing before restoring it from the zip file
      // contained Audio's which were downloaded before the restoration.
      // In this case, those Audio's will have to be added to the
      // restored playlist
      initialListOfPlaylistCopy =
          _listOfPlaylist.map((Playlist playlist) => playlist.copy()).toList();
    }

    // Loading again the list of playlists since the list of playlists
    // existing in the application playlist directory may have been
    // manually modified: playlist(s) suppression or playlist(s) addition.
    loadExistingPlaylists(
      initialListOfPlaylist: initialListOfPlaylistCopy,
      restoringPlaylistsCommentsAndSettingsJsonFilesFromZip:
          restoringPlaylistsCommentsAndSettingsJsonFilesFromZip,
    );

    // Obtaining the ordered list of playlist titles from the application
    // settings. The ordered list of playlist titles contains the playlists
    // title of the playlists existing before the update or after the restore.
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
      int removedPlayableAudioNumber = 0;

      if (updatePlaylistPlayableAudioList) {
        removedPlayableAudioNumber =
            correspondingOriginalPlaylist.updatePlayableAudioLst();
      }

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

    // Extraire les noms propres qui ne se trouvent pas dans les 3
    // premières lignes
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
        i++; // Pour ne pas prendre en compte les noms propres suivants qui font déjà
        //      partie d'une paire consécutive
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
    // Expression régulière pour identifier les lignes de texte de
    // la vidéo formatées comme les timestamps
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

  /// Prefer M4A (AAC) then best audioOnly
  /// Get manifest with mobile clients and simple retries (handles recent YT changes).
  Future<yt.StreamManifest> _getManifestWithClients(yt.VideoId id) async {
    const maxAttempts = 3;
    int attempt = 0;
    late yt.StreamManifest manifest;
    while (true) {
      attempt++;
      try {
        manifest = await _youtubeExplode!.videos.streams.getManifest(
          id,
          ytClients: [yt.YoutubeApiClient.ios, yt.YoutubeApiClient.androidVr],
        );
        return manifest;
      } catch (e) {
        if (attempt >= maxAttempts) rethrow;
        await Future.delayed(Duration(milliseconds: 400 * attempt));
      }
    }
  }

  /// Prefer M4A (AAC) then best audioOnly; choose highest/lowest bitrate per quality.
  Future<yt.AudioOnlyStreamInfo> _pickBestAudioStream({
    required yt.StreamManifest manifest,
    required bool highQuality,
  }) async {
    final audioOnly = manifest.audioOnly;

    // Try M4A first (easier to handle)
    final m4a = audioOnly.where((s) => s.container.name.toLowerCase() == 'm4a');
    yt.AudioOnlyStreamInfo chosen;

    if (m4a.isNotEmpty) {
      chosen = highQuality
          ? m4a.withHighestBitrate()
          : _withLowestBitrate(m4a); // Reduces quantity of downloaded data
    } else {
      chosen = highQuality
          ? audioOnly.withHighestBitrate()
          : _withLowestBitrate(
              audioOnly); // Reduces quantity of downloaded data
    }
    return chosen;
  }

  // Improving reduction of downloaded data quantity for low quality audio
  yt.AudioOnlyStreamInfo _withLowestBitrate(
      Iterable<yt.AudioOnlyStreamInfo> list) {
    return list.reduce(
        (a, b) => a.bitrate.bitsPerSecond < b.bitrate.bitsPerSecond ? a : b);
  }

  /// Download stream to a temp file with progress; then transcode to MP3.
  Future<bool> _downloadAudioFile({
    required yt.VideoId youtubeVideoId,
    required Audio audio,
    bool redownloading = false,
  }) async {
    if (!redownloading) {
      _currentDownloadingAudio = audio;
    }

    yt.StreamManifest manifest;
    try {
      manifest = await _getManifestWithClients(youtubeVideoId);
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
        errorArgTwo: audio.originalVideoTitle,
      );
      downloadingPlaylistUrls = []; // reset guard
      return false;
    }

    final yt.AudioOnlyStreamInfo streamInfo = await _pickBestAudioStream(
      manifest: manifest,
      highQuality: isHighQuality,
    );

    // Temp file for container (m4a/webm)
    final String tmpExt = streamInfo.container.name; // "m4a" or "webm"
    final String tmpPath = path.join(
      audio.enclosingPlaylist!.downloadPath,
      '${audio.validVideoTitle}.$tmpExt',
    );
    final File tmpFile = File(tmpPath);

    // Final MP3 destination (Audio.audioFileName points to .mp3)
    final String mp3Path = audio.filePathName;
    final File mp3File = File(mp3Path);

    // Source size (container)
    final int srcTotalBytes = streamInfo.size.totalBytes;
    if (!redownloading) {
      audio.audioFileSize =
          srcTotalBytes; // provisional; will be replaced by MP3 size
    }

    try {
      await _downloadToFileWithProgress(
        stream: _youtubeExplode!.videos.streams.get(streamInfo),
        targetFile: tmpFile,
        totalSizeBytes: srcTotalBytes,
      );
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
        errorArgTwo: audio.originalVideoTitle,
      );
      return false;
    }

    // Transcode to MP3
    final bool useMusicQuality = isHighQuality;

    final String targetBitrate = useMusicQuality ? '192k' : '64k';
    final int sampleRate = 44100;
    final int channels = useMusicQuality ? 2 : 1;

    _isAudioDownloading = false;
    _isDownloadedAudioConvertingToMp3 = true;
    notifyListeners();

    final ok = await _FfmpegFacade.convertToMp3(
      inputPath: tmpFile.path,
      outputPath: mp3File.path,
      bitrate: targetBitrate,
      sampleRate: sampleRate,
      channels: channels,
    );

    _isDownloadedAudioConvertingToMp3 = false;
    notifyListeners();

    // Cleanup temp
    try {
      if (await tmpFile.exists()) await tmpFile.delete();
    } catch (_) {}

    if (!ok) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: 'FFmpeg conversion failed',
        errorArgTwo: audio.originalVideoTitle,
      );
      return false;
    }

    // Overwrite with the final MP3 size
    try {
      audio.audioFileSize = await mp3File.length();
    } catch (_) {}

    // Mark quality if needed
    if (!redownloading && isHighQuality) {
      audio.setAudioToMusicQuality();
    }

    return true;
  }

  /// Downloads the audio file from the Youtube video and saves it
  /// to the enclosing playlist directory. UUsing generic downloader
  /// with 1s progress ticks, writing to a file.
  Future<void> _downloadToFileWithProgress({
    required Stream<List<int>> stream,
    required File targetFile,
    required int totalSizeBytes,
  }) async {
    final IOSink sink = targetFile.openWrite();
    int total = 0;
    int prevSecond = 0;

    // reset progress
    _audioDownloadProgress = 0.0;
    notifyListeners();

    final Duration tick = const Duration(seconds: 1);
    DateTime last = DateTime.now();
    final timer = Timer.periodic(tick, (_) {
      _audioDownloadProgress = total / totalSizeBytes;
      _lastSecondAudioDownloadSpeed = total - prevSecond;
      prevSecond = total;
      if (_isAudioDownloading) notifyListeners();
    });

    await for (final chunk in stream) {
      total += chunk.length;
      final now = DateTime.now();
      if (now.difference(last) >= tick) {
        _audioDownloadProgress = total / totalSizeBytes;
        _lastSecondAudioDownloadSpeed = total - prevSecond;
        prevSecond = total;
        last = now;
        notifyListeners();
      }
      sink.add(chunk);
    }

    timer.cancel();
    _audioDownloadProgress = 1.0;
    _lastSecondAudioDownloadSpeed = 0;
    notifyListeners();

    await sink.flush();
    await sink.close();
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
