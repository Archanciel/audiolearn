import 'dart:io';

import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';

import '../services/mock_shared_preferences.dart';

void main() {
  group('Copy/move audio + comment file to target playlist', () {
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
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_list_vm_copy_move_audio_test_data",
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
    });

    test('copyAudioToPlaylist copies audio and its comments to playlist', () {
      const String sourcePlaylistTitle = 'S8 audio';

      final sourcePlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        sourcePlaylistTitle,
      );

      final sourcePlaylistFilePathName = path.join(
        sourcePlaylistPath,
        '$sourcePlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist sourcePlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: sourcePlaylistFilePathName,
        type: Playlist,
      );

      const String targetPlaylistTitle = 'local_target';

      final targetPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        targetPlaylistTitle,
      );

      final targetPlaylistFilePathName = path.join(
        targetPlaylistPath,
        '$targetPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist targetPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: targetPlaylistFilePathName,
        type: Playlist,
      );

      // Testing copy La résilience insulaire par Fiona Roche with
      // play position at start of audio and no comment file
      testCopyAudioToPlaylist(
          playlistListVM: playlistListVM,
          sourcePlaylist: sourcePlaylist,
          sourceAudioIndex: 0,
          targetPlaylist: targetPlaylist,
          hasCommentFile: false);

      // Testing copy Le Secret de la RESILIENCE révélé par Boris Cyrulnik
      // with play position at end of audio and comment file
      testCopyAudioToPlaylist(
        playlistListVM: playlistListVM,
        sourcePlaylist: sourcePlaylist,
        sourceAudioIndex: 1,
        targetPlaylist: targetPlaylist,
        hasCommentFile: true,
      );

      // Testing copy Jancovici répond aux voeux de Macron pour 2024
      // with play position 2 seconds before end of audio and comment
      // file
      testCopyAudioToPlaylist(
        playlistListVM: playlistListVM,
        sourcePlaylist: sourcePlaylist,
        sourceAudioIndex: 4,
        targetPlaylist: targetPlaylist,
        hasCommentFile: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('moveAudioToPlaylist moves audio and its comments to playlist', () {
      const String sourcePlaylistTitle = 'S8 audio';

      final sourcePlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        sourcePlaylistTitle,
      );

      final sourcePlaylistFilePathName = path.join(
        sourcePlaylistPath,
        '$sourcePlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist sourcePlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: sourcePlaylistFilePathName,
        type: Playlist,
      );

      const String targetPlaylistTitle = 'local_target';

      final targetPlaylistPath = path.join(
        kPlaylistDownloadRootPathWindowsTest,
        targetPlaylistTitle,
      );

      final targetPlaylistFilePathName = path.join(
        targetPlaylistPath,
        '$targetPlaylistTitle.json',
      );

      // Load playlist from the json file
      Playlist targetPlaylist = JsonDataService.loadFromFile(
        jsonPathFileName: targetPlaylistFilePathName,
        type: Playlist,
      );

      // Testing move La résilience insulaire par Fiona Roche with
      // play position at start of audio, no comments
      testMoveAudioAndCommentToPlaylist(
        playlistListVM: playlistListVM,
        sourcePlaylist: sourcePlaylist,
        sourceAudioIndex: 0,
        targetPlaylist: targetPlaylist,
        hasCommentFile: false,
      );

      // Testing move Le Secret de la RESILIENCE révélé par Boris Cyrulnik
      // with play position at end of audio and comment file
      testMoveAudioAndCommentToPlaylist(
        playlistListVM: playlistListVM,
        sourcePlaylist: sourcePlaylist,
        sourceAudioIndex: 0,
        targetPlaylist: targetPlaylist,
        hasCommentFile: true,
      );

      // Testing move Jancovici répond aux voeux de Macron pour 2024
      // play position 2 seconds before end of audio
      testMoveAudioAndCommentToPlaylist(
        playlistListVM: playlistListVM,
        sourcePlaylist: sourcePlaylist,
        sourceAudioIndex: 2,
        targetPlaylist: targetPlaylist,
        hasCommentFile: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Obtain next playable audio', () {
    late PlaylistListVM playlistListVM;

    test('Next playable audio is not last downloaded', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = playlistListVM.getSelectedPlaylists()[0];
      Audio currentAudio = sourcePlaylist.playableAudioLst[7];

      // Obtaining the next playable audio
      Audio? nextAudio = playlistListVM
          .getNextSubsequentlyDownloadedOrSortFilteredNotFullyPlayedAudio(
        currentAudio: currentAudio,
      );

      expect(nextAudio!.validVideoTitle,
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        'Next playable audio when current audio is last downloaded audio which is not fully played',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      List<Playlist> selectablePlaylistLst =
          playlistListVM.getUpToDateSelectablePlaylists();

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = selectablePlaylistLst[3]; // local
      Audio lastDownloadedAudio = sourcePlaylist.playableAudioLst[0];

      // Obtaining the next playable audio
      Audio? nextAudio = playlistListVM
          .getNextSubsequentlyDownloadedOrSortFilteredNotFullyPlayedAudio(
        currentAudio: lastDownloadedAudio,
      );

      // Since the last downloaded audio is not fully played, it
      // is the next playable audio and so there is no next playable
      // audio
      expect(nextAudio, null);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        'Next playable audio when current audio is last downloaded audio which is fully played',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      List<Playlist> selectablePlaylistLst =
          playlistListVM.getUpToDateSelectablePlaylists();

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = selectablePlaylistLst[5]; // local_3
      Audio lastDownloadedAudio = sourcePlaylist.playableAudioLst[0];

      // Obtaining the next playable audio
      Audio? nextAudio = playlistListVM
          .getNextSubsequentlyDownloadedOrSortFilteredNotFullyPlayedAudio(
        currentAudio: lastDownloadedAudio,
      );

      // Since the last downloaded audio is fully played, there is no
      // next playable audio
      expect(nextAudio, null);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('Next playable audio is last downloaded audio', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      List<Playlist> selectablePlaylistLst =
          playlistListVM.getUpToDateSelectablePlaylists();

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = selectablePlaylistLst[0]; // S8 audio
      Audio firstDownloadedAudio = sourcePlaylist.playableAudioLst[3];

      // Obtaining the next playable audio
      Audio? nextaudioIslastdownloaded = playlistListVM
          .getNextSubsequentlyDownloadedOrSortFilteredNotFullyPlayedAudio(
        currentAudio: firstDownloadedAudio,
      );

      // Since the first downloaded audio is not fully played, it
      // is the next playable audio and so there is no next playableaudio
      expect(nextaudioIslastdownloaded!.validVideoTitle,
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Obtain list of playable audios', () {
    late PlaylistListVM playlistListVM;

    test(
        'Playlist has several not fully played audios. Last downloaded audio is not played.',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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

      // Obtaining the audio from which to obtain the next playable
      // audio
      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      expect(playableAudioLst.length, 2);
      expect(playableAudioLst[0].validVideoTitle,
          'La résilience insulaire par Fiona Roche');
      expect(playableAudioLst[1].validVideoTitle,
          'Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        'Playlist has several not fully played audios. Last downloaded audio is fully played.',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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

      // Obtaining the audio from which to obtain the next playable
      // audio
      playlistListVM.getUpToDateSelectablePlaylists();
      playlistListVM.setPlaylistSelection(
        playlistIndex: 1,
        isPlaylistSelected: true,
      );

      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      expect(playableAudioLst.length, 3);
      expect(playableAudioLst[0].validVideoTitle,
          "Les besoins artificiels par R.Keucheyan");
      expect(playableAudioLst[1].validVideoTitle,
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau");
      expect(playableAudioLst[2].validVideoTitle,
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)");

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('Playlist has no not fully played audios', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_play_skip_to_next_not_last_unread_audio_test",
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
      playlistListVM.setPlaylistSelection(
        playlistIndex: 2,
        isPlaylistSelected: true,
      );

      // Obtaining the audio from which to obtain the next playable
      // audio
      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      expect(playableAudioLst.length, 0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Add invalid paylist', () {
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
            "$kDownloadAppTestSavedDataDir${path.separator}playlist_list_vm_copy_move_audio_test_data",
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
    });

    test('Add local playlist with a comma in its title', () async {
      const String invalidPlaylistTitle = 'S8 audio, invalid playlist title';

      expect(
        await playlistListVM.addPlaylist(
          playlistQuality: PlaylistQuality.voice,
          playlistUrl: '',
          localPlaylistTitle: invalidPlaylistTitle,
        ),
        null,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}

void testCopyAudioToPlaylist({
  required PlaylistListVM playlistListVM,
  required Playlist sourcePlaylist,
  required int sourceAudioIndex,
  required Playlist targetPlaylist,
  required bool hasCommentFile,
}) {
  Audio sourceAudio = sourcePlaylist.playableAudioLst[sourceAudioIndex];

  playlistListVM.copyAudioAndCommentToPlaylist(
    audio: sourceAudio,
    targetPlaylist: targetPlaylist,
  );

  Audio modifiedSourceAudio = sourcePlaylist.playableAudioLst[sourceAudioIndex];
  Audio copiedAudio = targetPlaylist.playableAudioLst[0];

  expect(
      ensureAudioAreEquals(
        modifiedSourceAudio,
        copiedAudio,
      ),
      isTrue);

  expect(modifiedSourceAudio.copiedFromPlaylistTitle == null, isTrue);

  expect(modifiedSourceAudio.copiedToPlaylistTitle == targetPlaylist.title,
      isTrue);

  expect(modifiedSourceAudio.movedFromPlaylistTitle == null, isTrue);

  expect(modifiedSourceAudio.movedToPlaylistTitle == null, isTrue);

  expect(
      copiedAudio.copiedFromPlaylistTitle ==
          sourceAudio.enclosingPlaylist!.title,
      isTrue);

  expect(copiedAudio.copiedToPlaylistTitle == null, isTrue);

  expect(copiedAudio.movedFromPlaylistTitle == null, isTrue);

  expect(copiedAudio.movedToPlaylistTitle == null, isTrue);

  if (hasCommentFile) {
    String commentFileName =
        copiedAudio.audioFileName.replaceFirst('.mp3', '.json');

    String targetCommentFilePathName = path.join(
        targetPlaylist.downloadPath, kCommentDirName, commentFileName);

    // Verify that the comment file of the copied audio is still present
    // in the source playlist directory
    expect(
      File(targetCommentFilePathName).existsSync(),
      isTrue,
    );

    // Verify that the comment file of the copied audio now present
    // in the target playlist directory
    expect(
      File(targetCommentFilePathName).existsSync(),
      isTrue,
    );
  }
}

void testMoveAudioAndCommentToPlaylist({
  required PlaylistListVM playlistListVM,
  required Playlist sourcePlaylist,
  required int sourceAudioIndex,
  required Playlist targetPlaylist,
  required bool hasCommentFile,
}) {
  Audio sourceAudio = sourcePlaylist.playableAudioLst[sourceAudioIndex];
  String commentFileName =
      sourceAudio.audioFileName.replaceFirst('.mp3', '.json');
  String sourceCommentFilePathName =
      path.join(sourcePlaylist.downloadPath, kCommentDirName, commentFileName);

  if (hasCommentFile) {
    // Verify that the comment file of the moved audio is present in the
    // source playlist directory
    expect(
      File(sourceCommentFilePathName).existsSync(),
      isTrue,
    );
  }

  playlistListVM.moveAudioAndCommentToPlaylist(
    audio: sourceAudio,
    targetPlaylist: targetPlaylist,
    keepAudioInSourcePlaylistDownloadedAudioLst: true,
  );

  List<Audio> sourcePlaylistDownloadedAudioLst =
      sourcePlaylist.downloadedAudioLst;

  int modifiedSourceAudioIndex = sourcePlaylistDownloadedAudioLst.indexWhere(
    (audio) => audio == sourceAudio,
  );

  Audio modifiedSourceAudio =
      sourcePlaylistDownloadedAudioLst[modifiedSourceAudioIndex];
  Audio movedAudio = targetPlaylist.playableAudioLst[0];

  expect(
      ensureAudioAreEquals(
        sourceAudio,
        movedAudio,
      ),
      isTrue);

  expect(modifiedSourceAudio.movedFromPlaylistTitle == null, isTrue);

  expect(
      modifiedSourceAudio.movedToPlaylistTitle == targetPlaylist.title, isTrue);

  expect(modifiedSourceAudio.copiedFromPlaylistTitle == null, isTrue);

  expect(modifiedSourceAudio.copiedToPlaylistTitle == null, isTrue);

  expect(
      movedAudio.movedFromPlaylistTitle == sourceAudio.enclosingPlaylist!.title,
      isTrue);

  expect(movedAudio.movedToPlaylistTitle == null, isTrue);

  expect(movedAudio.copiedFromPlaylistTitle == null, isTrue);

  expect(movedAudio.copiedToPlaylistTitle == null, isTrue);

  if (hasCommentFile) {
    String targetCommentFilePathName = path.join(
        targetPlaylist.downloadPath, kCommentDirName, commentFileName);

    // Verify that the comment file of the moved audio no longer present
    // in the source playlist directory
    expect(
      File(sourceCommentFilePathName).existsSync(),
      isFalse,
    );

    // Verify that the comment file of the moved audio now present
    // in the target playlist directory
    expect(
      File(targetCommentFilePathName).existsSync(),
      isTrue,
    );
  }
}

bool ensureAudioAreEquals(Audio audio1, Audio audio2) {
  return audio1.originalVideoTitle == audio2.originalVideoTitle &&
      audio1.validVideoTitle == audio2.validVideoTitle &&
      audio1.compactVideoDescription == audio2.compactVideoDescription &&
      audio1.videoUrl == audio2.videoUrl &&
      audio1.audioDownloadDateTime == audio2.audioDownloadDateTime &&
      audio1.audioDownloadDuration == audio2.audioDownloadDuration &&
      audio1.videoUploadDate == audio2.videoUploadDate &&
      audio1.audioFileName == audio2.audioFileName &&
      audio1.audioDuration == audio2.audioDuration &&
      audio1.audioFileSize == audio2.audioFileSize &&
      audio1.audioDownloadSpeed == audio2.audioDownloadSpeed &&
      audio1.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd ==
          audio2.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd &&
      audio1.audioPositionSeconds == audio2.audioPositionSeconds &&
      audio1.isPaused == audio2.isPaused &&
      audio1.audioPausedDateTime == audio2.audioPausedDateTime &&
      audio1.audioPlaySpeed == audio2.audioPlaySpeed &&
      audio1.isAudioMusicQuality == audio2.isAudioMusicQuality;
}
