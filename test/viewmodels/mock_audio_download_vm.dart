import 'dart:io';

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
  String _youtubePlaylistTitle = '';
  set youtubePlaylistTitle(String youtubePlaylistTitle) {
    _youtubePlaylistTitle = youtubePlaylistTitle;
  }

  final String mockPlaylistDirectory;

  MockAudioDownloadVM({
    required super.warningMessageVM,
    required super.settingsDataService,
    this.mockPlaylistDirectory = '',
    super.isTest,
  });

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
        id: 'mock_id',
        title: 'Mock Playlist',
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

    final mockFiles = Directory(mockPlaylistDirectory)
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
      final Audio mockAudio = Audio(
        youtubeVideoChannel: 'Mock Channel',
        enclosingPlaylist: playlist,
        originalVideoTitle: fileName.replaceAll('.mp3', ''),
        compactVideoDescription: 'Mock Description',
        videoUrl: '',
        audioDownloadDateTime: DateTime.now(),
        videoUploadDate: DateTime.now(),
        audioDuration: Duration(minutes: 3),
        audioPlaySpeed: 1.0,
      );

      playlist.addDownloadedAudio(mockAudio);
    }

    notifyListeners();
  }
}
