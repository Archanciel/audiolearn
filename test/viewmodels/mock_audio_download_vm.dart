import 'dart:io';
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audioplayers/audioplayers.dart';

/// The MockAudioDownloadVM inherits from AudioDownloadVM.
/// It exists because when executing integration tests, using
/// YoutubeExplode to get a Youtube playlist in order to obtain
/// the playlist title is not possible.
///
/// It is also useful in unit tests to test the AudioDownloadVM
/// importAudioFilesInPlaylist() method. Since this method uses
/// the Flutter AudioPlayer plugin, it is not possible to test
/// it in a unit test. The MockAudioDownloadVM redifines the
/// getMp3DurationWithAudioPlayer() method in order to avoid to
/// instantiate the AudioPlayer plugin.
class MockAudioDownloadVM extends AudioDownloadVM {
  // Map comtaining YouTube playlist data
  final Map<String, Map<String, String>> youtubePlaylistData = {
    'Essai': {
      'url':
          'https://youtube.com/playlist?list=PLzwWSJNcZTMSMSrQ7LA0uSn91uZz47JOh&si=-c9fkDSormJfnB4k',
      'title': 'Essai',
      "id": "PLzwWSJNcZTMSMSrQ7LA0uSn91uZz47JOh",
    },
    'audio_player_view_2_shorts_test': {
      'url':
          'https://youtube.com/playlist?list=PLzwWSJNcZTMRrOkIdVTkV58wpWIZQCkgd&si=fBu5t1hVFDHThbwy',
      'title': 'audio_player_view_2_shorts_test',
      "id": "PLzwWSJNcZTMRrOkIdVTkV58wpWIZQCkgd",
    },
  };

  final Map<String, Map<String, Map<String, dynamic>>> youtubePlaylistAudio = {
    'Essai': {
      '1': {
        "audioDownloadDateTime": "2024-11-17T15:50:59.563914",
        "audioDownloadDurationMs": 3351,
        "audioDownloadSpeed": 1009043,
        "audioDurationMs": 550921,
        "audioFileName":
            "241117-155059-Les IA ont-elles vraiment atteint l'AGI  Analyse_ Johann Oriel 24-11-15.mp3",
        "audioFileSize": 3381742,
        "audioPausedDateTime": null,
        "audioPlaySpeed": 1.0,
        "audioPlayVolume": 0.5,
        "audioPositionSeconds": 0,
        "compactVideoDescription":
            "Johann Oriel - Technosophie\n\nhttps://www.geeky-gadgets.com/artificial-general-intelligence-advancements/\nhttps://ekinakyurek.github.io/papers/ttt.pdf\nhttps://arcprize.org/leaderboard ...",
        "copiedFromPlaylistTitle": null,
        "copiedToPlaylistTitle": null,
        "isAudioImported": false,
        "isAudioMusicQuality": false,
        "isPaused": true,
        "isPlayingOrPausedWithPositionBetweenAudioStartAndEnd": false,
        "movedFromPlaylistTitle": null,
        "movedToPlaylistTitle": null,
        "originalVideoTitle":
            "Les IA ont-elles vraiment atteint l'AGI ? Analyse_ Johann Oriel",
        "validVideoTitle":
            "Les IA ont-elles vraiment atteint l'AGI  Analyse_ Johann Oriel",
        "videoUploadDate": "2024-11-15T15:00:24.000Z",
        "videoUrl": "https://www.youtube.com/watch?v=MHreSEHusBE",
        "youtubeVideoChannel": "Johann Oriel - Technosophie"
      },
      '2': {
        "audioDownloadDateTime": "2024-11-17T15:51:06.460981",
        "audioDownloadDurationMs": 3493,
        "audioDownloadSpeed": 1696640,
        "audioDurationMs": 971847,
        "audioFileName":
            "241117-155106-La Chine a créé l'ARME ULTIME  - Plus PUISSANTE que l'étoilenoire 24-11-16.mp3",
        "audioFileSize": 5927323,
        "audioPausedDateTime": null,
        "audioPlaySpeed": 1.0,
        "audioPlayVolume": 0.5,
        "audioPositionSeconds": 0,
        "compactVideoDescription":
            "Vision IA\n\nRejoignez cette chaine pour soutenir mon travail et bénéficier d'avantages exclusifs :\nhttps://www.youtube.com/channel/UCyc03X3uRuxM9n7fyRH_gIw/join\n ...\n\nLa Chine, Téléportation Quantique, Sauron\" Chinois, L'Arme Secrète, Qui Secoue",
        "copiedFromPlaylistTitle": null,
        "copiedToPlaylistTitle": null,
        "isAudioImported": false,
        "isAudioMusicQuality": false,
        "isPaused": true,
        "isPlayingOrPausedWithPositionBetweenAudioStartAndEnd": false,
        "movedFromPlaylistTitle": null,
        "movedToPlaylistTitle": null,
        "originalVideoTitle":
            "La Chine a créé l'ARME ULTIME : Plus PUISSANTE que l'étoilenoire?",
        "validVideoTitle":
            "La Chine a créé l'ARME ULTIME  - Plus PUISSANTE que l'étoilenoire",
        "videoUploadDate": "2024-11-16T06:05:59.000Z",
        "videoUrl": "https://www.youtube.com/watch?v=DulXYMZZS34",
        "youtubeVideoChannel": "Vision IA"
      },
    },
    'audio_player_view_2_shorts_test': {
      '1': {
        "audioDownloadDateTime": "2024-11-17T15:51:32.502988",
        "audioDownloadDurationMs": 1955,
        "audioDownloadSpeed": 31343,
        "audioDurationMs": 9891,
        "audioFileName": "241117-155132-Really short video 23-07-01.mp3",
        "audioFileSize": 61288,
        "audioPausedDateTime": null,
        "audioPlaySpeed": 1.0,
        "audioPlayVolume": 0.5,
        "audioPositionSeconds": 0,
        "compactVideoDescription":
            "Jean-Pierre Schnyder\n\nCette vidéo me sert \u00e0 tester AudioLearn, l'app Android que je développe. ...",
        "copiedFromPlaylistTitle": null,
        "copiedToPlaylistTitle": null,
        "isAudioImported": false,
        "isAudioMusicQuality": false,
        "isPaused": true,
        "isPlayingOrPausedWithPositionBetweenAudioStartAndEnd": false,
        "movedFromPlaylistTitle": null,
        "movedToPlaylistTitle": null,
        "originalVideoTitle": "Really short video",
        "validVideoTitle": "Really short video",
        "videoUploadDate": "2023-07-01T18:05:33.000Z",
        "videoUrl": "https://www.youtube.com/watch?v=ADt0BYlh1Yo",
        "youtubeVideoChannel": "Jean-Pierre Schnyder"
      },
      '2': {
        "audioDownloadDateTime": "2024-11-17T15:51:36.668472",
        "audioDownloadDurationMs": 2045,
        "audioDownloadSpeed": 176401,
        "audioDurationMs": 58978,
        "audioFileName": "241117-155136-morning _ cinematic video 23-07-01.mp3",
        "audioFileSize": 360849,
        "audioPausedDateTime": null,
        "audioPlaySpeed": 1.0,
        "audioPlayVolume": 0.5,
        "audioPositionSeconds": 0,
        "compactVideoDescription":
            "Jean-Pierre Schnyder\n\nCette vidéo me sert à tester AudioLearn, l'app Android que je développe. ...",
        "copiedFromPlaylistTitle": null,
        "copiedToPlaylistTitle": null,
        "isAudioImported": false,
        "isAudioMusicQuality": false,
        "isPaused": true,
        "isPlayingOrPausedWithPositionBetweenAudioStartAndEnd": false,
        "movedFromPlaylistTitle": null,
        "movedToPlaylistTitle": null,
        "originalVideoTitle": "morning | cinematic video",
        "validVideoTitle": "morning _ cinematic video",
        "videoUploadDate": "2023-07-01T18:48:13.000Z",
        "videoUrl": "https://www.youtube.com/watch?v=nDqolLTOzYk",
        "youtubeVideoChannel": "Jean-Pierre Schnyder"
      },
    },
  };

  String _youtubePlaylistTitle = '';
  set youtubePlaylistTitle(String youtubePlaylistTitle) {
    _youtubePlaylistTitle = youtubePlaylistTitle;
  }

  final String mockPlaylistDirectory;

  MockAudioDownloadVM({
    required super.warningMessageVM,
    required super.settingsDataService,
    this.mockPlaylistDirectory = '',
  });

  String getPlaylistTitleByUrl(String url) {
    // Use firstWhere with orElse to handle not found cases
    final Map<String, String> entry = youtubePlaylistData.values.firstWhere(
      (value) => value['url'] == url,
      orElse: () => {'title': ''}, // Return a default empty title
    );

    return entry['title']!; // The title is never null due to orElse !
  }

  String getPlaylistIdByUrl(String url) {
    // Use firstWhere with orElse to handle not found cases
    final Map<String, String> entry = youtubePlaylistData.values.firstWhere(
      (value) => value['url'] == url,
      orElse: () => {'id': ''}, // Return a default map with an empty title
    );

    return entry['id']!; // The id is never null due to orElse !
  }

  Map<String, dynamic>? getAudioDataByFileName(String audioFileName) {
    // Iterate over playlists
    return youtubePlaylistAudio.values
        .expand((playlist) => playlist.values) // Flatten all audio entries
        .firstWhere(
          (audio) => audio['audioFileName'] == audioFileName,
          orElse: () => {}, // Returning null does not compile !
        );
  }

  @override
  Future<Playlist?> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    if (playlistUrl.contains('invalid')) {
      warningMessageVM.invalidPlaylistUrl = playlistUrl;

      return null;
    }

    // Calling the AudioDownloadVM's addPlaylistCallableByMock method
    // enables the MockAudioDownloadVM to use the logic of the
    // AudioDownloadVM addPlaylist method. The {mockYoutubePlaylistTitle}
    // is passed to the method in order to indicate that the method
    // is called by the MockAudioDownloadVM.
    Playlist? addedPlaylist = await addPlaylistCallableAlsoByMock(
      playlistUrl: playlistUrl,
      localPlaylistTitle: localPlaylistTitle,
      playlistQuality: playlistQuality,
      mockYoutubePlaylistTitle: _youtubePlaylistTitle,
    );

    return addedPlaylist;
  }

  @override
  Future<ErrorType> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoTargetPlaylist,
    bool downloadAtMusicQuality = false,
    bool displayWarningIfAudioAlreadyExists = true,
    String predefinedAudioFileName = '',
  }) async {
    if (videoUrl.contains('invalid')) {
      warningMessageVM.isSingleVideoUrlInvalid = true;

      return ErrorType.downloadAudioYoutubeError;
    }

    try {
      Audio existingSingleVideoAudio = singleVideoTargetPlaylist
          .downloadedAudioLst
          .firstWhere((audio) => audio.videoUrl == videoUrl);

      String existingAudioFileName = existingSingleVideoAudio.audioFileName;

      notifyDownloadError(
        errorType: ErrorType.downloadAudioFileAlreadyOnAudioDirectory,
        errorArgOne: existingSingleVideoAudio.validVideoTitle,
        errorArgTwo: existingAudioFileName,
        errorArgThree: singleVideoTargetPlaylist.title,
      );

      return ErrorType.downloadAudioFileAlreadyOnAudioDirectory;
    } catch (e) {
      // file was not found in the downloaded audio directory
    }

    notifyListeners();

    return ErrorType.noError;
  }

  /// This method is redifined in the MockAudioDownloadVM so that the
  /// AudioDownloadVM.importAudioFilesInPlaylist() method can be unit
  /// tested.
  @override
  Future<Duration> getMp3DurationWithAudioPlayer({
    required AudioPlayer? audioPlayer,
    required String filePathName,
  }) async {
    final File file = File(filePathName);

    if (!await file.exists()) {
      throw FileSystemException("File not found", filePathName);
    }

    final int fileSizeBytes = await file.length();
    final int fileDurationSeconds = (fileSizeBytes * 8) ~/ (128 * 1000);

    return Duration(seconds: fileDurationSeconds);
  }

  @override
  AudioPlayer? instanciateAudioPlayer() {
    return null;
  }

  @override
  Future<void> downloadPlaylistAudio({
    required String playlistUrl,
  }) async {
    // Simulate checking for an existing playlist
    Playlist? playlist;

    try {
      playlist = listOfPlaylist.firstWhere(
        (pl) => pl.url == playlistUrl,
      );
    } catch (e) {
      playlist = null;
    }

    // If the playlist doesn't exist, create it
    if (playlist == null) {
      playlist = Playlist(
        url: playlistUrl,
        id: getPlaylistIdByUrl(playlistUrl),
        title: getPlaylistTitleByUrl(playlistUrl),
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      await setPlaylistPath(
        playlistTitle: playlist.title,
        playlist: playlist,
      );

      listOfPlaylist.add(playlist);
    }

    // Simulate copying mock MP3 files to the playlist directory

    final playlistDir = Directory(playlist.downloadPath);

    if (!playlistDir.existsSync()) {
      playlistDir.createSync(recursive: true);
    }

    String filesPath =
        '$mockPlaylistDirectory${path.separator}audioFiles${path.separator}${playlist.title}';

    if (mockPlaylistDirectory.isEmpty) {
      filesPath = kApplicationPathWindows;
    }

    final mockFiles = Directory(filesPath)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.mp3'));

    for (var mockFile in mockFiles) {
      final fileName = mockFile.uri.pathSegments.last;
      final targetFile = File('${playlistDir.path}/$fileName');

      if (targetFile.existsSync()) {
        continue;
      }

      mockFile.copySync(targetFile.path);

      // Add the audio to the playlist
      Map<String, dynamic> audioDataMap = getAudioDataByFileName(fileName)!;
      final Audio mockAudio = Audio(
        youtubeVideoChannel: audioDataMap['youtubeVideoChannel'],
        enclosingPlaylist: playlist,
        originalVideoTitle: audioDataMap['originalVideoTitle'],
        compactVideoDescription: audioDataMap['compactVideoDescription'],
        videoUrl: audioDataMap['videoUrl'],
        audioDownloadDateTime:
            DateTime.parse(audioDataMap['audioDownloadDateTime']),
        videoUploadDate: DateTime.parse(audioDataMap['videoUploadDate']),
        audioDuration: Duration(milliseconds: audioDataMap['audioDurationMs']),
        audioPlaySpeed: audioDataMap['audioPlaySpeed'],
      );

      mockAudio.audioDownloadSpeed = audioDataMap['audioDownloadSpeed'];
      mockAudio.audioFileName = audioDataMap['audioFileName'];
      mockAudio.audioFileSize = audioDataMap['audioFileSize'];

      playlist.addDownloadedAudio(mockAudio);

      notifyListeners();
    }

    notifyListeners();
  }

  @override
  Future<ErrorType> redownloadSingleVideoAudio({
    bool displayWarningIfAudioAlreadyExists = false,
  }) async {
    if (isDownloadStopping) {
      return ErrorType.downloadAudioYoutubeError;
    }

    Audio audio = currentDownloadingAudio;
    int audioFileSize = audio.audioFileSize;

    int downloadSpeedPerSecond = audioFileSize ~/ 5;

    for (int i = 0; i < audioFileSize; i += downloadSpeedPerSecond) {
      downloadProgress = i * downloadSpeedPerSecond as double;
      lastSecondDownloadSpeed = downloadSpeedPerSecond;

      // Simulating re-download process
      await Future.delayed(Duration(milliseconds: 1000));

      notifyListeners();
    }

    List<String> playlistRootPathElementsLst =
        audio.enclosingPlaylist!.downloadPath.split('/');

    // This name may have been changed by the user on Android
    // using the 'Application Settings ...' menu.
    String androidAppPlaylistDirName =
        playlistRootPathElementsLst[playlistRootPathElementsLst.length - 2];

    String playlistRootPath =
        "$kApplicationPathWindows${path.separator}${androidAppPlaylistDirName}";

    DirUtil.copyFileToDirectorySync(
      sourceFilePathName:
          "$kApplicationPath${path.separator}downloadedMockFileDir${path.separator}${audio.audioFileName}",
      targetDirectoryPath: playlistRootPath,
    );

    if (isDownloadStopping) {
      return ErrorType.downloadAudioYoutubeError;
    }

    // Mocking success case
    return ErrorType.noError;
  }
}
