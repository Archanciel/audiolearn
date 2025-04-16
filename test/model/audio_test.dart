import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';

void main() {
  group('Audio.createValidVideoTitle', () {
    test('Test replace unauthorized characters', () {
      const String playlistTitle =
          "Audio: - ET L'UNIVERS DISPARAÎTRA/La \\nature * illusoire de notre réalité et le pouvoir transcendant du |véritable \"pardon\" + commentaires de <Gary> Renard ?";
      const String expectedValidVideoTitle =
          "Audio - - ET L'UNIVERS DISPARAÎTRA_La nature   illusoire de notre réalité et le pouvoir transcendant du _véritable 'pardon' + commentaires de Gary Renard";

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(playlistTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });

    test('Test replace colon char', () {
      const String playlistTitle =
          "Arthur Keller l'interview : Le CLIMAT n’est qu’une pièce du PUZZLE !";
      const String expectedValidVideoTitle =
          "Arthur Keller l'interview  - Le CLIMAT n’est qu’une pièce du PUZZLE !";

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(playlistTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });

    test('Test replace OR char', () {
      const String playlistTitle =
          "💥 EFFONDREMENT Imminent de l'Euro ?! | 👉 Maintenant, La Fin de l'Euro Approche ?!";
      const String expectedValidVideoTitle =
          "EFFONDREMENT Imminent de l'Euro ! _  Maintenant, La Fin de l'Euro Approche !";

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(playlistTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });

    test('Test replace OR char at end of validVideoTitle', () {
      const String playlistTitle =
          'Indian 🇮🇳|American🇺🇸| Japanese🇯🇵|Students #youtubeshorts #shorts |Samayra Narula| Subscribe |';
      const String expectedValidVideoTitle =
          'Indian _American_ Japanese_Students #youtubeshorts #shorts _Samayra Narula_ Subscribe';

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(playlistTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });

    test('Test replace double OR char', () {
      const String playlistTitle =
          'Lambda Expressions & Anonymous Functions ||  Python Tutorial  ||  Learn Python Programming';
      const String expectedValidVideoTitle =
          'Lambda Expressions & Anonymous Functions _  Python Tutorial  _  Learn Python Programming';

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(playlistTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });

    test('Test replace double slash char', () {
      const String videoTitle =
          '9 Dart concepts to know before you jump into flutter // for super beginners in flutter';
      const String expectedValidVideoTitle =
          '9 Dart concepts to know before you jump into flutter _ for super beginners in flutter';

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(videoTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });

    test('Test replace non french or english chars', () {
      const String videoTitle =
          "🔴 Que disent les pires scénarios climatiques ? 🔥";
      const String expectedValidVideoTitle =
          "Que disent les pires scénarios climatiques";

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(videoTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });
    test('Test replace œ by oe', () {
      const String videoTitle =
          "Se forger un cœur de diamant par Karine Arsène";
      const String expectedValidVideoTitle =
          "Se forger un coeur de diamant par Karine Arsène";

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(videoTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });
    test('Test replace Œ by OE', () {
      const String videoTitle =
          "Se forger un CŒUR de diamant par Karine Arsène";
      const String expectedValidVideoTitle =
          "Se forger un COEUR de diamant par Karine Arsène";

      final String actualValidVideoTitle =
          Audio.createValidVideoTitle(videoTitle);

      expect(actualValidVideoTitle, expectedValidVideoTitle);
    });
  });
  group('Audio static methods', () {
    test('buildDownloadDatePrefix', () {
      DateTime downloadDate = DateTime(2023, 4, 3, 2, 1, 33);
      String expectedPrefix = '230403-020133-';

      String actualPrefix = Audio.buildDownloadDatePrefix(downloadDate);

      expect(actualPrefix, expectedPrefix);
    });

    test('buildUploadDateSuffix', () {
      DateTime uploadDate = DateTime(2023, 4, 3);
      String expectedSuffix = '23-04-03';

      String actualSuffix = Audio.buildUploadDateSuffix(uploadDate);

      expect(actualSuffix, expectedSuffix);
    });
  });
  group('Audio filePathName getter', () {
    test('filePathName', () {
      Playlist playlist = Playlist(
        url: 'https://www.youtube.com/playlist?list=test_playlist_id',
        title: 'Test Playlist',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.downloadPath = 'download_path';

      Audio audio = Audio(
          enclosingPlaylist: playlist,
          originalVideoTitle: 'C',
          compactVideoDescription: '',
          videoUrl: 'https://example.com/video1',
          audioDownloadDateTime: DateTime(2023, 3, 17, 12, 34, 6),
          videoUploadDate: DateTime(2023, 4, 12),
          audioDuration: Duration.zero,
          audioPlaySpeed: 1.25);

      playlist.addDownloadedAudio(audio);

      String expectedFilePathName =
          "download_path\\230317-123406-C 23-04-12.mp3";
      String actualFilePathName = audio.filePathName;

      expect(actualFilePathName, expectedFilePathName);
    });
  });
  group('Audio == test', () {
    test('Audio copied to other playlist equality.', () {
      Playlist playlistOne = Playlist(
        url: 'https://www.youtube.com/playlist?list=test_playlist_id',
        id: 'playlist_one',
        title: 'playlist_one',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlistOne.downloadPath = 'playlist_one_path';

      Playlist playlistTwo = Playlist(
        url: 'https://www.youtube.com/playlist?list=test_playlist_id',
        id: 'playlist_two',
        title: 'playlist_two',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlistTwo.downloadPath = 'playlist_two_path';

      Audio audio = Audio(
          enclosingPlaylist: playlistOne,
          originalVideoTitle: 'C',
          compactVideoDescription: '',
          videoUrl: 'https://example.com/video1',
          audioDownloadDateTime: DateTime(2023, 3, 17, 12, 34, 6),
          videoUploadDate: DateTime(2023, 4, 12),
          audioDuration: Duration.zero,
          audioPlaySpeed: 1.25);

      audio.audioDownloadSpeed = 150000;

      playlistOne.addDownloadedAudio(audio);
      playlistTwo.addCopiedAudioToDownloadAndPlayableLst(
        audioToCopy: audio,
        copiedFromPlaylistTitle: playlistOne.title,
      );

      Audio copiedAudio = playlistTwo.downloadedAudioLst[0];

      expect(audio == copiedAudio, false);
    });
  });
}
