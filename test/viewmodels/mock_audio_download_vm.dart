import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';

/// The MockAudioDownloadVM inherits from AudioDownloadVM.
/// It exists because when executing integration tests, using
/// YoutubeExplode to get a Youtube playlist in order to obtain
/// the playlist title is not possible.
class MockAudioDownloadVM extends AudioDownloadVM {
  final List<Playlist> _playlistLst = [];

  String _youtubePlaylistTitle = '';
  set youtubePlaylistTitle(String youtubePlaylistTitle) {
    _youtubePlaylistTitle = youtubePlaylistTitle;
  }

  MockAudioDownloadVM({
    required super.warningMessageVM,
    required super.settingsDataService,
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
    Playlist? addedPlaylist = await addPlaylistCallableByMock(
      playlistUrl: playlistUrl,
      localPlaylistTitle: localPlaylistTitle,
      playlistQuality: playlistQuality,
      mockYoutubePlaylistTitle: _youtubePlaylistTitle,
    );

    return addedPlaylist;
  }

  @override
  Future<bool> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoTargetPlaylist,
  }) async {
    if (videoUrl.contains('invalid')) {
      warningMessageVM.isSingleVideoUrlInvalid = true;

      return false;
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

      return false;
    } catch (e) {
      // file was not found in the downloaded audio directory
    }

    notifyListeners();

    return true;
  }
}
