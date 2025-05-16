import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/sort_filter_parameters.dart';
import 'package:audiolearn/utils/date_time_parser.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/services/audio_sort_filter_service.dart';
import 'mock_shared_preferences.dart';

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

  group('filter test: ignoring case, filter audio list on validVideoTitle only',
      () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");
      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    test('filter by <tendance crypto> AND <en 2024>', () {
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
    test('filter by <tendance crypto> OR <en 2024>', () {
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
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'en 2024',
                'tendance crypto',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
        audioThree,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'en 2024',
                'tendance crypto',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'quelle',
                '2024',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <quelle> OR <2024>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
        audioThree,
        audioFour,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'quelle',
                '2024',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                '2024',
                'quelle',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <2024> OR <quelle>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
        audioThree,
        audioFour,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                '2024',
                'quelle',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredAudios = [
        audioThree,
        audioFour,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'intelligence',
                'artificielle',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
  });
  group(
      'filter test: not ignoring case, filter audio list on validVideoTitle only',
      () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    test('filter by <tendance crypto> AND <en 2024>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'tendance crypto',
                'en 2024',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <tendance crypto> OR <en 2024>', () {
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
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <en 2024> AND <tendance crypto>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'en 2024',
                'tendance crypto',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <en 2024> OR <tendance crypto>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
        audioThree,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'en 2024',
                'tendance crypto',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <quelle> AND <2024>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'quelle',
                '2024',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <quelle> OR <2024>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
        audioThree,
        audioFour,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'quelle',
                '2024',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <2024> AND <quelle>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                '2024',
                'quelle',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <intelligence> OR <artificielle>', () {
      List<Audio> expectedFilteredAudios = [
        audioFour,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'intelligence',
                'artificielle',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <2024> OR <quelle>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
        audioThree,
        audioFour,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                '2024',
                'quelle',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: false,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
  });
  group(
      'filter test: ignoring case, filter audio list on validVideoTitle or compactVideoDescription test',
      () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    test('filter by <investir en 2024> AND <éthique et tac>', () {
      List<Audio> expectedFilteredAudios = [];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'investir en 2024',
                'éthique et tac',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <accélération> AND <éthique et tac>', () {
      List<Audio> expectedFilteredAudios = [
        audioTwo,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'accélération',
                'éthique et tac',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <investir en 2024> OR <éthique et tac>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'investir en 2024',
                'éthique et tac',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <on vous propose> OR <en accélération>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'on vous propose',
                'en accélération',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: true,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
  });
  group(
      'filter test: not ignoring case, filter audio list on validVideoTitle or compactVideoDescription',
      () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    test('filter by <investir en 2024> AND <éthique et tac>', () {
      List<Audio> expectedFilteredAudios = [];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'investir en 2024',
                'éthique et tac',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <accélération> AND <Éthique et tac>', () {
      List<Audio> expectedFilteredAudios = [
        audioTwo,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'accélération',
                'Éthique et tac',
              ],
              sentencesCombination: SentencesCombination.and,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <investir en 2024> OR <Éthique et tac>', () {
      List<Audio> expectedFilteredAudios = [audioOne, audioTwo];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'investir en 2024',
                'Éthique et tac',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <investir en 2024> OR <éthique et tac>', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'investir en 2024',
                'éthique et tac',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by <on vous propose> OR <en accélération>', () {
      List<Audio> expectedFilteredAudios = [
        audioTwo,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService
          .filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
              audioLst: audioLst,
              filterSentenceLst: [
                'on vous propose',
                'en accélération',
              ],
              sentencesCombination: SentencesCombination.or,
              ignoreCase: false,
              searchAsWellInVideoCompactDescription: true,
              searchAsWellInYoutubeChannelName: false);

      expect(filteredAudioLst, expectedFilteredAudios);
    });
  });
  group(
      '''filter test: by start/end download date or/and start/end video upload date.''',
      () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    test('filter by start/end download date', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
        audioThree,
      ];

      List<Audio> filteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
              selectedPlaylist: audioPlaylist,
              audioLst: audioLst,
              audioSortFilterParameters: AudioSortFilterParameters(
                selectedSortItemLst: [],
                filterSentenceLst: [],
                sentencesCombination: SentencesCombination.and,
                ignoreCase: true,
                searchAsWellInVideoCompactDescription: true,
                searchAsWellInYoutubeChannelName: false,
                downloadDateStartRange: DateTime(2023, 3, 24, 20, 5, 22),
                downloadDateEndRange: DateTime(2023, 3, 24, 20, 5, 32),
              ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by start/end video upload date', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
              selectedPlaylist: audioPlaylist,
              audioLst: audioLst,
              audioSortFilterParameters: AudioSortFilterParameters(
                selectedSortItemLst: [],
                filterSentenceLst: [],
                sentencesCombination: SentencesCombination.and,
                ignoreCase: true,
                searchAsWellInVideoCompactDescription: true,
                searchAsWellInYoutubeChannelName: false,
                uploadDateStartRange: DateTime(2023, 3, 1),
                uploadDateEndRange: DateTime(2023, 4, 1),
              ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by start/end download date and start/end video upload date',
        () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioThree,
      ];

      List<Audio> filteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
              selectedPlaylist: audioPlaylist,
              audioLst: audioLst,
              audioSortFilterParameters: AudioSortFilterParameters(
                selectedSortItemLst: [],
                filterSentenceLst: [],
                sentencesCombination: SentencesCombination.and,
                ignoreCase: true,
                searchAsWellInVideoCompactDescription: true,
                searchAsWellInYoutubeChannelName: false,
                downloadDateStartRange: DateTime(2023, 3, 24, 20, 5, 22),
                downloadDateEndRange: DateTime(2023, 3, 24, 20, 5, 32),
                uploadDateStartRange: DateTime(2023, 3, 1),
                uploadDateEndRange: DateTime(2023, 4, 1),
              ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
  });
  group('''filter test: by file size range or/and audio duration range.''', () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    test('filter by 110 MB to 130 MB file size range', () {
      List<Audio> expectedFilteredAudios = [audioOne, audioThree, audioFour];

      List<Audio> filteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
              selectedPlaylist: audioPlaylist,
              audioLst: audioLst,
              audioSortFilterParameters: AudioSortFilterParameters(
                selectedSortItemLst: [],
                filterSentenceLst: [],
                sentencesCombination: SentencesCombination.and,
                ignoreCase: true,
                searchAsWellInVideoCompactDescription: true,
                searchAsWellInYoutubeChannelName: false,
                fileSizeStartRangeMB: 110,
                fileSizeEndRangeMB: 130,
              ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('''filter by 0 MB to 110 MB file size range. This tests a bug fix.''',
        () {
      List<Audio> expectedFilteredAudios = [audioTwo, audioFour];

      List<Audio> filteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
              selectedPlaylist: audioPlaylist,
              audioLst: audioLst,
              audioSortFilterParameters: AudioSortFilterParameters(
                selectedSortItemLst: [],
                filterSentenceLst: [],
                sentencesCombination: SentencesCombination.and,
                ignoreCase: true,
                searchAsWellInVideoCompactDescription: true,
                searchAsWellInYoutubeChannelName: false,
                fileSizeStartRangeMB: 0,
                fileSizeEndRangeMB: 110,
              ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by 300 sec to 900 sec audio duration range', () {
      List<Audio> expectedFilteredAudios = [audioOne, audioFour];

      List<Audio> filteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
              selectedPlaylist: audioPlaylist,
              audioLst: audioLst,
              audioSortFilterParameters: AudioSortFilterParameters(
                selectedSortItemLst: [],
                filterSentenceLst: [],
                sentencesCombination: SentencesCombination.and,
                ignoreCase: true,
                searchAsWellInVideoCompactDescription: true,
                searchAsWellInYoutubeChannelName: false,
                fileSizeStartRangeMB: 110,
                fileSizeEndRangeMB: 130,
                durationStartRangeSec: 300,
                durationEndRangeSec: 900,
              ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test(
        '''filter by 0 sec to 540 sec audio duration range. This tests a bug fix.''',
        () {
      List<Audio> expectedFilteredAudios = [audioOne, audioFour];

      List<Audio> filteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
              selectedPlaylist: audioPlaylist,
              audioLst: audioLst,
              audioSortFilterParameters: AudioSortFilterParameters(
                selectedSortItemLst: [],
                filterSentenceLst: [],
                sentencesCombination: SentencesCombination.and,
                ignoreCase: true,
                searchAsWellInVideoCompactDescription: true,
                searchAsWellInYoutubeChannelName: false,
                fileSizeStartRangeMB: 110,
                fileSizeEndRangeMB: 130,
                durationStartRangeSec: 0,
                durationEndRangeSec: 540,
              ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by file size range and audio duration range', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioFour,
      ];

      List<Audio> filteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
              selectedPlaylist: audioPlaylist,
              audioLst: audioLst,
              audioSortFilterParameters: AudioSortFilterParameters(
                selectedSortItemLst: [],
                filterSentenceLst: [],
                sentencesCombination: SentencesCombination.and,
                ignoreCase: true,
                searchAsWellInVideoCompactDescription: true,
                searchAsWellInYoutubeChannelName: false,
                durationStartRangeSec: 300,
                durationEndRangeSec: 900,
              ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
  });
  group('sort audio lst by one SortingOption', () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    group('sort audio lst by title SortingOption', () {
      test('sort by title', () {
        final Audio zebra = Audio.fullConstructor(
          youtubeVideoChannel: 'three',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: 'Zebra ?',
          compactVideoDescription: '',
          validVideoTitle: 'Zebra',
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'Test Video Title.mp3',
          audioFileSize: 330000000,
          isAudioImported: false,
        );
        final Audio apple = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: 'Apple ?',
          compactVideoDescription: '',
          validVideoTitle: 'Apple',
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'Test Video Title.mp3',
          audioFileSize: 330000000,
          isAudioImported: false,
        );
        final Audio bananna = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: 'Bananna ?',
          compactVideoDescription: '',
          validVideoTitle: 'Bananna',
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'Test Video Title.mp3',
          audioFileSize: 330000000,
          isAudioImported: true,
        );

        List<Audio> audioList = [
          zebra,
          apple,
          bananna,
        ];

        List<Audio> expectedResultForTitleAsc = [
          apple,
          bananna,
          zebra,
        ];

        List<Audio> expectedResultForTitleDesc = [
          zebra,
          bananna,
          apple,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('sort by title containing _ number reference', () {
        final Audio thirdAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "La foi contre la peur (1_2 - Joyce Meyer -  Avoir des relations saines",
          compactVideoDescription: '',
          validVideoTitle:
              "La foi contre la peur (1_2 - Joyce Meyer -  Avoir des relations saines",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "La foi contre la peur (1_2 - Joyce Meyer -  Avoir des relations saines.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio thirdAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "La foi contre la peur (2_2 - Joyce Meyer -  Avoir des relations saines",
          compactVideoDescription: '',
          validVideoTitle:
              "La foi contre la peur (2_2 - Joyce Meyer -  Avoir des relations saines",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "La foi contre la peur (2_2 - Joyce Meyer -  Avoir des relations saines.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio secondAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (2_2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (2_2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Il est temps d'être sérieux avec Dieu ! (2_2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio secondAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (1_2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (1_2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Il est temps d'être sérieux avec Dieu ! (1_2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio fourthAudio = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio fifthAudio = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
          compactVideoDescription: '',
          validVideoTitle:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio firstAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Communiquer avec Dieu (1_2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Communiquer avec Dieu (1_2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Communiquer avec Dieu (1_2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio firstAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Communiquer avec Dieu (2_2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Communiquer avec Dieu (2_2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Communiquer avec Dieu (2_2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          thirdAudioOneOfTwo,
          thirdAudioTwoOfTwo,
          secondAudioTwoOfTwo,
          secondAudioOneOfTwo,
          fourthAudio,
          fifthAudio,
          firstAudioOneOfTwo,
          firstAudioTwoOfTwo,
        ];

        List<Audio> expectedResultForTitleAsc = [
          firstAudioOneOfTwo,
          firstAudioTwoOfTwo,
          secondAudioOneOfTwo,
          secondAudioTwoOfTwo,
          thirdAudioOneOfTwo,
          thirdAudioTwoOfTwo,
          fourthAudio,
          fifthAudio,
        ];

        List<Audio> expectedResultForTitleDesc = [
          fifthAudio,
          fourthAudio,
          thirdAudioTwoOfTwo,
          thirdAudioOneOfTwo,
          secondAudioTwoOfTwo,
          secondAudioOneOfTwo,
          firstAudioTwoOfTwo,
          firstAudioOneOfTwo,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('sort by title containing - number reference', () {
        final Audio thirdAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "La foi contre la peur (1-2 - Joyce Meyer -  Avoir des relations saines",
          compactVideoDescription: '',
          validVideoTitle:
              "La foi contre la peur (1-2 - Joyce Meyer -  Avoir des relations saines",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "La foi contre la peur (1-2 - Joyce Meyer -  Avoir des relations saines.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio thirdAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "La foi contre la peur (2-2 - Joyce Meyer -  Avoir des relations saines",
          compactVideoDescription: '',
          validVideoTitle:
              "La foi contre la peur (2-2 - Joyce Meyer -  Avoir des relations saines",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "La foi contre la peur (2-2 - Joyce Meyer -  Avoir des relations saines.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio secondAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (2-2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (2-2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Il est temps d'être sérieux avec Dieu ! (2-2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio secondAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (1-2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (1-2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Il est temps d'être sérieux avec Dieu ! (1-2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio fourthAudio = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio fifthAudio = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
          compactVideoDescription: '',
          validVideoTitle:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio firstAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Communiquer avec Dieu (1-2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Communiquer avec Dieu (1-2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Communiquer avec Dieu (1-2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio firstAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Communiquer avec Dieu (2-2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Communiquer avec Dieu (2-2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Communiquer avec Dieu (2-2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          thirdAudioOneOfTwo,
          thirdAudioTwoOfTwo,
          secondAudioTwoOfTwo,
          secondAudioOneOfTwo,
          fourthAudio,
          fifthAudio,
          firstAudioOneOfTwo,
          firstAudioTwoOfTwo,
        ];

        List<Audio> expectedResultForTitleAsc = [
          firstAudioOneOfTwo,
          firstAudioTwoOfTwo,
          secondAudioOneOfTwo,
          secondAudioTwoOfTwo,
          thirdAudioOneOfTwo,
          thirdAudioTwoOfTwo,
          fourthAudio,
          fifthAudio,
        ];

        List<Audio> expectedResultForTitleDesc = [
          fifthAudio,
          fourthAudio,
          thirdAudioTwoOfTwo,
          thirdAudioOneOfTwo,
          secondAudioTwoOfTwo,
          secondAudioOneOfTwo,
          firstAudioTwoOfTwo,
          firstAudioOneOfTwo,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('sort by title containing / number reference', () {
        final Audio thirdAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "La foi contre la peur (1/2 - Joyce Meyer -  Avoir des relations saines",
          compactVideoDescription: '',
          validVideoTitle:
              "La foi contre la peur (1/2 - Joyce Meyer -  Avoir des relations saines",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "La foi contre la peur (1/2 - Joyce Meyer -  Avoir des relations saines.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio thirdAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "La foi contre la peur (2/2 - Joyce Meyer -  Avoir des relations saines",
          compactVideoDescription: '',
          validVideoTitle:
              "La foi contre la peur (2/2 - Joyce Meyer -  Avoir des relations saines",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "La foi contre la peur (2/2 - Joyce Meyer -  Avoir des relations saines.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio secondAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (2/2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (2/2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Il est temps d'être sérieux avec Dieu ! (2/2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio secondAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (1/2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (1/2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Il est temps d'être sérieux avec Dieu ! (1/2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio fourthAudio = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio fifthAudio = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
          compactVideoDescription: '',
          validVideoTitle:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio firstAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Communiquer avec Dieu (1/2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Communiquer avec Dieu (1/2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Communiquer avec Dieu (1/2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio firstAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Communiquer avec Dieu (2/2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Communiquer avec Dieu (2/2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Communiquer avec Dieu (2/2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          thirdAudioOneOfTwo,
          thirdAudioTwoOfTwo,
          secondAudioTwoOfTwo,
          secondAudioOneOfTwo,
          fourthAudio,
          fifthAudio,
          firstAudioOneOfTwo,
          firstAudioTwoOfTwo,
        ];

        List<Audio> expectedResultForTitleAsc = [
          firstAudioOneOfTwo,
          firstAudioTwoOfTwo,
          secondAudioOneOfTwo,
          secondAudioTwoOfTwo,
          thirdAudioOneOfTwo,
          thirdAudioTwoOfTwo,
          fourthAudio,
          fifthAudio,
        ];

        List<Audio> expectedResultForTitleDesc = [
          fifthAudio,
          fourthAudio,
          thirdAudioTwoOfTwo,
          thirdAudioOneOfTwo,
          secondAudioTwoOfTwo,
          secondAudioOneOfTwo,
          firstAudioTwoOfTwo,
          firstAudioOneOfTwo,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('sort by title containing : number reference', () {
        final Audio thirdAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "La foi contre la peur (1:2 - Joyce Meyer -  Avoir des relations saines",
          compactVideoDescription: '',
          validVideoTitle:
              "La foi contre la peur (1:2 - Joyce Meyer -  Avoir des relations saines",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "La foi contre la peur (1:2 - Joyce Meyer -  Avoir des relations saines.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio thirdAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "La foi contre la peur (2:2 - Joyce Meyer -  Avoir des relations saines",
          compactVideoDescription: '',
          validVideoTitle:
              "La foi contre la peur (2:2 - Joyce Meyer -  Avoir des relations saines",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "La foi contre la peur (2:2 - Joyce Meyer -  Avoir des relations saines.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio secondAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (2:2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (2:2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Il est temps d'être sérieux avec Dieu ! (2:2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio secondAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (1:2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Il est temps d'être sérieux avec Dieu ! (1:2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Il est temps d'être sérieux avec Dieu ! (1:2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio fourthAudio = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio fifthAudio = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
          compactVideoDescription: '',
          validVideoTitle:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio firstAudioOneOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Communiquer avec Dieu (1:2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Communiquer avec Dieu (1:2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Communiquer avec Dieu (1:2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio firstAudioTwoOfTwo = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Communiquer avec Dieu (2:2 - Joyce Meyer - Grandir avec Dieu",
          compactVideoDescription: '',
          validVideoTitle:
              "Communiquer avec Dieu (2:2 - Joyce Meyer - Grandir avec Dieu",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Communiquer avec Dieu (2:2 - Joyce Meyer - Grandir avec Dieu.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          thirdAudioOneOfTwo,
          thirdAudioTwoOfTwo,
          secondAudioTwoOfTwo,
          secondAudioOneOfTwo,
          fourthAudio,
          fifthAudio,
          firstAudioOneOfTwo,
          firstAudioTwoOfTwo,
        ];

        List<Audio> expectedResultForTitleAsc = [
          firstAudioOneOfTwo,
          firstAudioTwoOfTwo,
          secondAudioOneOfTwo,
          secondAudioTwoOfTwo,
          thirdAudioOneOfTwo,
          thirdAudioTwoOfTwo,
          fourthAudio,
          fifthAudio,
        ];

        List<Audio> expectedResultForTitleDesc = [
          fifthAudio,
          fourthAudio,
          thirdAudioTwoOfTwo,
          thirdAudioOneOfTwo,
          secondAudioTwoOfTwo,
          secondAudioOneOfTwo,
          firstAudioTwoOfTwo,
          firstAudioOneOfTwo,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''sort by edited title with chapter number. The valid video titles of
            the audio contained in the 'Gary Renard - Et l'univers disparaîtra'
            json file were edited in order for their titles to be sorted correctly
            before the SortingOption.validAudioTitle sort function was improved.''',
          () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_filter_unit_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Load Playlist from the file
        Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}Gary Renard - Et l'univers disparaîtra.json",
          type: Playlist,
        );

        List<Audio> audioList = loadedPlaylist.playableAudioLst;

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> actualAudioSortedByTitleAscLst =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        List<String> actualAudioSortedByTitleAscStrLst =
            actualAudioSortedByTitleAscLst
                .map((audio) => audio.validVideoTitle)
                .toList();

        // Load the expected sorted audio list from the file
        List<Audio> expectedAudioSortedByTitleAscLst =
            JsonDataService.loadListFromFile(
          jsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list asc Et l'univers disparaîtra.json",
          type: Audio,
        );

        List<String> expectedAudioSortedByTitleAscStrLst =
            expectedAudioSortedByTitleAscLst
                .map((audio) => audio.validVideoTitle)
                .toList();

        expect(
          actualAudioSortedByTitleAscStrLst,
          expectedAudioSortedByTitleAscStrLst,
        );

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> actualAudioSortedByTitleDescLst =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        List<String> actualAudioSortedByTitleDescStrLst =
            actualAudioSortedByTitleDescLst
                .map((audio) => audio.validVideoTitle)
                .toList();

        // Load the expected sorted audio list from the file
        List<Audio> expectedAudioSortedByTitleDescLst =
            JsonDataService.loadListFromFile(
          jsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list desc Et l'univers disparaîtra.json",
          type: Audio,
        );

        List<String> expectedAudioSortedByTitleDescStrLst =
            expectedAudioSortedByTitleDescLst
                .map((audio) => audio.validVideoTitle)
                .toList();

        expect(
          actualAudioSortedByTitleDescStrLst,
          expectedAudioSortedByTitleDescStrLst,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });

      test('sort by title starting with non language chars', () {
        Audio title = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "'title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "'title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio avecPercentTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "%avec percent title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "%avec percent title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio percentTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "%percent title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "%percent title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio powerTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "power title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "power title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio amenTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "#'amen title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "#'amen title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: true,
        );

        Audio epicure = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "ÉPICURE - La mort n'est rien 📏",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "ÉPICURE - La mort n'est rien",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio ninetyFiveTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "%95 title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "%95 title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: true,
        );

        Audio ninetyThreeTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "93 title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "93 title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio ninetyFourTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "#94 title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "#94 title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: true,
        );

        Audio echapper = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "Échapper à l'illusion de l'esprit",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "Échapper à l'illusion de l'esprit",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio evidentTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "évident title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "évident title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: true,
          audioPlaySpeed: 1.0,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: true,
        );

        Audio aLireTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "à lire title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "à lire title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio nineTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "9 title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "9 title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
          isPaused: true,
          audioPausedDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioPositionSeconds: 500,
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 10000),
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio eightTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "8 title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "8 title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          audioDownloadDuration: const Duration(seconds: 1),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
          isPaused: true,
          audioPausedDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioPositionSeconds: 500,
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 10000),
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: false,
        );

        Audio eventuelTitle = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle: "éventuel title",
          compactVideoDescription: 'compactVideoDescription',
          validVideoTitle: "éventuel title",
          videoUrl: 'videoUrl',
          audioDownloadDateTime: DateTime.now(),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioDownloadDuration: const Duration(seconds: 1),
          audioDownloadSpeed: 1,
          videoUploadDate: DateTime.now(),
          audioDuration: const Duration(seconds: 1),
          audioFileName: 'audioFileName',
          audioFileSize: 1,
          isAudioImported: true,
        );

        List<Audio?> audioLst = [
          title,
          avecPercentTitle,
          percentTitle,
          powerTitle,
          amenTitle,
          epicure,
          ninetyFiveTitle,
          ninetyThreeTitle,
          ninetyFourTitle,
          echapper,
          evidentTitle,
          aLireTitle,
          nineTitle,
          eightTitle,
          eventuelTitle,
        ];

        List<Audio?> expectedResultForTitleAsc = [
          amenTitle,
          ninetyFourTitle,
          ninetyFiveTitle,
          avecPercentTitle,
          percentTitle,
          title,
          eightTitle,
          nineTitle,
          ninetyThreeTitle,
          powerTitle,
          aLireTitle,
          echapper,
          epicure,
          eventuelTitle,
          evidentTitle,
        ];

        List<Audio?> expectedResultForTitleDesc = [
          evidentTitle,
          eventuelTitle,
          epicure,
          echapper,
          aLireTitle,
          powerTitle,
          ninetyThreeTitle,
          nineTitle,
          eightTitle,
          title,
          percentTitle,
          avecPercentTitle,
          ninetyFiveTitle,
          ninetyFourTitle,
          amenTitle,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: List<Audio>.from(audioLst), // copy list
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio!.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.validAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: List<Audio>.from(audioLst), // copy list
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio!.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });

    group('sort audio lst by chapter SortingOption', () {
      test('''sort by _ chapter title number. Example: ... 1_1 ..., ... 1_2 ...,
            ... 2_1 ...''', () {
        final Audio avantPropos = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 1_37  - Avant - propos de l'éditeur américain",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 1_37  - Avant - propos de l'éditeur américain",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 1_37  - Avant - propos de l'éditeur américain.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio note = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 2_37  - Note et remerciements de l'auteur",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 2_37  - Note et remerciements de l'auteur",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 2_37  - Note et remerciements de l'auteur.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3_37  - Partie 1 chapitre 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3_37  - Partie 1 chapitre 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 3_37  - Partie 1 chapitre 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4_37  - chapitre 2-1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4_37  - chapitre 2-1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 4_37  - chapitre 2-1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5_37  - chapitre 2 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5_37  - chapitre 2 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 5_37  - chapitre 2 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_3 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6_37  - chapitre 2 - 3",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6_37  - chapitre 2 - 3",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 6_37  - chapitre 2 - 3.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10_37  - chapitre 3 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10_37  - chapitre 3 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 10_37  - chapitre 3 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11_37  - chapitre 3 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11_37  - chapitre 3 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 11_37  - chapitre 3 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_4_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13_37  - chapitre 4 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13_37  - chapitre 4 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 13_37  - chapitre 4 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_5_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16_37  - Chapitre 5 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16_37  - Chapitre 5 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 16_37  - Chapitre 5 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21_37  - Partie 2 chapitre 6 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21_37  - Partie 2 chapitre 6 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 21_37  - Partie 2 chapitre 6 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22_37  - chapitre 6 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22_37  - chapitre 6 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 22_37  - chapitre 6 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_8 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26_37  - chapitre 8",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26_37  - chapitre 8",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 26_37  - chapitre 8.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_9_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27_37  - chapitre 9 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27_37  - chapitre 9 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 27_37  - chapitre 9 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_10 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29_37  - chapitre 10",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29_37  - chapitre 10",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 29_37  - chapitre 10.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30_37  - chapitre 11 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30_37  - chapitre 11 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 30_37  - chapitre 11 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31_37  - chapitre 11 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31_37  - chapitre 11 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 31_37  - chapitre 11 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_12 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32_37  - chapitre 12",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32_37  - chapitre 12",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 32_37  - chapitre 12.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_13 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33_37  - chapitre 13",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33_37  - chapitre 13",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 33_37  - chapitre 13.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleAsc = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleDesc = [
          chap_13,
          chap_12,
          chap_11_2,
          chap_11_1,
          chap_10,
          chap_9_1,
          chap_8,
          chap_6_2,
          chap_6_1,
          chap_5_1,
          chap_4_1,
          chap_3_2,
          chap_3_1,
          chap_2_3,
          chap_2_2,
          chap_2_1,
          chap_1,
          note,
          avantPropos,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by - chapter title number. Example: ... 1-1 ..., ... 1-2 ...,
            ... 2-1 ...''', () {
        final Audio avantPropos = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 1-37  - Avant - propos de l'éditeur américain",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 1-37  - Avant - propos de l'éditeur américain",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 1-37  - Avant - propos de l'éditeur américain.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio note = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 2-37  - Note et remerciements de l'auteur",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 2-37  - Note et remerciements de l'auteur",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 2-37  - Note et remerciements de l'auteur.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3-37  - Partie 1 chapitre 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3-37  - Partie 1 chapitre 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 3-37  - Partie 1 chapitre 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4-37  - chapitre 2-1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4-37  - chapitre 2-1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 4-37  - chapitre 2-1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5-37  - chapitre 2 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5-37  - chapitre 2 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 5-37  - chapitre 2 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_3 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6-37  - chapitre 2 - 3",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6-37  - chapitre 2 - 3",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 6-37  - chapitre 2 - 3.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10-37  - chapitre 3 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10-37  - chapitre 3 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 10-37  - chapitre 3 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11-37  - chapitre 3 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11-37  - chapitre 3 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 11-37  - chapitre 3 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_4_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13-37  - chapitre 4 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13-37  - chapitre 4 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 13-37  - chapitre 4 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_5_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16-37  - Chapitre 5 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16-37  - Chapitre 5 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 16-37  - Chapitre 5 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21-37  - Partie 2 chapitre 6 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21-37  - Partie 2 chapitre 6 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 21-37  - Partie 2 chapitre 6 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22-37  - chapitre 6 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22-37  - chapitre 6 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 22-37  - chapitre 6 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_8 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26-37  - chapitre 8",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26-37  - chapitre 8",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 26-37  - chapitre 8.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_9_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27-37  - chapitre 9 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27-37  - chapitre 9 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 27-37  - chapitre 9 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_10 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29-37  - chapitre 10",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29-37  - chapitre 10",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 29-37  - chapitre 10.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30-37  - chapitre 11 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30-37  - chapitre 11 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 30-37  - chapitre 11 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31-37  - chapitre 11 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31-37  - chapitre 11 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 31-37  - chapitre 11 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_12 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32-37  - chapitre 12",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32-37  - chapitre 12",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 32-37  - chapitre 12.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_13 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33-37  - chapitre 13",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33-37  - chapitre 13",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 33-37  - chapitre 13.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleAsc = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleDesc = [
          chap_13,
          chap_12,
          chap_11_2,
          chap_11_1,
          chap_10,
          chap_9_1,
          chap_8,
          chap_6_2,
          chap_6_1,
          chap_5_1,
          chap_4_1,
          chap_3_2,
          chap_3_1,
          chap_2_3,
          chap_2_2,
          chap_2_1,
          chap_1,
          note,
          avantPropos,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by / chapter title number. Example: ... 1/1 ..., ... 1/2 ...,
            ... 2/1 ...''', () {
        final Audio avantPropos = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 1/37  - Avant - propos de l'éditeur américain",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 1/37  - Avant - propos de l'éditeur américain",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 1/37  - Avant - propos de l'éditeur américain.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio note = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 2/37  - Note et remerciements de l'auteur",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 2/37  - Note et remerciements de l'auteur",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 2/37  - Note et remerciements de l'auteur.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3/37  - Partie 1 chapitre 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3/37  - Partie 1 chapitre 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 3/37  - Partie 1 chapitre 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4/37  - chapitre 2-1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4/37  - chapitre 2-1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 4/37  - chapitre 2-1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5/37  - chapitre 2 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5/37  - chapitre 2 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 5/37  - chapitre 2 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_3 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6/37  - chapitre 2 - 3",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6/37  - chapitre 2 - 3",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 6/37  - chapitre 2 - 3.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10/37  - chapitre 3 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10/37  - chapitre 3 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 10/37  - chapitre 3 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11/37  - chapitre 3 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11/37  - chapitre 3 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 11/37  - chapitre 3 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_4_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13/37  - chapitre 4 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13/37  - chapitre 4 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 13/37  - chapitre 4 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_5_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16/37  - Chapitre 5 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16/37  - Chapitre 5 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 16/37  - Chapitre 5 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21/37  - Partie 2 chapitre 6 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21/37  - Partie 2 chapitre 6 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 21/37  - Partie 2 chapitre 6 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22/37  - chapitre 6 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22/37  - chapitre 6 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 22/37  - chapitre 6 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_8 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26/37  - chapitre 8",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26/37  - chapitre 8",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 26/37  - chapitre 8.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_9_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27/37  - chapitre 9 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27/37  - chapitre 9 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 27/37  - chapitre 9 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_10 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29/37  - chapitre 10",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29/37  - chapitre 10",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 29/37  - chapitre 10.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30/37  - chapitre 11 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30/37  - chapitre 11 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 30/37  - chapitre 11 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31/37  - chapitre 11 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31/37  - chapitre 11 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 31/37  - chapitre 11 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_12 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32/37  - chapitre 12",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32/37  - chapitre 12",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 32/37  - chapitre 12.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_13 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33/37  - chapitre 13",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33/37  - chapitre 13",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 33/37  - chapitre 13.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleAsc = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleDesc = [
          chap_13,
          chap_12,
          chap_11_2,
          chap_11_1,
          chap_10,
          chap_9_1,
          chap_8,
          chap_6_2,
          chap_6_1,
          chap_5_1,
          chap_4_1,
          chap_3_2,
          chap_3_1,
          chap_2_3,
          chap_2_2,
          chap_2_1,
          chap_1,
          note,
          avantPropos,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by : chapter title number. Example: ... 1:1 ..., ... 1:2 ...,
            ... 2:1 ...''', () {
        final Audio avantPropos = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 1:37  - Avant - propos de l'éditeur américain",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 1:37  - Avant - propos de l'éditeur américain",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 1:37  - Avant - propos de l'éditeur américain.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio note = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 2:37  - Note et remerciements de l'auteur",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 2:37  - Note et remerciements de l'auteur",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 2:37  - Note et remerciements de l'auteur.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3:37  - Partie 1 chapitre 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3:37  - Partie 1 chapitre 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 3:37  - Partie 1 chapitre 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4:37  - chapitre 2-1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4:37  - chapitre 2-1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 4:37  - chapitre 2-1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5:37  - chapitre 2 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5:37  - chapitre 2 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 5:37  - chapitre 2 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_3 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6:37  - chapitre 2 - 3",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6:37  - chapitre 2 - 3",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 6:37  - chapitre 2 - 3.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10:37  - chapitre 3 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10:37  - chapitre 3 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 10:37  - chapitre 3 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11:37  - chapitre 3 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11:37  - chapitre 3 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 11:37  - chapitre 3 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_4_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13:37  - chapitre 4 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13:37  - chapitre 4 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 13:37  - chapitre 4 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_5_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16:37  - Chapitre 5 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16:37  - Chapitre 5 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 16:37  - Chapitre 5 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21:37  - Partie 2 chapitre 6 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21:37  - Partie 2 chapitre 6 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 21:37  - Partie 2 chapitre 6 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22:37  - chapitre 6 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22:37  - chapitre 6 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 22:37  - chapitre 6 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_8 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26:37  - chapitre 8",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26:37  - chapitre 8",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 26:37  - chapitre 8.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_9_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27:37  - chapitre 9 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27:37  - chapitre 9 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 27:37  - chapitre 9 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_10 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29:37  - chapitre 10",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29:37  - chapitre 10",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 29:37  - chapitre 10.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30:37  - chapitre 11 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30:37  - chapitre 11 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 30:37  - chapitre 11 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31:37  - chapitre 11 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31:37  - chapitre 11 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 31:37  - chapitre 11 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_12 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32:37  - chapitre 12",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32:37  - chapitre 12",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 32:37  - chapitre 12.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_13 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33:37  - chapitre 13",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33:37  - chapitre 13",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 33:37  - chapitre 13.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleAsc = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleDesc = [
          chap_13,
          chap_12,
          chap_11_2,
          chap_11_1,
          chap_10,
          chap_9_1,
          chap_8,
          chap_6_2,
          chap_6_1,
          chap_5_1,
          chap_4_1,
          chap_3_2,
          chap_3_1,
          chap_2_3,
          chap_2_2,
          chap_2_1,
          chap_1,
          note,
          avantPropos,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by _ chapter title number. The order of the list of audio to
            sort (included in the variable audioList below) was modified.''',
          () {
        final Audio avantPropos = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 1_37  - Avant - propos de l'éditeur américain",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 1_37  - Avant - propos de l'éditeur américain",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 1_37  - Avant - propos de l'éditeur américain.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio note = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 2_37  - Note et remerciements de l'auteur",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 2_37  - Note et remerciements de l'auteur",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 2_37  - Note et remerciements de l'auteur.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3_37  - Partie 1 chapitre 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3_37  - Partie 1 chapitre 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 3_37  - Partie 1 chapitre 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4_37  - chapitre 2-1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4_37  - chapitre 2-1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 4_37  - chapitre 2-1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5_37  - chapitre 2 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5_37  - chapitre 2 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 5_37  - chapitre 2 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_3 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6_37  - chapitre 2 - 3",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6_37  - chapitre 2 - 3",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 6_37  - chapitre 2 - 3.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10_37  - chapitre 3 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10_37  - chapitre 3 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 10_37  - chapitre 3 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11_37  - chapitre 3 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11_37  - chapitre 3 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 11_37  - chapitre 3 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_4_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13_37  - chapitre 4 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13_37  - chapitre 4 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 13_37  - chapitre 4 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_5_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16_37  - Chapitre 5 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16_37  - Chapitre 5 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 16_37  - Chapitre 5 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21_37  - Partie 2 chapitre 6 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21_37  - Partie 2 chapitre 6 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 21_37  - Partie 2 chapitre 6 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22_37  - chapitre 6 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22_37  - chapitre 6 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 22_37  - chapitre 6 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_8 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26_37  - chapitre 8",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26_37  - chapitre 8",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 26_37  - chapitre 8.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_9_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27_37  - chapitre 9 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27_37  - chapitre 9 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 27_37  - chapitre 9 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_10 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29_37  - chapitre 10",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29_37  - chapitre 10",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 29_37  - chapitre 10.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30_37  - chapitre 11 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30_37  - chapitre 11 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 30_37  - chapitre 11 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31_37  - chapitre 11 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31_37  - chapitre 11 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 31_37  - chapitre 11 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_12 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32_37  - chapitre 12",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32_37  - chapitre 12",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 32_37  - chapitre 12.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_13 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33_37  - chapitre 13",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33_37  - chapitre 13",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 33_37  - chapitre 13.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          note,
          chap_10,
          chap_1,
          chap_5_1,
          chap_2_2,
          chap_6_1,
          chap_2_1,
          chap_2_3,
          avantPropos,
          chap_3_1,
          chap_3_2,
          chap_11_1,
          chap_11_2,
          chap_4_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleAsc = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleDesc = [
          chap_13,
          chap_12,
          chap_11_2,
          chap_11_1,
          chap_10,
          chap_9_1,
          chap_8,
          chap_6_2,
          chap_6_1,
          chap_5_1,
          chap_4_1,
          chap_3_2,
          chap_3_1,
          chap_2_3,
          chap_2_2,
          chap_2_1,
          chap_1,
          note,
          avantPropos,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by - chapter title number. The order of the list of audio to
            sort (included in the variable audioList below) was modified.''',
          () {
        final Audio avantPropos = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 1-37  - Avant - propos de l'éditeur américain",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 1-37  - Avant - propos de l'éditeur américain",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 1-37  - Avant - propos de l'éditeur américain.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio note = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 2-37  - Note et remerciements de l'auteur",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 2-37  - Note et remerciements de l'auteur",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 2-37  - Note et remerciements de l'auteur.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3-37  - Partie 1 chapitre 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3-37  - Partie 1 chapitre 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 3-37  - Partie 1 chapitre 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4-37  - chapitre 2-1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4-37  - chapitre 2-1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 4-37  - chapitre 2-1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5-37  - chapitre 2 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5-37  - chapitre 2 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 5-37  - chapitre 2 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_3 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6-37  - chapitre 2 - 3",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6-37  - chapitre 2 - 3",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 6-37  - chapitre 2 - 3.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10-37  - chapitre 3 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10-37  - chapitre 3 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 10-37  - chapitre 3 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11-37  - chapitre 3 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11-37  - chapitre 3 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 11-37  - chapitre 3 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_4_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13-37  - chapitre 4 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13-37  - chapitre 4 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 13-37  - chapitre 4 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_5_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16-37  - Chapitre 5 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16-37  - Chapitre 5 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 16-37  - Chapitre 5 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21-37  - Partie 2 chapitre 6 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21-37  - Partie 2 chapitre 6 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 21-37  - Partie 2 chapitre 6 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22-37  - chapitre 6 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22-37  - chapitre 6 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 22-37  - chapitre 6 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_8 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26-37  - chapitre 8",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26-37  - chapitre 8",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 26-37  - chapitre 8.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_9_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27-37  - chapitre 9 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27-37  - chapitre 9 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 27-37  - chapitre 9 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_10 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29-37  - chapitre 10",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29-37  - chapitre 10",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 29-37  - chapitre 10.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30-37  - chapitre 11 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30-37  - chapitre 11 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 30-37  - chapitre 11 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31-37  - chapitre 11 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31-37  - chapitre 11 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 31-37  - chapitre 11 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_12 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32-37  - chapitre 12",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32-37  - chapitre 12",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 32-37  - chapitre 12.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_13 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33-37  - chapitre 13",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33-37  - chapitre 13",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 33-37  - chapitre 13.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          note,
          chap_10,
          chap_1,
          chap_5_1,
          chap_2_2,
          chap_6_1,
          chap_2_1,
          chap_2_3,
          avantPropos,
          chap_3_1,
          chap_3_2,
          chap_11_1,
          chap_11_2,
          chap_4_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleAsc = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleDesc = [
          chap_13,
          chap_12,
          chap_11_2,
          chap_11_1,
          chap_10,
          chap_9_1,
          chap_8,
          chap_6_2,
          chap_6_1,
          chap_5_1,
          chap_4_1,
          chap_3_2,
          chap_3_1,
          chap_2_3,
          chap_2_2,
          chap_2_1,
          chap_1,
          note,
          avantPropos,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by / chapter title number. Example: ... 1/1 ..., ... 1/2 ...,
            ... 2/1 ... . The order of the list of audio to sort (included in the
            variable audioList below) was modified.''', () {
        final Audio avantPropos = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 1/37  - Avant - propos de l'éditeur américain",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 1/37  - Avant - propos de l'éditeur américain",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 1/37  - Avant - propos de l'éditeur américain.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio note = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 2/37  - Note et remerciements de l'auteur",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 2/37  - Note et remerciements de l'auteur",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 2/37  - Note et remerciements de l'auteur.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3/37  - Partie 1 chapitre 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3/37  - Partie 1 chapitre 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 3/37  - Partie 1 chapitre 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4/37  - chapitre 2-1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4/37  - chapitre 2-1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 4/37  - chapitre 2-1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5/37  - chapitre 2 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5/37  - chapitre 2 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 5/37  - chapitre 2 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_3 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6/37  - chapitre 2 - 3",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6/37  - chapitre 2 - 3",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 6/37  - chapitre 2 - 3.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10/37  - chapitre 3 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10/37  - chapitre 3 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 10/37  - chapitre 3 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11/37  - chapitre 3 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11/37  - chapitre 3 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 11/37  - chapitre 3 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_4_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13/37  - chapitre 4 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13/37  - chapitre 4 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 13/37  - chapitre 4 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_5_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16/37  - Chapitre 5 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16/37  - Chapitre 5 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 16/37  - Chapitre 5 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21/37  - Partie 2 chapitre 6 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21/37  - Partie 2 chapitre 6 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 21/37  - Partie 2 chapitre 6 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22/37  - chapitre 6 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22/37  - chapitre 6 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 22/37  - chapitre 6 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_8 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26/37  - chapitre 8",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26/37  - chapitre 8",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 26/37  - chapitre 8.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_9_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27/37  - chapitre 9 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27/37  - chapitre 9 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 27/37  - chapitre 9 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_10 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29/37  - chapitre 10",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29/37  - chapitre 10",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 29/37  - chapitre 10.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30/37  - chapitre 11 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30/37  - chapitre 11 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 30/37  - chapitre 11 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31/37  - chapitre 11 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31/37  - chapitre 11 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 31/37  - chapitre 11 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_12 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32/37  - chapitre 12",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32/37  - chapitre 12",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 32/37  - chapitre 12.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_13 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33/37  - chapitre 13",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33/37  - chapitre 13",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 33/37  - chapitre 13.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          note,
          chap_10,
          chap_1,
          chap_5_1,
          chap_2_2,
          chap_6_1,
          chap_2_1,
          chap_2_3,
          avantPropos,
          chap_3_1,
          chap_3_2,
          chap_11_1,
          chap_11_2,
          chap_4_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleAsc = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleDesc = [
          chap_13,
          chap_12,
          chap_11_2,
          chap_11_1,
          chap_10,
          chap_9_1,
          chap_8,
          chap_6_2,
          chap_6_1,
          chap_5_1,
          chap_4_1,
          chap_3_2,
          chap_3_1,
          chap_2_3,
          chap_2_2,
          chap_2_1,
          chap_1,
          note,
          avantPropos,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by : chapter title number. Example: ... 1:1 ..., ... 1:2 ...,
            ... 2:1 ... . The order of the list of audio to sort (included in the
            variable audioList below) was modified.''', () {
        final Audio avantPropos = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 1:37  - Avant - propos de l'éditeur américain",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 1:37  - Avant - propos de l'éditeur américain",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 1:37  - Avant - propos de l'éditeur américain.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio note = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra 2:37  - Note et remerciements de l'auteur",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra 2:37  - Note et remerciements de l'auteur",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra 2:37  - Note et remerciements de l'auteur.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3:37  - Partie 1 chapitre 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 3:37  - Partie 1 chapitre 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 3:37  - Partie 1 chapitre 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4:37  - chapitre 2-1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 4:37  - chapitre 2-1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 4:37  - chapitre 2-1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5:37  - chapitre 2 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 5:37  - chapitre 2 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 5:37  - chapitre 2 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_2_3 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6:37  - chapitre 2 - 3",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 6:37  - chapitre 2 - 3",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 6:37  - chapitre 2 - 3.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10:37  - chapitre 3 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 10:37  - chapitre 3 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 10:37  - chapitre 3 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_3_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11:37  - chapitre 3 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 11:37  - chapitre 3 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 11:37  - chapitre 3 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_4_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13:37  - chapitre 4 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 13:37  - chapitre 4 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 13:37  - chapitre 4 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_5_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16:37  - Chapitre 5 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 16:37  - Chapitre 5 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 16:37  - Chapitre 5 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21:37  - Partie 2 chapitre 6 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 21:37  - Partie 2 chapitre 6 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 21:37  - Partie 2 chapitre 6 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_6_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22:37  - chapitre 6 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 22:37  - chapitre 6 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 22:37  - chapitre 6 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_8 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26:37  - chapitre 8",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 26:37  - chapitre 8",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 26:37  - chapitre 8.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_9_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27:37  - chapitre 9 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 27:37  - chapitre 9 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 27:37  - chapitre 9 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_10 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29:37  - chapitre 10",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 29:37  - chapitre 10",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 29:37  - chapitre 10.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_1 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30:37  - chapitre 11 - 1",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 30:37  - chapitre 11 - 1",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 30:37  - chapitre 11 - 1.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_11_2 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31:37  - chapitre 11 - 2",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 31:37  - chapitre 11 - 2",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 31:37  - chapitre 11 - 2.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_12 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32:37  - chapitre 12",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 32:37  - chapitre 12",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 32:37  - chapitre 12.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        final Audio chap_13 = Audio.fullConstructor(
          youtubeVideoChannel: 'one',
          enclosingPlaylist: audioPlaylist,
          movedFromPlaylistTitle: null,
          movedToPlaylistTitle: null,
          copiedFromPlaylistTitle: null,
          copiedToPlaylistTitle: null,
          originalVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33:37  - chapitre 13",
          compactVideoDescription: '',
          validVideoTitle:
              "Audio Et l'Univers disparaitra de Gary Renard 33:37  - chapitre 13",
          videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
          audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
          audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
          audioDownloadSpeed: 1000000,
          videoUploadDate: DateTime(2023, 3, 1),
          audioDuration: const Duration(minutes: 5, seconds: 30),
          isAudioMusicQuality: false,
          audioPlaySpeed: kAudioDefaultPlaySpeed,
          audioPlayVolume: kAudioDefaultPlayVolume,
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
          isPaused: true,
          audioPausedDateTime: null,
          audioPositionSeconds: 0,
          audioFileName:
              "Audio Et l'Univers disparaitra de Gary Renard 33:37  - chapitre 13.mp3",
          audioFileSize: 330000000,
          isAudioImported: false,
        );

        List<Audio> audioList = [
          note,
          chap_10,
          chap_1,
          chap_5_1,
          chap_2_2,
          chap_6_1,
          chap_2_1,
          chap_2_3,
          avantPropos,
          chap_3_1,
          chap_3_2,
          chap_11_1,
          chap_11_2,
          chap_4_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleAsc = [
          avantPropos,
          note,
          chap_1,
          chap_2_1,
          chap_2_2,
          chap_2_3,
          chap_3_1,
          chap_3_2,
          chap_4_1,
          chap_5_1,
          chap_6_1,
          chap_6_2,
          chap_8,
          chap_9_1,
          chap_10,
          chap_11_1,
          chap_11_2,
          chap_12,
          chap_13,
        ];

        List<Audio> expectedResultForTitleDesc = [
          chap_13,
          chap_12,
          chap_11_2,
          chap_11_1,
          chap_10,
          chap_9_1,
          chap_8,
          chap_6_2,
          chap_6_1,
          chap_5_1,
          chap_4_1,
          chap_3_2,
          chap_3_1,
          chap_2_3,
          chap_2_2,
          chap_2_1,
          chap_1,
          note,
          avantPropos,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> sortedByTitleDesc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        expect(
            sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleDesc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by ' à ' chapter title number. Example: chapitre 1 à 5,
            Chapitre 6 à 10, chapitre 11 à 15''', () {
        final Audio one = Audio.fullConstructor(
            enclosingPlaylist: audioPlaylist,
            audioDownloadDateTime: DateTime(2025, 03, 01, 20, 15, 58),
            audioDownloadDuration: const Duration(milliseconds: 10503),
            audioDownloadSpeed: 474501,
            audioDuration: const Duration(milliseconds: 817203),
            audioFileName:
                "250301-201558-Livre Audio Imitation du Christ Livre 1 Chapitre 1 \u00e0 5 23-08-27.mp3",
            audioFileSize: 4983815,
            audioPausedDateTime: null,
            audioPlaySpeed: 1.0,
            audioPlayVolume: 0.5,
            audioPositionSeconds: 0,
            compactVideoDescription:
                "La voie de Dieu par la voix des saints\n\nChapitre 1: Qu'il faut imiter J\u00e9sus-Christ, et m\u00e9priser toutes les vanit\u00e9s du monde.\nChapitre 2: Avoir d'humble sentiments de soi-m\u00eame.\nChapitre 3: De la doctrine de la v\u00e9rit\u00e9. ...",
            copiedFromPlaylistTitle: null,
            copiedToPlaylistTitle: null,
            isAudioImported: false,
            isAudioMusicQuality: false,
            isPaused: true,
            isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
            movedFromPlaylistTitle: null,
            movedToPlaylistTitle: null,
            originalVideoTitle:
                "Livre Audio Imitation du Christ Livre 1 Chapitre 1 \u00e0 5",
            validVideoTitle:
                "Livre Audio l'Imitation de Christ Livre 1 chapitre 1 \u00e0 5",
            videoUploadDate: DateTime(2023, 08, 27, 12, 10, 41),
            videoUrl: "https://www.youtube.com/watch?v=ZkMs8aGzUaU",
            youtubeVideoChannel: "La voie de Dieu par la voix des saints");
        final Audio two = Audio.fullConstructor(
            enclosingPlaylist: audioPlaylist,
            audioDownloadDateTime: DateTime(2025, 03, 01, 20, 15, 58),
            audioDownloadDuration: const Duration(milliseconds: 10503),
            audioDownloadSpeed: 474501,
            audioDuration: const Duration(milliseconds: 863411),
            audioFileName:
                "250301-201610-LIvre audio l'Imitation de J\u00e9sus Christ Livre 1 chapitre 11 \u00e0 15 23-08-27.mp3",
            audioFileSize: 5265772,
            audioPausedDateTime: null,
            audioPlaySpeed: 1.0,
            audioPlayVolume: 0.5,
            audioPositionSeconds: 0,
            compactVideoDescription:
                "La voie de Dieu par la voix des saints\n\nChapitre 11:  Des moyens d'acqu\u00e9rir la paix int\u00e9rieure et du soin d'avancer dans la vertu.\nChapitre 12: De l'avantage de l'adversit\u00e9.\nChapitre 13 :  De la r\u00e9sistance aux tentations. ...\n\nChapitre14: Eviter, Chapitre15: Des",
            copiedFromPlaylistTitle: null,
            copiedToPlaylistTitle: null,
            isAudioImported: false,
            isAudioMusicQuality: false,
            isPaused: true,
            isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
            movedFromPlaylistTitle: null,
            movedToPlaylistTitle: null,
            originalVideoTitle:
                "LIvre audio l'Imitation de J\u00e9sus Christ Livre 1 chapitre 11 \u00e0 15",
            validVideoTitle:
                "LIvre audio l'Imitation de J\u00e9sus Christ Livre 1 chapitre 11 \u00e0 15",
            videoUploadDate: DateTime(2023, 08, 27, 12, 10, 41),
            videoUrl: "https://www.youtube.com/watch?v=ezC10g8xnPo",
            youtubeVideoChannel: "La voie de Dieu par la voix des saints");
        final Audio three = Audio.fullConstructor(
            enclosingPlaylist: audioPlaylist,
            audioDownloadDateTime: DateTime(2025, 03, 01, 20, 15, 58),
            audioDownloadDuration: const Duration(milliseconds: 10503),
            audioDownloadSpeed: 474501,
            audioDuration: const Duration(milliseconds: 1444281),
            audioFileName:
                "250301-201621-Livre audio L imitation de J\u00e9sus Christ Livre 1 chapitre 16 \u00e0 21 23-08-27.mp3",
            audioFileSize: 8807603,
            audioPausedDateTime: null,
            audioPlaySpeed: 1.0,
            audioPlayVolume: 0.5,
            audioPositionSeconds: 0,
            compactVideoDescription:
                "La voie de Dieu par la voix des saints\n\nChapitre 16: Qu'il faut supporter les d\u00e9fauts d'autrui.\nChapitre17: De la vie religieuse.\nChapitre 18: De l'exemple des saints. ...",
            copiedFromPlaylistTitle: null,
            copiedToPlaylistTitle: null,
            isAudioImported: false,
            isAudioMusicQuality: false,
            isPaused: true,
            isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
            movedFromPlaylistTitle: null,
            movedToPlaylistTitle: null,
            originalVideoTitle:
                "Livre audio L imitation de J\u00e9sus Christ Livre 1 chapitre 16 \u00e0 21",
            validVideoTitle:
                "Livre audio l'Imitation de J\u00e9sus Christ Livre 1 chapitre 16 \u00e0 21",
            videoUploadDate: DateTime(2023, 08, 27, 12, 10, 41),
            videoUrl: "https://www.youtube.com/watch?v=BTHUIqDUBTI",
            youtubeVideoChannel: "La voie de Dieu par la voix des saints");
        final Audio four = Audio.fullConstructor(
            enclosingPlaylist: audioPlaylist,
            audioDownloadDateTime: DateTime(2025, 03, 01, 20, 15, 58),
            audioDownloadDuration: const Duration(milliseconds: 10503),
            audioDownloadSpeed: 474501,
            audioDuration: const Duration(milliseconds: 1642487),
            audioFileName:
                "250301-201628-Livre audio l imitation de J\u00e9sus Christ Livre 1 chapitre 22 \u00e0 25 23-08-27.mp3",
            audioFileSize: 10016268,
            audioPausedDateTime: null,
            audioPlaySpeed: 1.0,
            audioPlayVolume: 0.5,
            audioPositionSeconds: 0,
            compactVideoDescription:
                "La voie de Dieu par la voix des saints\n\nChapitre 22: De la consid\u00e9ration de la mis\u00e8re humaine.\nChapitre 23: De la m\u00e9ditation de la mort.\nChapitre 24: Du jugement et des peines des p\u00e9cheurs. ...",
            copiedFromPlaylistTitle: null,
            copiedToPlaylistTitle: null,
            isAudioImported: false,
            isAudioMusicQuality: false,
            isPaused: true,
            isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
            movedFromPlaylistTitle: null,
            movedToPlaylistTitle: null,
            originalVideoTitle:
                "Livre audio l imitation de J\u00e9sus Christ Livre 1 chapitre 22 \u00e0 25",
            validVideoTitle:
                "Livre audio l'Imitation de J\u00e9sus Christ Livre 1 chapitre 22 \u00e0 25",
            videoUploadDate: DateTime(2023, 08, 27, 12, 10, 41),
            videoUrl: "https://www.youtube.com/watch?v=7dkWTWTi8A8",
            youtubeVideoChannel: "La voie de Dieu par la voix des saints");
        final Audio five = Audio.fullConstructor(
            enclosingPlaylist: audioPlaylist,
            audioDownloadDateTime: DateTime(2025, 03, 01, 20, 15, 58),
            audioDownloadDuration: const Duration(milliseconds: 10503),
            audioDownloadSpeed: 474501,
            audioDuration: const Duration(milliseconds: 475870),
            audioFileName:
                "250301-201546-Livre Audio l'Imitation de J\u00e9sus Christ Livre 1 chapitre 6 \u00e0 10 23-08-27.mp3",
            audioFileSize: 2902447,
            audioPausedDateTime: null,
            audioPlaySpeed: 1.0,
            audioPlayVolume: 0.5,
            audioPositionSeconds: 0,
            compactVideoDescription:
                "La voie de Dieu par la voix des saints\n\nChapitre 6: Des affections d\u00e9r\u00e9gl\u00e9s.\nChapitre 7: Qu'il faut fuir l'orgueil et les vaines esp\u00e9rances.\nChapitre 8: Eviter la pop grande familiarit\u00e9. ...",
            copiedFromPlaylistTitle: null,
            copiedToPlaylistTitle: null,
            isAudioImported: false,
            isAudioMusicQuality: false,
            isPaused: true,
            isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
            movedFromPlaylistTitle: null,
            movedToPlaylistTitle: null,
            originalVideoTitle:
                "Livre Audio l'Imitation de J\u00e9sus Christ Livre 1 chapitre 6 \u00e0 10",
            validVideoTitle:
                "Livre Audio l'Imitation de J\u00e9sus Christ Livre 1 chapitre 6 \u00e0 10",
            videoUploadDate: DateTime(2023, 08, 27, 12, 10, 41),
            videoUrl: "https://www.youtube.com/watch?v=FUFz3R4PX6Q",
            youtubeVideoChannel: "La voie de Dieu par la voix des saints");

        List<Audio> audioList = [
          one,
          two,
          three,
          four,
          five,
        ];

        List<Audio> expectedResultForTitleAsc = [
          one,
          five,
          two,
          three,
          four,
        ];

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> sortedByTitleAsc =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        expect(
            sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
            equals(expectedResultForTitleAsc
                .map((audio) => audio.validVideoTitle)
                .toList()));

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''sort by chapter title number. The valid video title of the audio
            contained in the 'Gary Renard - Et l'univers disparaîtra imported'
            json file are original and so not modified.''', () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_filter_unit_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Load Playlist from the file
        Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}Et l'univers disparaîtra imported.json",
          type: Playlist,
        );

        List<Audio> audioList = loadedPlaylist.playableAudioLst;

        final List<SortingItem> selectedSortItemLstAsc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: true,
          ),
        ];

        List<Audio> actualAudioSortedByTitleAscLst =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstAsc,
        );

        List<String> actualAudioSortedByTitleAscStrLst =
            actualAudioSortedByTitleAscLst
                .map((audio) => audio.validVideoTitle)
                .toList();

        // Load the expected sorted audio list from the file
        List<Audio> expectedAudioSortedByTitleAscLst =
            JsonDataService.loadListFromFile(
          jsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list asc Et l'univers disparaîtra imported.json",
          type: Audio,
        );

        List<String> expectedAudioSortedByTitleAscStrLst =
            expectedAudioSortedByTitleAscLst
                .map((audio) => audio.validVideoTitle)
                .toList();

        expect(
          actualAudioSortedByTitleAscStrLst,
          expectedAudioSortedByTitleAscStrLst,
        );

        final List<SortingItem> selectedSortItemLstDesc = [
          SortingItem(
            sortingOption: SortingOption.chapterAudioTitle,
            isAscending: false,
          ),
        ];

        List<Audio> actualAudioSortedByTitleDescLst =
            audioSortFilterService.sortAudioLstBySortingOptions(
          audioLst: audioList,
          selectedSortItemLst: selectedSortItemLstDesc,
        );

        List<String> actualAudioSortedByTitleDescStrLst =
            actualAudioSortedByTitleDescLst
                .map((audio) => audio.validVideoTitle)
                .toList();

        // Load the expected sorted audio list from the file
        List<Audio> expectedAudioSortedByTitleDescLst =
            JsonDataService.loadListFromFile(
          jsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list desc Et l'univers disparaîtra imported.json",
          type: Audio,
        );

        List<String> expectedAudioSortedByTitleDescStrLst =
            expectedAudioSortedByTitleDescLst
                .map((audio) => audio.validVideoTitle)
                .toList();

        expect(
          actualAudioSortedByTitleDescStrLst,
          expectedAudioSortedByTitleDescStrLst,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group("sort audio lst by multiple SortingOption's", () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    test('sort by duration and title', () {
      final Audio zebra = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio apple = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: '',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio bananna = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 15, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio banannaLonger = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna Longer',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 25, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      List<Audio> audioList = [
        zebra,
        banannaLonger,
        apple,
        bananna,
      ];

      List<Audio> expectedResultForDurationAscAndTitleAsc = [
        apple,
        zebra,
        bananna,
        banannaLonger,
      ];

      List<Audio> expectedResultForDurationDescAndTitleDesc = [
        banannaLonger,
        bananna,
        zebra,
        apple,
      ];

      final List<SortingItem> selectedSortItemLstDurationAscAndTitleAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: audioList,
        selectedSortItemLst: selectedSortItemLstDurationAscAndTitleAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForDurationAscAndTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortItemLstDurationDescAndTitleDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: audioList,
        selectedSortItemLst: selectedSortItemLstDurationDescAndTitleDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForDurationDescAndTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('filterAndSortAudioLst by title and description', () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });

    test('with search word present in in title only', () {
      final Audio zebra1 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio apple = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: '',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio zebra3 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio bananna = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio zebra2 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: '',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForTitleAsc = [
        apple,
        bananna,
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
        bananna,
        apple,
      ];

      final List<SortingItem> selectedSortItemLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: audioList,
        selectedSortItemLst: selectedSortItemLstAsc,
      );

      expect(
          sortedByTitleAsc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortItemLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> sortedByTitleDesc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: audioList,
        selectedSortItemLst: selectedSortItemLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      List<Audio> expectedResultForFilterSortTitleAsc = [
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstAsc,
        filterSentenceLst: ['Zeb'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDesc,
        filterSentenceLst: ['Zeb'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('with search word present in compact description only', () {
      final Audio zebra1 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio apple = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio zebra3 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio bananna = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio zebra2 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForFilterSortTitleAsc = [
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
      ];

      final List<SortingItem> selectedSortItemLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstAsc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortItemLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDesc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('with search word in title and in compact description', () {
      final Audio zebra1 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio apple = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: true,
      );
      final Audio zebra3 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio bananna = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      var audio2 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio zebra2 = audio2;

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForFilterSortTitleAsc = [
        apple,
        zebra1,
        zebra2,
        zebra3,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra3,
        zebra2,
        zebra1,
        apple,
      ];

      final List<SortingItem> selectedSortItemLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstAsc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortItemLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDesc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('filterAndSortAudioLst by title only', () {
    late AudioSortFilterService audioSortFilterService;

    SettingsDataService settingsDataService = SettingsDataService(
      sharedPreferences: MockSharedPreferences(),
    );

    setUp(() async {
      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });

    test('with search word in title and in compact description', () {
      final Audio zebra1 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 1 Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio apple = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Apple ?',
        compactVideoDescription: 'description',
        validVideoTitle: 'Apple Julien',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio zebra3 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Bam',
        validVideoTitle: 'Zebra 3',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio bananna = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Bananna ?',
        compactVideoDescription: '',
        validVideoTitle: 'Bananna',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );
      final Audio zebra2 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: audioPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Zebra ?',
        compactVideoDescription: 'Julien Goal',
        validVideoTitle: 'Zebra 2',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      List<Audio> audioList = [
        zebra1,
        apple,
        zebra3,
        bananna,
        zebra2,
      ];

      List<Audio> expectedResultForFilterSortTitleAsc = [
        apple,
        zebra1,
      ];

      List<Audio> expectedResultForFilterSortTitleDesc = [
        zebra1,
        apple,
      ];

      final List<SortingItem> selectedSortItemLstAsc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstAsc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleAsc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      final List<SortingItem> selectedSortItemLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDesc,
        filterSentenceLst: ['Julien'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group("filter sort audio by multiple filter and multiple SortingOption's",
      () {
    late AudioSortFilterService audioSortFilterService;
    late PlaylistListVM playlistListVM;

    setUp(() async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kApplicationPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        pictureVM: PictureVM(
          settingsDataService: settingsDataService,
        ),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        '''filter by one word in audio title and sort by download date descending
           and duration ascending and then sort by download date ascending and
           duration descending''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc =
          [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La surpopulation mondiale par Jancovici et Barrau",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
      ];

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Jancovici',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Janco',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc =
          [
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "La surpopulation mondiale par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        '''filter by multiple words in audio title or in audio compact description
           and sort by download date descending and duration ascending''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc =
          [
        "La surpopulation mondiale par Jancovici et Barrau",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
      ];

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Éthique et tac',
          'Jancovici',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
              selectedPlaylist: audioPlaylist,
              audioLst: audioList,
              audioSortFilterParameters: audioSortFilterParameters);

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Éthique et tac',
          'Jancovici',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
              selectedPlaylist: audioPlaylist,
              audioLst: audioList,
              audioSortFilterParameters: audioSortFilterParameters);

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc =
          [
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "La surpopulation mondiale par Jancovici et Barrau",
      ];

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        '''filter by one sentence present in audio compact description only with
           searchInVideoCompactDescription = false and sort by download date
           descending and duration ascending. Result list will be empty''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: ['Éthique et tac'],
        sentencesCombination: SentencesCombination.or,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          []);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: ['Éthique et tac'],
        sentencesCombination: SentencesCombination.or,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );
      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          []);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        '''filter in 'and' mode by multiple sentences present in audio title and
           compact description only with searchInVideoCompactDescription = false
           and sort by download date descending and duration ascending''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Janco',
          'Éthique et tac',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          []);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Éthique et tac',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          []);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        '''filter in 'and' mode by multiple sentences present in audio title and
           compact description only with searchInVideoCompactDescription = true
           and sort by download date descending and duration ascending''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Janco',
          'Éthique et tac',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            'La surpopulation mondiale par Jancovici et Barrau',
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau'
          ]);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Éthique et tac',
          'Janco',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            'La surpopulation mondiale par Jancovici et Barrau'
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        '''filter in 'or' mode by multiple sentences present in audio title and compact
         description only with searchInVideoCompactDescription = false and sort by
         download date descending and duration ascending''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Janco',
          'Roche',
        ],
        sentencesCombination: SentencesCombination.or,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            'La surpopulation mondiale par Jancovici et Barrau',
            'La résilience insulaire par Fiona Roche',
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau'
          ]);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Janco',
          'Roche',
        ],
        sentencesCombination: SentencesCombination.or,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            'La résilience insulaire par Fiona Roche',
            'La surpopulation mondiale par Jancovici et Barrau',
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('''filter in 'or' mode by multiple sentences present in audio title and
           compact description only with searchInVideoCompactDescription = true
           and sort by download date descending and duration ascending''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Janco',
          'Éthique et tac',
        ],
        sentencesCombination: SentencesCombination.or,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
            'La surpopulation mondiale par Jancovici et Barrau',
            'La résilience insulaire par Fiona Roche',
            'Les besoins artificiels par R.Keucheyan',
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
          ]);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Janco',
          'Éthique et tac',
        ],
        sentencesCombination: SentencesCombination.or,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            'Les besoins artificiels par R.Keucheyan',
            'La résilience insulaire par Fiona Roche',
            'La surpopulation mondiale par Jancovici et Barrau',
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('''filter by one word in audio title, by download start/end date and by
           upload start/end date and sort by download date descending and duration
           ascending and then sort by download date ascending and duration
           descending.''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc =
          [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Jancovici',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
        downloadDateStartRange: DateTime(2024, 7, 1),
        downloadDateEndRange: DateTime(2024, 8, 1),
        uploadDateStartRange: DateTime(2022, 1, 1),
        uploadDateEndRange: DateTime(2022, 12, 31),
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Janco',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
        downloadDateStartRange: DateTime(2024, 1, 7),
        downloadDateEndRange: DateTime(2024, 8, 1),
        uploadDateStartRange: DateTime(2022, 1, 1),
        uploadDateEndRange: DateTime(2023, 12, 31),
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc =
          [
        "La surpopulation mondiale par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('''filter by one word in audio title, by audio file size range and by
           audio duration range and sort by download date descending and duration
           ascending and then sort by download date ascending and duration
           descending.''', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc =
          [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: true,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [
          'Jancovici',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
        fileSizeStartRangeMB: 2.373,
        fileSizeEndRangeMB: 2.374,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc);

      final List<SortingItem>
          selectedSortItemLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: [
          'Janco',
        ],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
        fileSizeStartRangeMB: 2.373,
        fileSizeEndRangeMB: 2.8,
        durationStartRangeSec: 389,
        durationEndRangeSec: 458,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc =
          [
        "La surpopulation mondiale par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group("filter audio by fully, partially and not listened options", () {
    late AudioSortFilterService audioSortFilterService;
    late PlaylistListVM playlistListVM;

    setUp(() async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        pictureVM: PictureVM(
          settingsDataService: settingsDataService,
        ),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('filter not listened audio only', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String> expectedFilteredAudioTitles = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La surpopulation mondiale par Jancovici et Barrau",
        'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.and,
        filterFullyListened: false,
        filterPartiallyListened: false,
        filterNotListened: true,
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      List<String> expectedFilteredAudioTitlesSortedByDurationDesc = [
        'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        "La surpopulation mondiale par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      final List<SortingItem> selectedSortItemLstDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];

      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDurationDesc,
        sentencesCombination: SentencesCombination.and,
        filterFullyListened: false,
        filterPartiallyListened: false,
        filterNotListened: true,
      );

      actualFilteredAudioLst = audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitlesSortedByDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('filter audio avoiding fully listened audio', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String> expectedFilteredAudioTitles = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        'La surpopulation mondiale par Jancovici et Barrau',
        'La résilience insulaire par Fiona Roche',
        'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        '3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher)',
        'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.and,
        filterFullyListened: false,
        filterPartiallyListened: true,
        filterNotListened: true,
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('filter audio getting only fully listened audio', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String> expectedFilteredAudioTitles = [
        'Les besoins artificiels par R.Keucheyan',
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.and,
        filterFullyListened: true,
        filterPartiallyListened: false,
        filterNotListened: false,
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group("filter audio by commented or not commented options", () {
    late AudioSortFilterService audioSortFilterService;
    late PlaylistListVM playlistListVM;

    setUp(() async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        pictureVM: PictureVM(
          settingsDataService: settingsDataService,
        ),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );
    });
    test('filter commented or not commented audio', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String> expectedFilteredAudioTitles = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        'La surpopulation mondiale par Jancovici et Barrau',
        'La résilience insulaire par Fiona Roche',
        'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        'Les besoins artificiels par R.Keucheyan',
        '3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher)',
        'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.and,
        filterCommented: true, // is true by default
        filterNotCommented: true, // is true by default
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('filter commented audio', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String> expectedFilteredAudioTitles = [
        'La surpopulation mondiale par Jancovici et Barrau',
        'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        '3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher)',
      ];

      // Selecting only the commented audios
      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.and,
        filterCommented: true, // is true by default
        filterNotCommented: false, // is true by default
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'empty audio list. Filter commented audio. This test verify a bug fix.',
        () {
      List<String> expectedFilteredAudioTitles = [];

      // Selecting only the commented audios
      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.and,
        filterCommented: true, // is true by default
        filterNotCommented: false, // is true by default
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
        selectedPlaylist: audioPlaylist,
        audioLst: [],
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('filter not commented audio', () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String> expectedFilteredAudioTitles = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        'La résilience insulaire par Fiona Roche',
        'Les besoins artificiels par R.Keucheyan',
        'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.and,
        filterCommented: false, // is true by default
        filterNotCommented: true, // is true by default
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'empty audio list. Filter not commented audio. This test verify a bug fix.',
        () {
      List<String> expectedFilteredAudioTitles = [];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.and,
        filterCommented: false, // is true by default
        filterNotCommented: true, // is true by default
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterOnOtherOptions(
        selectedPlaylist: audioPlaylist,
        audioLst: [],
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('bug fix', () {
    late AudioSortFilterService audioSortFilterService;
    late PlaylistListVM playlistListVM;

    setUp(() async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        pictureVM: PictureVM(
          settingsDataService: settingsDataService,
        ),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService(
        settingsDataService: settingsDataService,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        'filter by no word in audio title or video compact description and sort by download date descending',
        () {
      List<Audio> audioList = playlistListVM
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc =
          [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        'La surpopulation mondiale par Jancovici et Barrau',
        'La résilience insulaire par Fiona Roche',
        'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        'Les besoins artificiels par R.Keucheyan',
        '3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher)',
        'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
      ];

      final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
        filterSentenceLst: [],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateDescAndDurationAsc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateDescAndDurationAsc);

      final List<SortingItem>
          selectedSortOptionsLstDownloadDateAscAndDurationDesc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: true,
        ),
        SortingItem(
          sortingOption: SortingOption.audioDuration,
          isAscending: false,
        ),
      ];
      audioSortFilterParameters = AudioSortFilterParameters(
        selectedSortItemLst:
            selectedSortOptionsLstDownloadDateAscAndDurationDesc,
        filterSentenceLst: ['Janco'],
        sentencesCombination: SentencesCombination.and,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: audioPlaylist,
        audioLst: audioList,
        audioSortFilterParameters: audioSortFilterParameters,
      );

      List<String>
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc =
          [
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "La surpopulation mondiale par Jancovici et Barrau",
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      ];

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          expectedResultForFilterByWordAndSortByDownloadDateAscAndDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('Comments order tests', () {
    test('''sort playlist audio comments so that they are displayed in the same
            order than the audio in the audio playable list dialog available in
            the audio player view.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_unit_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Load Playlist from the file
      Playlist loadedPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}Conversation avec Dieu${path.separator}Conversation avec Dieu.json",
        type: Playlist,
      );

      CommentVM commentVM = CommentVM();

      Map<String, List<Comment>> playlistAudiosCommentsMap =
          commentVM.getPlaylistAudioComments(
        playlist: loadedPlaylist,
      );

      List<String> commentFileNamesNoExtLst =
          playlistAudiosCommentsMap.keys.toList();

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        pictureVM: PictureVM(
          settingsDataService: settingsDataService,
        ),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlist is selected
      playlistListVM.getUpToDateSelectablePlaylists();

      List<String> sortedCommentFileNamesLst = playlistListVM
          .getSortedPlaylistAudioCommentFileNamesApplyingSortFilterParameters(
        selectedPlaylist: loadedPlaylist,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        commentFileNameNoExtLst: commentFileNamesNoExtLst,
      );

      List<String> expectedSortedCommentFileNameLst = [
        "Conversation avec dieu T1 Tome 1 lecture complet entier Neal",
        "Conversation avec Dieu T2 en entier   Neale Donald Walsch   Livre audio",
        "Conversation avec Dieu T3   Neale Donald Walsch   Livre audio",
      ];

      expect(
        sortedCommentFileNamesLst,
        expectedSortedCommentFileNameLst,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test(
        '''sort playlist audio and non audio comments so that they are displayed
           in the same order than the audio in the audio playable list dialog
           available in the audio player view. The audio comment file names
           list contains audio comment file name which do not correspond to
           playable audio list of the playlist.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_unit_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Load Playlist from the file
      Playlist loadedPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}Conversation avec Dieu${path.separator}Conversation avec Dieu.json",
        type: Playlist,
      );

      CommentVM commentVM = CommentVM();

      Map<String, List<Comment>> playlistAudiosCommentsMap =
          commentVM.getPlaylistAudioComments(
        playlist: loadedPlaylist,
      );

      List<String> commentFileNamesNoExtLst =
          playlistAudiosCommentsMap.keys.toList();

      // Adding a comment file name which does not correspond to a playable
      // audio list of the playlist.
      commentFileNamesNoExtLst.add("Conversation avec Dieu T4");

      // Inserting a comment file name which does not correspond to a playable
      // audio list of the playlist.
      commentFileNamesNoExtLst.insert(1, "Conversation avec Dieu T5");

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        pictureVM: PictureVM(
          settingsDataService: settingsDataService,
        ),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlist is selected
      playlistListVM.getUpToDateSelectablePlaylists();

      List<String> sortedCommentFileNamesLst = playlistListVM
          .getSortedPlaylistAudioCommentFileNamesApplyingSortFilterParameters(
        selectedPlaylist: loadedPlaylist,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        commentFileNameNoExtLst: commentFileNamesNoExtLst,
      );

      List<String> expectedSortedCommentFileNameLst = [
        "Conversation avec dieu T1 Tome 1 lecture complet entier Neal",
        "Conversation avec Dieu T2 en entier   Neale Donald Walsch   Livre audio",
        "Conversation avec Dieu T3   Neale Donald Walsch   Livre audio",
      ];

      expect(
        sortedCommentFileNamesLst,
        expectedSortedCommentFileNameLst,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    test('''sort playlist zero comments.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_audio_comments_sort_unit_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Load Playlist from the file
      Playlist loadedPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}Conversation avec Dieu${path.separator}Conversation avec Dieu.json",
        type: Playlist,
      );

      List<String> commentFileNamesNoExtLst = [];

      // Adding a comment file name which does not correspond to a playable
      // audio list of the playlist.
      commentFileNamesNoExtLst.add("Conversation avec Dieu T4");

      // Inserting a comment file name which does not correspond to a playable
      // audio list of the playlist.
      commentFileNamesNoExtLst.insert(1, "Conversation avec Dieu T5");

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        pictureVM: PictureVM(
          settingsDataService: settingsDataService,
        ),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlist is selected
      playlistListVM.getUpToDateSelectablePlaylists();

      List<String> sortedCommentFileNamesLst = playlistListVM
          .getSortedPlaylistAudioCommentFileNamesApplyingSortFilterParameters(
        selectedPlaylist: loadedPlaylist,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        commentFileNameNoExtLst: commentFileNamesNoExtLst,
      );

      List<String> expectedSortedCommentFileNameLst = [];

      expect(
        sortedCommentFileNamesLst,
        expectedSortedCommentFileNameLst,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('Remaining options test', () {
    late PlaylistListVM playlistListVM;

    setUp(() async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        pictureVM: PictureVM(
          settingsDataService: settingsDataService,
        ),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    group('''By audio downl or vid upl date filter tests
        test''', () {
      late AudioSortFilterService audioSortFilterService;
      late PlaylistListVM playlistListVM;

      setUp(() async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: MockSharedPreferences(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        // Since we have to use a mock AudioDownloadVM to add the
        // youtube playlist, we can not use app.main() to start the
        // app because app.main() uses the real AudioDownloadVM
        // and we don't want to make the main.dart file dependent
        // of a mock class. So we have to start the app by hand.

        WarningMessageVM warningMessageVM = WarningMessageVM();
        // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        //   warningMessageVM: warningMessageVM,
        //
        // );
        // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

        AudioDownloadVM audioDownloadVM = AudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

        playlistListVM = PlaylistListVM(
          warningMessageVM: warningMessageVM,
          audioDownloadVM: audioDownloadVM,
          commentVM: CommentVM(),
          pictureVM: PictureVM(
            settingsDataService: settingsDataService,
          ),
          settingsDataService: settingsDataService,
        );

        // calling getUpToDateSelectablePlaylists() loads all the
        // playlist json files from the app dir and so enables
        // playlistListVM to know which playlists are
        // selected and which are not
        playlistListVM.getUpToDateSelectablePlaylists();

        audioSortFilterService = AudioSortFilterService(
          settingsDataService: settingsDataService,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''Set start + end audio download date and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          downloadDateStartRange: DateTime(2024, 1, 1),
          downloadDateEndRange: DateTime(2024, 1, 7),
        );

        List<String> expectedAudioFilteredLst = [
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''Set start only audio download date and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          downloadDateStartRange: DateTime(2024, 1, 7),
        );

        List<String> expectedAudioFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''Set end only audio download date and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          downloadDateEndRange: DateTime(2023, 12, 26),
        );

        List<String> expectedAudioFilteredLst = [
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''Set start == end audio download date and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          downloadDateStartRange: DateTime(2024, 1, 8),
          downloadDateEndRange: DateTime(2024, 1, 8),
        );

        List<String> expectedAudioFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''Set start + end video upload date and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          uploadDateStartRange: DateTime(2023, 1, 1),
          uploadDateEndRange: DateTime(2023, 12, 3),
        );

        List<String> expectedAudioFilteredLst = [
          'La surpopulation mondiale par Jancovici et Barrau',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''Set start only video upload date and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          uploadDateStartRange: DateTime(2023, 12, 1),
        );

        List<String> expectedAudioFilteredLst = [
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set end only video upload date and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          uploadDateEndRange: DateTime(2023, 12, 3),
        );

        List<String> expectedAudioFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''Set start == end video upload date and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          uploadDateStartRange: DateTime(2023, 9, 10),
          uploadDateEndRange: DateTime(2023, 9, 10),
        );

        List<String> expectedAudioFilteredLst = [
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
    group('''By audio file size or duration filter tests
        test''', () {
      late AudioSortFilterService audioSortFilterService;
      late PlaylistListVM playlistListVM;

      setUp(() async {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}sort_and_filter_audio_dialog_widget_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        SettingsDataService settingsDataService = SettingsDataService(
          sharedPreferences: MockSharedPreferences(),
        );

        // Load the settings from the json file. This is necessary
        // otherwise the ordered playlist titles will remain empty
        // and the playlist list will not be filled with the
        // playlists available in the download app test dir
        await settingsDataService.loadSettingsFromFile(
            settingsJsonPathFileName:
                "$kApplicationPathWindowsTest${path.separator}$kSettingsFileName");

        // Since we have to use a mock AudioDownloadVM to add the
        // youtube playlist, we can not use app.main() to start the
        // app because app.main() uses the real AudioDownloadVM
        // and we don't want to make the main.dart file dependent
        // of a mock class. So we have to start the app by hand.

        WarningMessageVM warningMessageVM = WarningMessageVM();
        // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
        //   warningMessageVM: warningMessageVM,
        //
        // );
        // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

        AudioDownloadVM audioDownloadVM = AudioDownloadVM(
          warningMessageVM: warningMessageVM,
          settingsDataService: settingsDataService,
        );

        // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

        playlistListVM = PlaylistListVM(
          warningMessageVM: warningMessageVM,
          audioDownloadVM: audioDownloadVM,
          commentVM: CommentVM(),
          pictureVM: PictureVM(
            settingsDataService: settingsDataService,
          ),
          settingsDataService: settingsDataService,
        );

        // calling getUpToDateSelectablePlaylists() loads all the
        // playlist json files from the app dir and so enables
        // playlistListVM to know which playlists are
        // selected and which are not
        playlistListVM.getUpToDateSelectablePlaylists();

        audioSortFilterService = AudioSortFilterService(
          settingsDataService: settingsDataService,
        );

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set start + end audio filesize and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          fileSizeStartRangeMB: 4,
          fileSizeEndRangeMB: 5,
        );

        List<String> expectedAudioFilteredLst = [
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set start only audio file size and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          fileSizeStartRangeMB: 4,
        );

        List<String> expectedAudioFilteredLst = [
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set end only audio file size and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          fileSizeEndRangeMB: 4.97,
        );

        List<String> expectedAudioFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set start == end audio file size and verify filtered audio list.
              In this test, 2 files have those file size: 2373715 bytes and
              2370022 bytes. Setting start and end filter file size to 2.37 MB
              returns those files.''', () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          fileSizeStartRangeMB: 2.37,
          fileSizeEndRangeMB: 2.37,
        );

        List<String> expectedAudioFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test(
          '''Set start ==almost end audio file size and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          fileSizeStartRangeMB: 2.37,
          fileSizeEndRangeMB: 2.38,
        );

        List<String> expectedAudioFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set start + end audio duration and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          durationStartRangeSec:
              DateTimeParser.parseHHMMDuration('0:07')!.inSeconds,
          durationEndRangeSec:
              DateTimeParser.parseHHMMDuration('0:14')!.inSeconds,
        );

        List<String> expectedAudioFilteredLst = [
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set start only audio duration and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          durationStartRangeSec:
              DateTimeParser.parseHHMMDuration('0:13')!.inSeconds,
        );

        List<String> expectedAudioFilteredLst = [
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set end only audio duration and verify filtered audio list''',
          () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          durationEndRangeSec:
              DateTimeParser.parseHHMMDuration('0:08')!.inSeconds,
        );

        List<String> expectedAudioFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      test('''Set start == end audio duration and verify filtered audio list.
           Since the audio duration contain are defined in hour, minute and seconds,
           trying to filter audio based on start hour minute == end hour minute
           has no sence and an empty list is returned as result.''', () {
        List<Audio> audioNotFilteredLst = playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        );

        List<String> expectedAudioNotFilteredLst = [
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          'La surpopulation mondiale par Jancovici et Barrau',
          'La résilience insulaire par Fiona Roche',
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik',
          'Les besoins artificiels par R.Keucheyan',
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        ];

        expect(
          audioNotFilteredLst.map((audio) => audio.validVideoTitle).toList(),
          expectedAudioNotFilteredLst,
        );

        final List<SortingItem> selectedSortItemLstDownloadDateDesc = [
          SortingItem(
            sortingOption: SortingOption.audioDownloadDate,
            isAscending: false,
          ),
        ];

        AudioSortFilterParameters audioSortFilterParameters =
            AudioSortFilterParameters(
          selectedSortItemLst: selectedSortItemLstDownloadDateDesc,
          sentencesCombination: SentencesCombination.and,
          durationStartRangeSec:
              DateTimeParser.parseHHMMDuration('0:19')!.inSeconds,
          durationEndRangeSec:
              DateTimeParser.parseHHMMDuration('0:19')!.inSeconds,
        );

        List<String> expectedAudioFilteredLst = [];

        List<Audio> filteredByStartEndDownloadDate =
            audioSortFilterService.filterAndSortAudioLst(
          selectedPlaylist: audioPlaylist,
          audioLst: audioNotFilteredLst,
          audioSortFilterParameters: audioSortFilterParameters,
        );

        expect(
            filteredByStartEndDownloadDate
                .map((audio) => audio.validVideoTitle)
                .toList(),
            expectedAudioFilteredLst);

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
  });
}
