import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audiolearn/services/sort_filter_parameters.dart';
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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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

      // Needed so that testing equality of source and target audio
      // returns true. This is due to the fact that when copying or
      // moving an audio to a target playlist, the copied or moved
      // audio play speed is set to the target olaylist audio play
      // speed.
      targetPlaylist.audioPlaySpeed = 1.25;

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

      // Needed so that testing equality of source and target audio
      // returns true. This is due to the fact that when copying or
      // moving an audio to a target playlist, the copied or moved
      // audio play speed is set to the target olaylist audio play
      // speed.
      targetPlaylist.audioPlaySpeed = 1.25;

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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist sourcePlaylist = playlistListVM.getSelectedPlaylists()[0];
      Audio currentAudio = sourcePlaylist.playableAudioLst[7];

      // Obtaining the next playable audio
      Audio? nextAudio =
          playlistListVM.getNextDownloadedOrSortFilteredNotFullyPlayedAudio(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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
      Playlist sourcePlaylist = selectablePlaylistLst[3]; // local
      Audio lastDownloadedAudio = sourcePlaylist.playableAudioLst[0];

      // Obtaining the next playable audio
      Audio? nextAudio =
          playlistListVM.getNextDownloadedOrSortFilteredNotFullyPlayedAudio(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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
      Playlist sourcePlaylist = selectablePlaylistLst[5]; // local_3
      Audio lastDownloadedAudio = sourcePlaylist.playableAudioLst[0];

      // Obtaining the next playable audio
      Audio? nextAudio =
          playlistListVM.getNextDownloadedOrSortFilteredNotFullyPlayedAudio(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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
      Audio? nextaudioIslastdownloaded =
          playlistListVM.getNextDownloadedOrSortFilteredNotFullyPlayedAudio(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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
  group('Obtain list of playable audio', () {
    late PlaylistListVM playlistListVM;

    test(
        'Playlist has several not fully played audio. Last downloaded audio is not played.',
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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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

      // Obtaining the audio from which to obtain the next playable
      // audio
      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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
        'Playlist has several not fully played audio. Last downloaded audio is fully played.',
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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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

      // Obtaining the audio from which to obtain the next playable
      // audio
      Playlist playlist = playlistListVM.getUpToDateSelectablePlaylists()[1];
      playlistListVM.setPlaylistSelection(
        playlistSelectedOrUnselected: playlist,
        isPlaylistSelected: true,
      );

      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      expect(playableAudioLst.length, 3);
      expect(playableAudioLst[0].validVideoTitle,
          "Les besoins artificiels par R.Keucheyan");
      expect(playableAudioLst[1].validVideoTitle,
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)");
      expect(playableAudioLst[2].validVideoTitle,
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau");

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('Playlist has no not fully played audio', () async {
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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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
      Playlist playlist = playlistListVM.getUpToDateSelectablePlaylists()[2];
      playlistListVM.setPlaylistSelection(
        playlistSelectedOrUnselected: playlist,
        isPlaylistSelected: true,
      );

      // Obtaining the audio from which to obtain the next playable
      // audio
      List<Audio> playableAudioLst = playlistListVM
          .getSelectedPlaylistNotFullyPlayedAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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

      WarningMessageVM warningMessageVM = WarningMessageVM();

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
  group('Save playlists, comments and settings json files to zip', () {
    test('settings and playlists sub dirs in same root path', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
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

      await playlistListVM.savePlaylistsCommentsAndSettingsJsonFilesToZip(
        targetDirectoryPath: kPlaylistDownloadRootPathWindowsTest,
      );

      List<String> zipLst = DirUtil.listFileNamesInDir(
        directoryPath: kApplicationPathWindowsTest,
        fileExtension: 'zip',
      );

      List<String> expectedZipContent = [
        "Empty/Empty.json",
        "local/local.json",
        "local_comment/local_comment.json",
        "local_delete_comment/comments/240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
        "local_delete_comment/local_delete_comment.json",
        "S8 audio/comments/240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
        "S8 audio/comments/240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
        "S8 audio/comments/240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
        "S8 audio/comments/New file name.json",
        "S8 audio/S8 audio.json",
        "settings.json",
      ];

      List<String> zipFilePathNamesLst = await listFilesInZip(
        zipFilePathName:
            kApplicationPathWindowsTest + path.separator + zipLst[0],
      );

      expect(
        zipFilePathNamesLst,
        expectedZipContent,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('settings in app dir and playlists in playlists root path', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_json_only_test",
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

      await playlistListVM.savePlaylistsCommentsAndSettingsJsonFilesToZip(
        targetDirectoryPath: kPlaylistDownloadRootPathWindowsTest,
      );

      List<String> zipLst = DirUtil.listFileNamesInDir(
        directoryPath: kApplicationPathWindowsTest,
        fileExtension: 'zip',
      );

      List<String> expectedZipContent = [
        "playlists/Empty/Empty.json",
        "playlists/local/local.json",
        "playlists/local_comment/local_comment.json",
        "playlists/local_delete_comment/comments/240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
        "playlists/local_delete_comment/local_delete_comment.json",
        "playlists/S8 audio/comments/240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12.json",
        "playlists/S8 audio/comments/240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
        "playlists/S8 audio/comments/240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10.json",
        "playlists/S8 audio/comments/New file name.json",
        "playlists/S8 audio/S8 audio.json",
        "settings.json",
      ];

      List<String> zipFilePathNamesLst = await listFilesInZip(
        zipFilePathName:
            kApplicationPathWindowsTest + path.separator + zipLst[0],
      );

      expect(
        zipFilePathNamesLst,
        expectedZipContent,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('''Delete Sort/Filtered audio physically and from selected playlist.''',
      () {
    test('''Filtered by 'listenedNoCom' Sort/filtered parms audio deletion.''',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}delete_filtered_audio_test",
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
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      const String audioSortFilterParametersName = 'listenedNoCom';

      // Set the 'listenedNoCom' audio Sort/Filter parameters in the
      // playlistListVM

      AudioSortFilterParameters audioSortFilterParameters =
          playlistListVM.getAudioSortFilterParameters(
        audioSortFilterParametersName: audioSortFilterParametersName,
      );

      playlistListVM.setSortFilterForSelectedPlaylistPlayableAudiosAndParms(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
        sortFilteredSelectedPlaylistPlayableAudio: playlistListVM
            .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
          audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
          passedAudioSortFilterParameters: audioSortFilterParameters,
        ),
        audioSortFilterParms: audioSortFilterParameters,
        audioSortFilterParmsName: audioSortFilterParametersName,
        searchSentence: '',
        doNotifyListeners: false,
      );

      // Deleting the filtered audio physically and from the selected playlist
      playlistListVM.deleteSortFilteredAudioLst();

      // Verify that the physical audio to delete files have been deleted

      List<String> audioFileNameToDeleteLst = [
        "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
        "240107-094528-Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik 23-09-10.mp3",
      ];

      List<String> listMp3FileNames = DirUtil.listFileNamesInDir(
        directoryPath:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio",
        fileExtension: 'mp3',
      );

      for (String audioFileNameToDelete in audioFileNameToDeleteLst) {
        expect(
          listMp3FileNames.contains(audioFileNameToDelete),
          false,
        );
      }

      // Verify that the other files were not deleted

      List<String> remainingAudioFileNameLst = [
        "231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23.mp3",
        "231226-094534-3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher) 23-12-01.mp3",
        "240107-094520-Les besoins artificiels par R.Keucheyan 24-01-05.mp3",
        "240107-094546-La résilience insulaire par Fiona Roche 24-01-03.mp3",
        "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
      ];

      for (String remainingAudioFileName in remainingAudioFileNameLst) {
        expect(
          listMp3FileNames.contains(remainingAudioFileName),
          true,
        );
      }
      // Verify the 'S8 audio' playlist json file

      Playlist loadedPlaylist = loadPlaylist('S8 audio');

      expect(loadedPlaylist.downloadedAudioLst.length, 18);

      List<String> downloadedAudioLst = loadedPlaylist.downloadedAudioLst
          .map((Audio audio) => audio.validVideoTitle)
          .toList();

      List<String> audioTitleBeforeDeletionLst = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "La surpopulation mondiale par Jancovici et Barrau",
        "La résilience insulaire par Fiona Roche",
        "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        "Les besoins artificiels par R.Keucheyan",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
      ];

      for (String audioTitleToDelete in audioTitleBeforeDeletionLst) {
        expect(
          downloadedAudioLst.contains(audioTitleToDelete),
          true,
        );
      }

      expect(loadedPlaylist.playableAudioLst.length, 5);

      List<String> audioTitleAfterDeletionLst = [
        "La surpopulation mondiale par Jancovici et Barrau",
        "La résilience insulaire par Fiona Roche",
        "Les besoins artificiels par R.Keucheyan",
        "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau",
        "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
      ];

      List<String> playableAudioLst = loadedPlaylist.playableAudioLst
          .map((Audio audio) => audio.validVideoTitle)
          .toList();

      for (String audioTitleAfterDeletion in audioTitleAfterDeletionLst) {
        expect(
          playableAudioLst.contains(audioTitleAfterDeletion),
          true,
        );
      }

      List<String> deletedAudioTitleLst = [
        "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
        "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
      ];

      for (String deletedAudioTitle in deletedAudioTitleLst) {
        expect(
          playableAudioLst.contains(deletedAudioTitle),
          false,
        );
      }

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('moveAudioToPlaylist moves audio and its comments to playlist',
        () async {
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
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

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

      // Needed so that testing equality of source and target audio
      // returns true. This is due to the fact that when copying or
      // moving an audio to a target playlist, the copied or moved
      // audio play speed is set to the target olaylist audio play
      // speed.
      targetPlaylist.audioPlaySpeed = 1.25;

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
  group('''Obtain list of playlists using sort/filter parms name.''', () {
    test('''Test.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}sort_filtered_parms_name_deletion_no_mp3_test",
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
      // playlistListVM to know which playlists are
      // selected and which are not
      playlistListVM.getUpToDateSelectablePlaylists();

      _testGetPlaylistsUsingSortFilterParmsName(
        playlistListVM: playlistListVM,
        audioSortFilterParmsName: 'Title asc',
        expectedPlaylistTitleLst: [
          'S8 audio',
          'local',
        ],
      );

      _testGetPlaylistsUsingSortFilterParmsName(
        playlistListVM: playlistListVM,
        audioSortFilterParmsName: 'asc listened',
        expectedPlaylistTitleLst: [
          'local_2',
          'local_3',
        ],
      );

      _testGetPlaylistsUsingSortFilterParmsName(
        playlistListVM: playlistListVM,
        audioSortFilterParmsName: 'desc listened',
        expectedPlaylistTitleLst: [
          'local_2',
        ],
      );

      _testGetPlaylistsUsingSortFilterParmsName(
        playlistListVM: playlistListVM,
        audioSortFilterParmsName: 'Unused SF',
        expectedPlaylistTitleLst: [],
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}

void _testGetPlaylistsUsingSortFilterParmsName(
    {required PlaylistListVM playlistListVM,
    required String audioSortFilterParmsName,
    required List<String> expectedPlaylistTitleLst}) {
  List<Playlist> playlistLst =
      playlistListVM.getPlaylistsUsingSortFilterParmsName(
    audioSortFilterParmsName: audioSortFilterParmsName,
  );

  List<String> playlistTitleLst =
      playlistLst.map((Playlist playlist) => playlist.title).toList();

  expect(
    playlistTitleLst,
    expectedPlaylistTitleLst,
  );
}

Playlist loadPlaylist(String playListOneName) {
  return JsonDataService.loadFromFile(
      jsonPathFileName:
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playListOneName${path.separator}$playListOneName.json",
      type: Playlist);
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
    audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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

Future<List<String>> listFilesInZip({
  required String zipFilePathName,
}) async {
  // Open the zip file
  File zipFile = File(zipFilePathName);
  List<int> bytes = await zipFile.readAsBytes();

  // Decode the zip file
  Archive archive = ZipDecoder().decodeBytes(bytes);

  // List to store the full paths of files
  List<String> filePaths = [];

  // Loop through the archive files and get their full paths (name includes directories)
  for (ArchiveFile file in archive) {
    if (!file.isFile) continue; // Skip directories
    filePaths.add(file.name); // File name includes the full path inside the zip
  }

  return filePaths;
}
