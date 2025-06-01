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

Future<void> main() async {
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

  group('sort audio lst by one SortingOption', ()  {
    group('sort audio lst by title SortingOption', ()  {
      test('sort by title', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('sort by title containing _ number reference', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('sort by title containing - number reference', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('sort by title containing / number reference', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('sort by title containing : number reference', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });

      test('sort by title starting with non language chars', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
    });

    group('sort audio lst by chapter SortingOption', () {
      test('''sort by _ chapter title number. Example: ... 1_1 ..., ... 1_2 ...,
            ... 2_1 ...''', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('''sort by - chapter title number. Example: ... 1-1 ..., ... 1-2 ...,
            ... 2-1 ...''', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('''sort by / chapter title number. Example: ... 1/1 ..., ... 1/2 ...,
            ... 2/1 ...''', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('''sort by : chapter title number. Example: ... 1:1 ..., ... 1:2 ...,
            ... 2:1 ...''', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('''sort by / chapter title number. Example: ... 1/1 ..., ... 1/2 ...,
            ... 2/1 ... . The order of the list of audio to sort (included in the
            variable audioList below) was modified.''', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('''sort by : chapter title number. Example: ... 1:1 ..., ... 1:2 ...,
            ... 2:1 ... . The order of the list of audio to sort (included in the
            variable audioList below) was modified.''', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('''sort by ' à ' chapter title number. Example: chapitre 1 à 5,
            Chapitre 6 à 10, chapitre 11 à 15''', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });
      test('''sort by chapter title number. The valid video title of the audio
            contained in the 'Gary Renard - Et l'univers disparaîtra imported'
            json file are original and so not modified.''', () async {
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
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      });

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}
