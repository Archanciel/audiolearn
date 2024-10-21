import 'dart:math';

import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/sort_filter_parameters.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
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
  final Audio audioOne = Audio.fullConstructor(
    youtubeVideoChannel: 'one',
    enclosingPlaylist: null,
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
    enclosingPlaylist: null,
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
    enclosingPlaylist: null,
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
    enclosingPlaylist: null,
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

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.OR,
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

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.OR,
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

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.OR,
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

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.AND,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.OR,
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
              sentencesCombination: SentencesCombination.OR,
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

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('filter by start/end download date', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioTwo,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService.filterOnOtherOptions(
          audioLst: audioLst,
          audioSortFilterParameters: AudioSortFilterParameters(
            selectedSortItemLst: [],
            filterSentenceLst: [],
            sentencesCombination: SentencesCombination.AND,
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

      List<Audio> filteredAudioLst = audioSortFilterService.filterOnOtherOptions(
          audioLst: audioLst,
          audioSortFilterParameters: AudioSortFilterParameters(
            selectedSortItemLst: [],
            filterSentenceLst: [],
            sentencesCombination: SentencesCombination.AND,
            ignoreCase: true,
            searchAsWellInVideoCompactDescription: true,
            searchAsWellInYoutubeChannelName: false,
            uploadDateStartRange: DateTime(2023, 3, 1),
            uploadDateEndRange: DateTime(2023, 4, 1),
          ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by start/end download date and start/end video upload date', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
      ];
 
      List<Audio> filteredAudioLst = audioSortFilterService.filterOnOtherOptions(
          audioLst: audioLst,
          audioSortFilterParameters: AudioSortFilterParameters(
            selectedSortItemLst: [],
            filterSentenceLst: [],
            sentencesCombination: SentencesCombination.AND,
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
  group(
      '''filter test: by file size range or/and audio duration range.''',
      () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('filter by file size range', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioThree,
        audioFour
      ];

      List<Audio> filteredAudioLst = audioSortFilterService.filterOnOtherOptions(
          audioLst: audioLst,
          audioSortFilterParameters: AudioSortFilterParameters(
            selectedSortItemLst: [],
            filterSentenceLst: [],
            sentencesCombination: SentencesCombination.AND,
            ignoreCase: true,
            searchAsWellInVideoCompactDescription: true,
            searchAsWellInYoutubeChannelName: false,
            fileSizeStartRangeMB: 110,
            fileSizeEndRangeMB: 130,
          ));

      expect(filteredAudioLst, expectedFilteredAudios);
    });
    test('filter by audio duration range', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioFour
      ];

      List<Audio> filteredAudioLst = audioSortFilterService.filterOnOtherOptions(
          audioLst: audioLst,
          audioSortFilterParameters: AudioSortFilterParameters(
            selectedSortItemLst: [],
            filterSentenceLst: [],
            sentencesCombination: SentencesCombination.AND,
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
    test('filter by file size range and audio duration range', () {
      List<Audio> expectedFilteredAudios = [
        audioOne,
        audioFour,
      ];

      List<Audio> filteredAudioLst = audioSortFilterService.filterOnOtherOptions(
          audioLst: audioLst,
          audioSortFilterParameters: AudioSortFilterParameters(
            selectedSortItemLst: [],
            filterSentenceLst: [],
            sentencesCombination: SentencesCombination.AND,
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

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('sort by title', () {
      final Audio zebra = Audio.fullConstructor(
        youtubeVideoChannel: 'three',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        audioLst: List<Audio>.from(audioList), // copy list
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
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortItemLst: selectedSortItemLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('sort by title with chapter number', () {
      final Audio avantPropos = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
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
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortItemLst: selectedSortItemLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('''sort by title with chapter number. The order of the list of audio to
            sort was modified''', () {
      final Audio avantPropos = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> sortedByTitleAsc =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
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
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortItemLst: selectedSortItemLstDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('''sort by edited title with chapter number. The valid video titles of
            the audio contained in the 'Gary Renard - Et l'univers disparaîtra'
            json file were edited in order for their titles to be sorted correctly
            before the SortingOption.validAudioTitle sort function was improved.''',
        () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortItemLst: selectedSortItemLstAsc,
      );

      // Load the expected sorted audio list from the file
      List<Audio> expectedAudioSortedByTitleAscLst =
          JsonDataService.loadListFromFile(
        jsonPathFileName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list asc Et l'univers disparaîtra.json",
        type: Audio,
      );

      expect(
        actualAudioSortedByTitleAscLst,
        expectedAudioSortedByTitleAscLst,
      );

      final List<SortingItem> selectedSortItemLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> actualAudioSortedByTitleDescLst =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortItemLst: selectedSortItemLstDesc,
      );

      // Save the list to a file
      // JsonDataService.saveListToFile(
      //   data: actualAudioSortedByTitleDescLst,
      //   jsonPathFileName:
      //       "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list desc Et l'univers disparaîtra.json",
      // );

      // Load the expected sorted audio list from the file
      List<Audio> expectedAudioSortedByTitleDescLst =
          JsonDataService.loadListFromFile(
        jsonPathFileName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list desc Et l'univers disparaîtra.json",
        type: Audio,
      );

      expect(
        actualAudioSortedByTitleDescLst,
        expectedAudioSortedByTitleDescLst,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''sort by title with chapter number. The valid video title of the audio
            contained in the 'Gary Renard - Et l'univers disparaîtra imported'
            json file are original and so not modified.''', () {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
          sortingOption: SortingOption.validAudioTitle,
          isAscending: true,
        ),
      ];

      List<Audio> actualAudioSortedByTitleAscLst =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortItemLst: selectedSortItemLstAsc,
      );

      // Load the expected sorted audio list from the file
      List<Audio> expectedAudioSortedByTitleAscLst =
          JsonDataService.loadListFromFile(
        jsonPathFileName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list asc Et l'univers disparaîtra imported.json",
        type: Audio,
      );

      expect(
        actualAudioSortedByTitleAscLst,
        expectedAudioSortedByTitleAscLst,
      );

      final List<SortingItem> selectedSortItemLstDesc = [
        SortingItem(
          sortingOption: SortingOption.validAudioTitle,
          isAscending: false,
        ),
      ];

      List<Audio> actualAudioSortedByTitleDescLst =
          audioSortFilterService.sortAudioLstBySortingOptions(
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortItemLst: selectedSortItemLstDesc,
      );

      // Save the list to a file
      // JsonDataService.saveListToFile(
      //   data: actualAudioSortedByTitleDescLst,
      //   jsonPathFileName:
      //       "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list desc Et l'univers disparaîtra imported.json",
      // );

      // Load the expected sorted audio list from the file
      List<Audio> expectedAudioSortedByTitleDescLst =
          JsonDataService.loadListFromFile(
        jsonPathFileName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}expected audio list desc Et l'univers disparaîtra imported.json",
        type: Audio,
      );

      expect(
        actualAudioSortedByTitleDescLst,
        expectedAudioSortedByTitleDescLst,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });

    test('sort by title starting with non language chars', () {
      Audio title = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
    });
  });
  group("sort audio lst by multiple SortingOption's", () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });
    test('sort by duration and title', () {
      final Audio zebra = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        audioLst: List<Audio>.from(audioList), // copy list
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
        audioLst: List<Audio>.from(audioList), // copy list
        selectedSortItemLst: selectedSortItemLstDurationDescAndTitleDesc,
      );

      expect(
          sortedByTitleDesc.map((audio) => audio.validVideoTitle).toList(),
          equals(expectedResultForDurationDescAndTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
  group('filterAndSortAudioLst by title and description', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('with search word present in in title only', () {
      final Audio zebra1 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        audioLst: List<Audio>.from(audioList), // copy list
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
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('with search word present in compact description only', () {
      final Audio zebra1 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
    test('with search word in title and in compact description', () {
      final Audio zebra1 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredAndSortedByTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          equals(expectedResultForFilterSortTitleDesc
              .map((audio) => audio.validVideoTitle)
              .toList()));
    });
  });
  group('filterAndSortAudioLst by title only', () {
    late AudioSortFilterService audioSortFilterService;

    setUp(() {
      audioSortFilterService = AudioSortFilterService();
    });

    test('with search word in title and in compact description', () {
      final Audio zebra1 = Audio.fullConstructor(
        youtubeVideoChannel: 'one',
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        enclosingPlaylist: null,
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredAndSortedByTitleDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //   isTest: true,
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''filter by one word in audio title and sort by download date descending
           and duration ascending and then sort by download date ascending and
           duration descending''',
        () {
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''filter by multiple words in audio title or in audio compact description
           and sort by download date descending and duration ascending''',
        () {
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
              audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
              audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''filter by one sentence present in audio compact description only with
           searchInVideoCompactDescription = false and sort by download date
           descending and duration ascending. Result list will be empty''',
        () {
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
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );
      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''filter in 'and' mode by multiple sentences present in audio title and
           compact description only with searchInVideoCompactDescription = false
           and sort by download date descending and duration ascending''',
        () {
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''filter in 'and' mode by multiple sentences present in audio title and
           compact description only with searchInVideoCompactDescription = true
           and sort by download date descending and duration ascending''',
        () {
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
      '''filter in 'or' mode by multiple sentences present in audio title and compact
         description only with searchInVideoCompactDescription = false and sort by
         download date descending and duration ascending''',
        () {
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
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: false,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''filter in 'or' mode by multiple sentences present in audio title and
           compact description only with searchInVideoCompactDescription = true
           and sort by download date descending and duration ascending''',
        () {
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
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)"
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
        sentencesCombination: SentencesCombination.OR,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          filteredByWordAndSortedByDownloadDateAscAndDurationDesc
              .map((audio) => audio.validVideoTitle)
              .toList(),
          [
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
            'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
            'Les besoins artificiels par R.Keucheyan',
            'La résilience insulaire par Fiona Roche',
            'La surpopulation mondiale par Jancovici et Barrau',
            "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          ]);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
      test(
        '''filter by one word in audio title, by download start/end date and by
           upload start/end date and sort by download date descending and duration
           ascending and then sort by download date ascending and duration
           descending.''',
        () {
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
        sentencesCombination: SentencesCombination.AND,
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
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
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
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
      test(
        '''filter by one word in audio title, by audio file size range and by
           audio duration range and sort by download date descending and duration
           ascending and then sort by download date ascending and duration
           descending.''',
        () {
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
        fileSizeStartRangeMB: 2.373,
        fileSizeEndRangeMB: 2.374,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
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
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //   isTest: true,
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService();
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
        sentencesCombination: SentencesCombination.AND,
        filterFullyListened: false,
        filterPartiallyListened: false,
        filterNotListened: true,
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        filterFullyListened: false,
        filterPartiallyListened: false,
        filterNotListened: true,
      );

      actualFilteredAudioLst = audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitlesSortedByDurationDesc);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        '3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher)',
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: [],
        sentencesCombination: SentencesCombination.AND,
        filterFullyListened: false,
        filterPartiallyListened: true,
        filterNotListened: true,
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        sentencesCombination: SentencesCombination.AND,
        filterFullyListened: true,
        filterPartiallyListened: false,
        filterNotListened: false,
      );

      List<Audio> actualFilteredAudioLst =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
        audioSortFilterParameters: audioSortFilterParameters,
      );

      expect(
          actualFilteredAudioLst.map((audio) => audio.validVideoTitle).toList(),
          expectedFilteredAudioTitles);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //   isTest: true,
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau',
        '3 fois où un économiste m\'a ouvert les yeux (Giraud, Lefournier, Porcher)',
      ];

      final List<SortingItem>
          selectedSortItemLstDownloadDateDescAndDurationAsc = [
        SortingItem(
          sortingOption: SortingOption.audioDownloadDate,
          isAscending: false,
        ),
      ];

      AudioSortFilterParameters audioSortFilterParameters =
          AudioSortFilterParameters(
        selectedSortItemLst: selectedSortItemLstDownloadDateDescAndDurationAsc,
        filterSentenceLst: [],
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateDescAndDurationAsc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        sentencesCombination: SentencesCombination.AND,
        ignoreCase: true,
        searchAsWellInVideoCompactDescription: true,
        searchAsWellInYoutubeChannelName: false,
      );

      List<Audio> filteredByWordAndSortedByDownloadDateAscAndDurationDesc =
          audioSortFilterService.filterAndSortAudioLst(
        audioLst: List<Audio>.from(audioList), // copy list
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
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
        commentFileNamesLst: commentFileNamesNoExtLst,
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
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
        commentFileNamesLst: commentFileNamesNoExtLst,
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
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('''sort playlist zero comments.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
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
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      WarningMessageVM warningMessageVM = WarningMessageVM();

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      PlaylistListVM playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
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
        commentFileNamesLst: commentFileNamesNoExtLst,
      );

      List<String> expectedSortedCommentFileNameLst = [];

      expect(
        sortedCommentFileNamesLst,
        expectedSortedCommentFileNameLst,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Static functions test', () {
    late AudioSortFilterService audioSortFilterService;
    late PlaylistListVM playlistListVM;

    setUp(() async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_sort_filter_service_test_data",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // Load the settings from the json file. This is necessary
      // otherwise the ordered playlist titles will remain empty
      // and the playlist list will not be filled with the
      // playlists available in the download app test dir
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Since we have to use a mock AudioDownloadVM to add the
      // youtube playlist, we can not use app.main() to start the
      // app because app.main() uses the real AudioDownloadVM
      // and we don't want to make the main.dart file dependent
      // of a mock class. So we have to start the app by hand.

      WarningMessageVM warningMessageVM = WarningMessageVM();
      // MockAudioDownloadVM mockAudioDownloadVM = MockAudioDownloadVM(
      //   warningMessageVM: warningMessageVM,
      //   isTest: true,
      // );
      // mockAudioDownloadVM.youtubePlaylistTitle = youtubeNewPlaylistTitle;

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // audioDownloadVM.youtubeExplode = mockYoutubeExplode;

      playlistListVM = PlaylistListVM(
        warningMessageVM: warningMessageVM,
        audioDownloadVM: audioDownloadVM,
        commentVM: CommentVM(),
        settingsDataService: settingsDataService,
      );

      // calling getUpToDateSelectablePlaylists() loads all the
      // playlist json files from the app dir and so enables
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      audioSortFilterService = AudioSortFilterService();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        'increaseByMinimumUnit 0.01 test',
        () {
          double increasedValue = AudioSortFilterService.increaseByMinimumUnit(
            endValueTxt: '2.79',
          );

          expect(increasedValue, 2.8);
    });
    test(
        'increaseByMinimumUnit 0.001 test',
        () {
          double increasedValue = AudioSortFilterService.increaseByMinimumUnit(
            endValueTxt: '200.327',
          );

          expect(increasedValue, 200.328);
    });
    test(
        'setDateTimeToEndDay 0 hour',
        () {
          DateTime increasedValue = AudioSortFilterService.setDateTimeToEndDay(
            date: DateTime(2024, 1, 7),
          );

          expect(increasedValue, DateTime(2024, 1, 7, 23, 59, 59));
    });
    test(
        'setDateTimeToEndDay 10 hours 45 minutes 23 seconds',
        () {
          DateTime increasedValue = AudioSortFilterService.setDateTimeToEndDay(
            date: DateTime(2024, 1, 7, 10, 45, 23),
          );

          expect(increasedValue, DateTime(2024, 1, 7, 23, 59, 59));
    });
    test(
        'setDateTimeToEndDay 0 hours 0 minutes 23 seconds',
        () {
          DateTime increasedValue = AudioSortFilterService.setDateTimeToEndDay(
            date: DateTime(2024, 1, 7, 0, 0, 23),
          );

          expect(increasedValue, DateTime(2024, 1, 7, 23, 59, 59));
    });
  });
}
