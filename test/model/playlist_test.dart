import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/models/audio.dart';

void main() {
  group('Testing Playlist add and remove methods', () {
    test('add 3 audio to playlist', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      expect(playlist.playableAudioLst.length, 3);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.playableAudioLst[2].originalVideoTitle, 'C');
    });
    test('copy playlist test', () {
      Playlist sourcePlaylist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(sourcePlaylist);

      expect(sourcePlaylist.downloadedAudioLst.length, 3);
      expect(sourcePlaylist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(sourcePlaylist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(sourcePlaylist.downloadedAudioLst[2].originalVideoTitle, 'B');

      expect(sourcePlaylist.playableAudioLst.length, 3);
      expect(sourcePlaylist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(sourcePlaylist.playableAudioLst[1].originalVideoTitle, 'A');
      expect(sourcePlaylist.playableAudioLst[2].originalVideoTitle, 'C');

      Playlist copiedPlaylist = sourcePlaylist.copy();

      expect(copiedPlaylist.downloadedAudioLst.length, 3);
      expect(copiedPlaylist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(copiedPlaylist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(copiedPlaylist.downloadedAudioLst[2].originalVideoTitle, 'B');

      expect(copiedPlaylist.playableAudioLst.length, 3);
      expect(copiedPlaylist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(copiedPlaylist.playableAudioLst[1].originalVideoTitle, 'A');
      expect(copiedPlaylist.playableAudioLst[2].originalVideoTitle, 'C');

      for (int i = 0; i < 3; i++) {
        Audio audio = sourcePlaylist.downloadedAudioLst[i];
        Audio copiedAudio = copiedPlaylist.downloadedAudioLst[i];

        expect(audio == copiedAudio, true);
      }
    });
    test('getAudioByFileNameNoExt() test', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      expect(
          playlist
              .getAudioByFileNameNoExt(
                audioFileNameNoExt: '230320-000000-C 22-03-20',
              )!
              .originalVideoTitle,
          'C');
      expect(
          playlist
              .getAudioByFileNameNoExt(
                audioFileNameNoExt: '230318-000000-B 22-03-18',
              )!
              .originalVideoTitle,
          'B');
      expect(
          playlist
              .getAudioByFileNameNoExt(
                audioFileNameNoExt: '230325-000000-A 22-03-25',
              )!
              .originalVideoTitle,
          'A');
    });

    test('remove 1 audio from downloaded and playable audio list', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      expect(playlist.playableAudioLst.length, 3);

      playlist.removeAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[1],
      );

      expect(playlist.downloadedAudioLst.length, 2);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'B');

      expect(playlist.playableAudioLst.length, 2);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
    });

    test('remove 1 audio from playable audio list only', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      expect(playlist.playableAudioLst.length, 3);

      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[1],
      );

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      expect(playlist.playableAudioLst.length, 2);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
    });

    test('remove 1 audio mp3 from playalable audio list', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      expect(playlist.playableAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[1],
      );

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.playableAudioLst.length, 2);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.playableAudioLst[1].originalVideoTitle, 'C');
    });
    test('remove audio list from playalable audio list', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      expect(playlist.playableAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      playlist.removeAudioLstFromPlayableAudioLstOnly(
        playableAudioToRemoveLst: [
          playlist.playableAudioLst[1],
          playlist.playableAudioLst[2],
        ],
      );

      expect(playlist.downloadedAudioLst.length, 3);
      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
    });
    test('remove audio list from downloaded and playalable audio lists', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      expect(playlist.playableAudioLst.length, 3);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'C');
      expect(playlist.downloadedAudioLst[1].originalVideoTitle, 'A');
      expect(playlist.downloadedAudioLst[2].originalVideoTitle, 'B');

      playlist.removeAudioLstFromDownloadedAndPlayableAudioLsts(
        audioToRemoveLst: [
          playlist.playableAudioLst[1],
          playlist.playableAudioLst[2],
        ],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'B');
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'B');
    });
    test('add 1 audio to empty playlist', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.downloadedAudioLst[0].originalVideoTitle, 'A');

      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.playableAudioLst[0].originalVideoTitle, 'A');

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
    });
    test(
        'add 1 audio to empty playlist and then remove it from downloaded and playable list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);

      playlist.removeAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 0);
      expect(playlist.playableAudioLst.length, 0);
      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test(
        'add 1 audio to empty playlist and then remove it from playable list only',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);

      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 0);
      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test('add 1 audio to empty playlist and then delete the mp3', () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);

      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 0);
      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test(
        'add 2 audio to empty playlist and then remove 1 audio from downloaded and playable list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      addOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      addOneOtherDownloadedAudio(playlist);

      // verifying that the currentOrPastPlayableAudioIndex
      // is not changed by the addDownloadedAudio method
      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      playlist.removeAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
    test(
        'add 3 audio to playlist, set second as current, then delete the first downloaded',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      playlist.currentOrPastPlayableAudioIndex = 1;
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // deleting the first downloaded audio. Since the
      // currentOrPastPlayableAudioIndex is 1, i.e. the
      // second downloaded audio, the currentOrPastPlayableAudioIndex
      // is not changed
      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[2],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
    test(
        'add 3 audio to playlist, set second as current, then delete the audio',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      playlist.currentOrPastPlayableAudioIndex = 1;
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // deleting the last downloaded audio. Since the
      // currentOrPastPlayableAudioIndex is 1, i.e. the
      // second downloaded audio, the currentOrPastPlayableAudioIndex
      // is decremented by 1
      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // now deleting the remaining (and current) downloaded audio

      playlist.removePlayableAudio(
        playableAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test(
        'add 3 audio to playlist, set second as current, then remove from playable audio list the first downloaded',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      playlist.currentOrPastPlayableAudioIndex = 1;
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // removing the first downloaded audio from the playable
      // playlist only. Since the
      // currentOrPastPlayableAudioIndex is 1, i.e. the
      // second downloaded audio, the currentOrPastPlayableAudioIndex
      // is not changed
      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[2],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
    test(
        'add 3 audio to playlist, set second as current, then remove them from playable audio list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      _addThreeDownloadedAudio(playlist);

      playlist.currentOrPastPlayableAudioIndex = 1;
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // removing the last downloaded audio. Since the
      // currentOrPastPlayableAudioIndex is 1, i.e. the
      // second downloaded audio, the currentOrPastPlayableAudioIndex
      // is decremented by 1
      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      // now deleting the remaining (and current) downloaded audio

      playlist.removeDownloadedAudioFromPlayableAudioLstOnly(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.currentOrPastPlayableAudioIndex, -1);
    });
    test(
        'copy 2 audio to empty playlist and then remove 1 audio from downloaded and playable list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      copyOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      copyOneOtherDownloadedAudio(playlist);

      // verifying that the currentOrPastPlayableAudioIndex
      // is not changed by the addDownloadedAudio method
      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      playlist.removeAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
    test(
        'move 2 audio to empty playlist and then remove 1 audio from downloaded and playable list',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.currentOrPastPlayableAudioIndex = -1;

      moveOneDownloadedAudio(playlist);

      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      moveOneOtherDownloadedAudio(playlist);

      // verifying that the currentOrPastPlayableAudioIndex
      // is not changed by the addDownloadedAudio method
      expect(playlist.currentOrPastPlayableAudioIndex, 1);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');

      playlist.removeAudioFromDownloadAndPlayableAudioLst(
        downloadedAudio: playlist.playableAudioLst[0],
      );

      expect(playlist.downloadedAudioLst.length, 1);
      expect(playlist.playableAudioLst.length, 1);
      expect(playlist.currentOrPastPlayableAudioIndex, 0);
      expect(
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex]
              .originalVideoTitle,
          'A');
    });
  });
  group('Testing Playlist duration calculation methods', () {
    test(
        '''Add 3 playable audio to playlist and compute the total playable duration
           as well as the total playable remaining duration of the playlist''',
        () {
      Playlist playlist = Playlist(
        url: 'https://example.com/playlist2',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      addThreePlayableAudio(playlist);

      expect(
        playlist.getPlayableAudioLstTotalDuration().inMinutes,
        40,
      );

      expect(
        playlist.getPlayableAudioLstTotalRemainingDuration().inMinutes,
        30,
      );
    });
  });
}

void addThreePlayableAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'C',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime(2022, 3, 20),
      audioDuration: Duration(minutes: 10),
      audioPlaySpeed: 1.5);
  audio.audioPositionSeconds = 300;
  playlist.addPlayableAudio(audio);

  Audio audio2 = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video2',
      audioDownloadDateTime: DateTime(2023, 3, 25),
      videoUploadDate: DateTime(2022, 3, 25),
      audioDuration: Duration(minutes: 20),
      audioPlaySpeed: 1.5);
  audio2.audioPositionSeconds = 600;
  playlist.addPlayableAudio(audio2);

  Audio audio3 = Audio(
      enclosingPlaylist: playlist,
      compactVideoDescription: '',
      originalVideoTitle: 'B',
      videoUrl: 'https://example.com/video3',
      audioDownloadDateTime: DateTime(2023, 3, 18),
      videoUploadDate: DateTime(2022, 3, 18),
      audioDuration: Duration(minutes: 30),
      audioPlaySpeed: 1.5);
  audio3.audioPositionSeconds = 900;
  playlist.addPlayableAudio(audio3);
}

void _addThreeDownloadedAudio(Playlist playlist) {
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'C',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime(2022, 3, 20),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5));
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video2',
      audioDownloadDateTime: DateTime(2023, 3, 25),
      videoUploadDate: DateTime(2022, 3, 25),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5));
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      compactVideoDescription: '',
      originalVideoTitle: 'B',
      videoUrl: 'https://example.com/video3',
      audioDownloadDateTime: DateTime(2023, 3, 18),
      videoUploadDate: DateTime(2022, 3, 18),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5));

  playlist.downloadedAudioLst[0].audioDownloadSpeed = 1000;
  playlist.downloadedAudioLst[1].audioDownloadSpeed = 2000;
  playlist.downloadedAudioLst[2].audioDownloadSpeed = 3000;

  playlist.playableAudioLst[0].audioDownloadSpeed = 1000;
  playlist.playableAudioLst[1].audioDownloadSpeed = 2000;
  playlist.playableAudioLst[2].audioDownloadSpeed = 3000;
}

void addOneDownloadedAudio(Playlist playlist) {
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5));
}

void addOneOtherDownloadedAudio(Playlist playlist) {
  playlist.addDownloadedAudio(Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'B',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5));
}

void copyOneDownloadedAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5);
  audio.audioDownloadSpeed = 1000;
  playlist.addCopiedAudioToDownloadAndPlayableLst(
      audioToCopy: audio, copiedFromPlaylistTitle: 'source playlist title');
}

void copyOneOtherDownloadedAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'B',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5);
  audio.audioDownloadSpeed = 1000;
  playlist.addCopiedAudioToDownloadAndPlayableLst(
      audioToCopy: audio, copiedFromPlaylistTitle: 'source playlist title');
}

void moveOneDownloadedAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'A',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5);
  audio.audioDownloadSpeed = 1000;
  playlist.addMovedAudioToDownloadAndPlayableLst(
      movedAudio: audio, movedFromPlaylistTitle: 'source playlist title');
}

void moveOneOtherDownloadedAudio(Playlist playlist) {
  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle: 'B',
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 20),
      videoUploadDate: DateTime.now(),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.5);
  audio.audioDownloadSpeed = 1000;
  playlist.addMovedAudioToDownloadAndPlayableLst(
      movedAudio: audio, movedFromPlaylistTitle: 'source playlist title');
}
