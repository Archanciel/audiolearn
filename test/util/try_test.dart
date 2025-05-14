import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/audio_sort_filter_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/services/sort_filter_parameters.dart';
import 'package:audiolearn/utils/button_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import '../services/mock_shared_preferences.dart';

void main() {
  Playlist audioPlaylist = Playlist(
    id: '1',
    title: 'Audio Playlist',
    playlistQuality: PlaylistQuality.voice,
    playlistType: PlaylistType.youtube,
  );

  final Audio audioOne = Audio.fullConstructor(
    youtubeVideoChannel: 'one',
    enclosingPlaylist: audioPlaylist,
    movedFromPlaylistTitle: null,
    movedToPlaylistTitle: null,
    copiedFromPlaylistTitle: null,
    copiedToPlaylistTitle: null,
    originalVideoTitle: 'Zebra ?',
    compactVideoDescription:
        'On vous propose de découvrir les tendances crypto en progression en 2024. Découvrez lesquelles sont les plus prometteuses et lesquelles sont à éviter.',
    validVideoTitle: 'Sur quelle tendance crypto investir en 2024 ?',
    videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
    audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 22),
    audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
    audioDownloadSpeed: 1000000,
    videoUploadDate: DateTime(2023, 3, 1),
    audioDuration: const Duration(minutes: 8, seconds: 30),
    isAudioMusicQuality: false,
    audioPlaySpeed: kAudioDefaultPlaySpeed,
    audioPlayVolume: kAudioDefaultPlayVolume,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    isPaused: true,
    audioPausedDateTime: null,
    audioPositionSeconds: 0,
    audioFileName: 'Test Video Title.mp3',
    audioFileSize: 125000000,
    isAudioImported: false,
  );

  final Audio audioTwo = Audio.fullConstructor(
    youtubeVideoChannel: 'two',
    enclosingPlaylist: audioPlaylist,
    movedFromPlaylistTitle: null,
    movedToPlaylistTitle: null,
    copiedFromPlaylistTitle: null,
    copiedToPlaylistTitle: null,
    originalVideoTitle: 'Zebra ?',
    compactVideoDescription:
        'Éthique et tac vous propose de découvrir les tendances crypto en progression en 2024. Découvrez lesquelles sont les plus prometteuses et lesquelles sont à éviter.',
    validVideoTitle: 'Tendance crypto en accélération en 2024',
    videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
    audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
    audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
    audioDownloadSpeed: 1000000,
    videoUploadDate: DateTime(2023, 1, 1),
    audioDuration: const Duration(minutes: 55, seconds: 30),
    isAudioMusicQuality: false,
    audioPlaySpeed: kAudioDefaultPlaySpeed,
    audioPlayVolume: kAudioDefaultPlayVolume,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    isPaused: true,
    audioPausedDateTime: null,
    audioPositionSeconds: 0,
    audioFileName: 'Test Video Title.mp3',
    audioFileSize: 70000000,
    isAudioImported: false,
  );
  final Audio audioThree = Audio.fullConstructor(
    youtubeVideoChannel: 'one',
    enclosingPlaylist: audioPlaylist,
    movedFromPlaylistTitle: null,
    movedToPlaylistTitle: null,
    copiedFromPlaylistTitle: null,
    copiedToPlaylistTitle: null,
    originalVideoTitle: 'Zebra ?',
    compactVideoDescription:
        "Se dirige-t-on vers une intelligence artificielle qui pourrait menacer l’humanité ou au contraire, vers une opportunité pour l’humanité ? Découvrez les réponses à ces questions dans ce podcast.",
    validVideoTitle:
        'Intelligence Artificielle: quelle menace ou opportunité en 2024 ?',
    videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
    audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 42),
    audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
    audioDownloadSpeed: 1000000,
    videoUploadDate: DateTime(2023, 4, 1),
    audioDuration: const Duration(minutes: 15, seconds: 30),
    isAudioMusicQuality: false,
    audioPlaySpeed: kAudioDefaultPlaySpeed,
    audioPlayVolume: kAudioDefaultPlayVolume,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    isPaused: true,
    audioPausedDateTime: null,
    audioPositionSeconds: 0,
    audioFileName: 'Test Video Title.mp3',
    audioFileSize: 130000000,
    isAudioImported: false,
  );
  final Audio audioFour = Audio.fullConstructor(
    youtubeVideoChannel: 'one',
    enclosingPlaylist: audioPlaylist,
    movedFromPlaylistTitle: null,
    movedToPlaylistTitle: null,
    copiedFromPlaylistTitle: null,
    copiedToPlaylistTitle: null,
    originalVideoTitle: 'Zebra ?',
    compactVideoDescription:
        "Sur le plan philosophique, quelles différences entre l’intelligence humaine et l’intelligence artificielle ? Découvrez les réponses à ces questions dans ce podcast.",
    validVideoTitle:
        'Intelligence humaine ou artificielle, quelles différences ?',
    videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
    audioDownloadDateTime: DateTime(2023, 3, 28, 20, 5, 32),
    audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
    audioDownloadSpeed: 1000000,
    videoUploadDate: DateTime(2023, 2, 1),
    audioDuration: const Duration(minutes: 5, seconds: 30),
    isAudioMusicQuality: false,
    audioPlaySpeed: kAudioDefaultPlaySpeed,
    audioPlayVolume: kAudioDefaultPlayVolume,
    isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
    isPaused: true,
    audioPausedDateTime: null,
    audioPositionSeconds: 0,
    audioFileName: 'Test Video Title.mp3',
    audioFileSize: 110000000,
    isAudioImported: false,
  );

  List<Audio> audioLst = [
    audioOne,
    audioTwo,
    audioThree,
    audioFour,
  ];
  AudioSortFilterService audioSortFilterService = AudioSortFilterService(
      settingsDataService: SettingsDataService(
    sharedPreferences: MockSharedPreferences(),
  ));

  group('group', () {
    test('filter by <tendance crypto> AND <en 2024>', () async {
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");
      AudioSortFilterService audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );

      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'tendance crypto',
                'en 2024',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <tendance crypto> OR <en 2024>', () async {
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");
      AudioSortFilterService audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );

      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
        audioThree,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'tendance crypto',
                'en 2024',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
  });
}
