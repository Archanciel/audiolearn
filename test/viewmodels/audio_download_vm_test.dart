import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';

import '../services/mock_shared_preferences.dart';
import 'mock_audio_download_vm.dart';

void main() {
  group('Video description handling', () {
    test('Test extract video chapters time position', () async {
      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: SettingsDataService(
            sharedPreferences: MockSharedPreferences(), isTest: true),
      );

      String videoDescription = '''Ma chaîne YouTube principale
  https://www.youtube.com/@LeFuturologue


  ME SOUTENIR FINANCIÈREMENT :

  Sur Tipeee
  https://fr.tipeee.com/le-futurologue
  Sur PayPal
  https://www.paypal.com/donate/?hosted_button_id=BBXFGSM5D5WQS
  Sur Patreon
  https://patreon.com/LeFuturologue


  MES VIDÉOS COURTES :

  Sur YouTube 
  https://youtube.com/@LeFuturologue/shorts
  Sur Instagram
  https://www.instagram.com/le.futurologue/
  Sur TikTok
  https://www.tiktok.com/@le.futurologue


  TIME CODE :

  0:00 Introduction
  1:37 Qui es-tu ?
  3:29 Les IA vont-elles tous nous mettre au chômage ?
  21:01 Faut-il mettre les IA en open source ? 
  48:05 Comment fonctionne les agents ?
  1:14:31 Définition de l’IA autonome, de l’IA générale et de la super IA
  1:41:23 Que manque-t-il pour avoir une AGI ?
  1:57:23 À quel point faut-il avoir peur de L’IA ?
  2:04:36 Les meilleurs arguments de ceux qui ne croient pas aux risques existentiels des AGI 
  2:11:48 Y aura-t-il plusieurs AGI ?
  2:14:06 Est-ce que l’explosion d’intelligence sera rapide ? 
  2:22:37 Quels impacts aurait une IA qui devient consciente ?
  2:53:18 Quelle est la probabilité qu’on arrive à aligner une AGI avant qu’on en crée une ?
  3:09:54 Ressources pour aller plus loin
  3:11:57 Un message pour l’humanité 


  RESSOURCES MENTIONNÉES :

  La chaîne YouTube de Jérémy
  https://youtube.com/@suboptimalchannel9704
  Le Twitter de Jérémy
  https://twitter.com/suboptimalc?s=21&t=KiEIZQwoZSOhseL0LUGLpg
  L’organisation « EffiSciences »
  https://www.effisciences.org/

  ChatGPT''';

      Map<String, String> expectedChapters = {
        'Introduction': '0:00',
        'Qui es-tu ?': '1:37',
        'Les IA vont-elles tous nous mettre au chômage ?': '3:29',
        'Faut-il mettre les IA en open source ? ': '21:01',
        'Comment fonctionne les agents ?': '48:05',
        'Définition de l’IA autonome, de l’IA générale et de la super IA':
            '1:14:31',
        'Que manque-t-il pour avoir une AGI ?': '1:41:23',
        'À quel point faut-il avoir peur de L’IA ?': '1:57:23',
        'Les meilleurs arguments de ceux qui ne croient pas aux risques existentiels des AGI ':
            '2:04:36',
        'Y aura-t-il plusieurs AGI ?': '2:11:48',
        'Est-ce que l’explosion d’intelligence sera rapide ? ': '2:14:06',
        'Quels impacts aurait une IA qui devient consciente ?': '2:22:37',
        'Quelle est la probabilité qu’on arrive à aligner une AGI avant qu’on en crée une ?':
            '2:53:18',
        'Ressources pour aller plus loin': '3:09:54',
        'Un message pour l’humanité ': '3:11:57',
      };

      Map<String, String> chapters =
          audioDownloadVM.getVideoDescriptionChapters(
        videoDescription: videoDescription,
      );

      expect(chapters, expectedChapters);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Update playlist json file', () {
    test('Check that playlist download path is correctly updated', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_update_playlists",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      const String playListOneName = "audio_learn_test_download_2_small_videos";

      // Load Playlist from the file
      Playlist loadedPlaylistOne = loadPlaylist(playListOneName);
      expect(loadedPlaylistOne.downloadPath,
          "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\previous_audio\\playlist_downloaded\\audio_learn_test_download_2_small_videos");

      const String playListTwoName = "audio_player_view_2_shorts_test";

      // Load Playlist from the file
      Playlist loadedPlaylistTwo = loadPlaylist(playListTwoName);
      expect(loadedPlaylistTwo.downloadPath,
          "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\other_audio\\playlist_downloaded\\audio_player_view_2_shorts_test");

      const String playListThreeName = "local_3";

      // Load Playlist from the file
      Playlist loadedPlaylistThree = loadPlaylist(playListThreeName);
      expect(loadedPlaylistThree.downloadPath,
          "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\previous_audio\\playlist_downloaded\\local_3");

      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // Update the playlist json files
      audioDownloadVM.loadExistingPlaylists();
      audioDownloadVM.updatePlaylistJsonFiles();

      // reLoad Playlist from the file and check that the
      // download path was updated correctly
      loadedPlaylistOne = loadPlaylist(playListOneName);
      expect(loadedPlaylistOne.downloadPath,
          "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\audio\\audio_learn_test_download_2_small_videos");

      // reLoad Playlist from the file and check that the
      // download path was updated correctly
      loadedPlaylistTwo = loadPlaylist(playListTwoName);
      expect(loadedPlaylistTwo.downloadPath,
          "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\audio\\audio_player_view_2_shorts_test");

      // reLoad Playlist from the file and check that the
      // download path was updated correctly
      loadedPlaylistThree = loadPlaylist(playListThreeName);
      expect(loadedPlaylistThree.downloadPath,
          "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\audio\\local_3");

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group(
      '''Copy audio to playlist and then trying to copy it again in the same target
         playlist not keeping it in the source playlist''', () {
    test('Copy audio to playlist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_copy_move__audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Playlist sourcePlaylist = audioDownloadVM.listOfPlaylist[1];
      Audio copiedAudio = sourcePlaylist.downloadedAudioLst[0];
      Playlist targetPlaylist = audioDownloadVM.listOfPlaylist[2];

      expect(sourcePlaylist.downloadedAudioLst.length, 2);
      expect(sourcePlaylist.playableAudioLst.length, 2);
      expect(targetPlaylist.downloadedAudioLst.length, 5);
      expect(targetPlaylist.playableAudioLst.length, 0);

      // Copying the audio to the target playlist
      bool wasCopied = audioDownloadVM.copyAudioToPlaylist(
        audio: copiedAudio,
        targetPlaylist: targetPlaylist,
      );

      expect(wasCopied, true);

      // Now verifying source and target playlists data

      // Loading playlists from the json file
      Playlist loadedSourcePlaylist = loadPlaylist(sourcePlaylist.title);
      List<Audio> loadedSourcePlaylistDownloadedAudioLst =
          loadedSourcePlaylist.downloadedAudioLst;
      List<Audio> loadedSourcePlaylistPlayableAudioLst =
          loadedSourcePlaylist.playableAudioLst;
      Audio loadedSourcePlaylistCopiedDownloadedAudio =
          loadedSourcePlaylistDownloadedAudioLst[0];
      Audio loadedSourcePlaylistCopiedPlayableAudio =
          loadedSourcePlaylistPlayableAudioLst[1];

      String targetPlaylistTitle = targetPlaylist.title;
      Playlist loadedTargetPlaylist = loadPlaylist(targetPlaylistTitle);
      List<Audio> downloadedAudioLst = loadedTargetPlaylist.downloadedAudioLst;
      Audio loadedTargetPlaylistCopiedDownloadAudio = downloadedAudioLst[5];
      List<Audio> loadedTargetPlaylistPlayableAudioLst =
          loadedTargetPlaylist.playableAudioLst;
      Audio loadedTargetPlaylistCopiedPlayableAudio =
          loadedTargetPlaylistPlayableAudioLst[0];

      expect(loadedSourcePlaylistDownloadedAudioLst.length, 2);
      expect(loadedSourcePlaylistPlayableAudioLst.length, 2);
      expect(
          loadedSourcePlaylistCopiedDownloadedAudio.movedToPlaylistTitle, null);
      expect(loadedSourcePlaylistCopiedDownloadedAudio.movedFromPlaylistTitle,
          null);
      expect(loadedSourcePlaylistCopiedDownloadedAudio.copiedFromPlaylistTitle,
          null);
      expect(loadedSourcePlaylistCopiedDownloadedAudio.copiedToPlaylistTitle,
          targetPlaylistTitle);

      expect(
          loadedSourcePlaylistCopiedPlayableAudio.movedToPlaylistTitle, null);
      expect(
          loadedSourcePlaylistCopiedPlayableAudio.movedFromPlaylistTitle, null);
      expect(loadedSourcePlaylistCopiedPlayableAudio.copiedFromPlaylistTitle,
          null);
      expect(loadedSourcePlaylistCopiedPlayableAudio.copiedToPlaylistTitle,
          targetPlaylistTitle);

      expect(downloadedAudioLst.length, 6);
      expect(
          loadedTargetPlaylistCopiedDownloadAudio.movedFromPlaylistTitle, null);
      expect(
          loadedTargetPlaylistCopiedDownloadAudio.movedToPlaylistTitle, null);
      expect(loadedTargetPlaylistCopiedDownloadAudio.copiedFromPlaylistTitle,
          loadedSourcePlaylist.title);
      expect(
          loadedTargetPlaylistCopiedDownloadAudio.copiedToPlaylistTitle, null);

      expect(loadedTargetPlaylistPlayableAudioLst.length, 1);
      expect(
          loadedTargetPlaylistCopiedPlayableAudio.movedFromPlaylistTitle, null);
      expect(
          loadedTargetPlaylistCopiedPlayableAudio.movedToPlaylistTitle, null);
      expect(loadedTargetPlaylistCopiedPlayableAudio.copiedFromPlaylistTitle,
          loadedSourcePlaylist.title);
      expect(
          loadedTargetPlaylistCopiedPlayableAudio.copiedToPlaylistTitle, null);

      // Copying again the same the audio to the target playlist
      wasCopied = audioDownloadVM.copyAudioToPlaylist(
        audio: copiedAudio,
        targetPlaylist: targetPlaylist,
      );

      expect(wasCopied, false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''Copy an audio file which was manually deleted from the source playlist
           directory''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_copy_move__audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Playlist sourcePlaylist = audioDownloadVM.listOfPlaylist[1];
      Audio copiedAudio = sourcePlaylist.downloadedAudioLst[0];
      Playlist targetPlaylist = audioDownloadVM.listOfPlaylist[2];

      expect(sourcePlaylist.downloadedAudioLst.length, 2);
      expect(sourcePlaylist.playableAudioLst.length, 2);
      expect(targetPlaylist.downloadedAudioLst.length, 5);
      expect(targetPlaylist.playableAudioLst.length, 0);

      // Manually deleting the audio to be copied from the source playlist
      DirUtil.deleteFileIfExist(pathFileName: copiedAudio.filePathName);

      // Copying the audio to the target playlist
      bool wasCopied = audioDownloadVM.copyAudioToPlaylist(
        audio: copiedAudio,
        targetPlaylist: targetPlaylist,
      );

      expect(wasCopied, false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Move audio to playlist', () {
    test('''Moved audio kept in source playlist and then trying to move it again
            in the same target playlist keeping it in the source  playlist''',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_copy_move__audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Playlist sourcePlaylist = audioDownloadVM.listOfPlaylist[1];
      Audio movedAudio = sourcePlaylist.downloadedAudioLst[0];
      Playlist targetPlaylist = audioDownloadVM.listOfPlaylist[2];

      expect(sourcePlaylist.downloadedAudioLst.length, 2);
      expect(sourcePlaylist.playableAudioLst.length, 2);
      expect(targetPlaylist.downloadedAudioLst.length, 5);
      expect(targetPlaylist.playableAudioLst.length, 0);

      // Moving the audio keeping it in source playlist
      bool wasMoved = audioDownloadVM.moveAudioToPlaylist(
        audio: movedAudio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: true,
      );

      expect(wasMoved, true);

      // Now verifying source and target playlists data

      // Loading playlists from the json file
      Playlist loadedSourcePlaylist = loadPlaylist(sourcePlaylist.title);
      List<Audio> loadedSourcePlaylistDownloadedAudioLst =
          loadedSourcePlaylist.downloadedAudioLst;
      Audio loadedSourcePlaylistMovedDownloadedAudio =
          loadedSourcePlaylistDownloadedAudioLst[0];
      String targetPlaylistTitle = targetPlaylist.title;
      Playlist loadedTargetPlaylist = loadPlaylist(targetPlaylistTitle);
      List<Audio> loadedTargetPlaylistPlayableAudioLst =
          loadedTargetPlaylist.playableAudioLst;
      Audio loadedTargetPlaylistMovedPlayableAudio =
          loadedTargetPlaylistPlayableAudioLst[0];

      expect(loadedSourcePlaylistDownloadedAudioLst.length, 2);
      expect(loadedSourcePlaylist.playableAudioLst.length, 1);
      expect(loadedSourcePlaylistMovedDownloadedAudio.movedToPlaylistTitle,
          targetPlaylistTitle);
      expect(loadedSourcePlaylistMovedDownloadedAudio.movedFromPlaylistTitle,
          null);
      expect(loadedSourcePlaylistMovedDownloadedAudio.copiedFromPlaylistTitle,
          null);
      expect(
          loadedSourcePlaylistMovedDownloadedAudio.copiedToPlaylistTitle, null);

      expect(loadedTargetPlaylist.downloadedAudioLst.length, 6);
      expect(loadedTargetPlaylistPlayableAudioLst.length, 1);
      expect(loadedTargetPlaylistMovedPlayableAudio.movedFromPlaylistTitle,
          loadedSourcePlaylist.title);
      expect(loadedTargetPlaylistMovedPlayableAudio.movedToPlaylistTitle, null);
      expect(
          loadedTargetPlaylistMovedPlayableAudio.copiedFromPlaylistTitle, null);
      expect(
          loadedTargetPlaylistMovedPlayableAudio.copiedToPlaylistTitle, null);

      // Moving again the same audio keeping it in source playlist
      wasMoved = audioDownloadVM.moveAudioToPlaylist(
        audio: movedAudio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: true,
      );

      expect(wasMoved, false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('''Moved audio not kept in source playlist and then trying to move it 
           again in the same target playlist not keeping it in the source
           playlist''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_copy_move__audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Playlist sourcePlaylist = audioDownloadVM.listOfPlaylist[1];
      Audio movedAudio = sourcePlaylist.downloadedAudioLst[0];
      Playlist targetPlaylist = audioDownloadVM.listOfPlaylist[2];

      expect(sourcePlaylist.downloadedAudioLst.length, 2);
      expect(sourcePlaylist.playableAudioLst.length, 2);
      expect(targetPlaylist.downloadedAudioLst.length, 5);
      expect(targetPlaylist.playableAudioLst.length, 0);

      // Moving the audio not keeping it in source playlist
      bool wasMoved = audioDownloadVM.moveAudioToPlaylist(
        audio: movedAudio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: false,
      );

      expect(wasMoved, true);

      // Now verifying source and target playlists data

      // Loading playlists from the json file
      Playlist loadedSourcePlaylist = loadPlaylist(sourcePlaylist.title);
      List<Audio> loadedSourcePlaylistDownloadedAudioLst =
          loadedSourcePlaylist.downloadedAudioLst;
      String targetPlaylistTitle = targetPlaylist.title;
      Playlist loadedTargetPlaylist = loadPlaylist(targetPlaylistTitle);
      List<Audio> loadedTargetPlaylistPlayableAudioLst =
          loadedTargetPlaylist.playableAudioLst;
      Audio loadedTargetPlaylistMovedPlayableAudio =
          loadedTargetPlaylistPlayableAudioLst[0];

      expect(loadedSourcePlaylistDownloadedAudioLst.length, 1);
      expect(loadedSourcePlaylist.playableAudioLst.length, 1);

      expect(loadedTargetPlaylist.downloadedAudioLst.length, 6);
      expect(loadedTargetPlaylistPlayableAudioLst.length, 1);
      expect(loadedTargetPlaylistMovedPlayableAudio.movedFromPlaylistTitle,
          loadedSourcePlaylist.title);
      expect(loadedTargetPlaylistMovedPlayableAudio.movedToPlaylistTitle, null);
      expect(
          loadedTargetPlaylistMovedPlayableAudio.copiedFromPlaylistTitle, null);
      expect(
          loadedTargetPlaylistMovedPlayableAudio.copiedToPlaylistTitle, null);

      // Moving again the audio suppressed by the first move
      wasMoved = audioDownloadVM.moveAudioToPlaylist(
        audio: movedAudio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: false,
      );

      expect(wasMoved, false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''Moved audio kept in source playlist and then trying to move it again in
           in the same target playlist but this tyme not keeping it in the source
           playlist''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_copy_move__audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Playlist sourcePlaylist = audioDownloadVM.listOfPlaylist[1];
      Audio movedAudio = sourcePlaylist.downloadedAudioLst[0];
      Playlist targetPlaylist = audioDownloadVM.listOfPlaylist[2];

      expect(sourcePlaylist.downloadedAudioLst.length, 2);
      expect(sourcePlaylist.playableAudioLst.length, 2);
      expect(targetPlaylist.downloadedAudioLst.length, 5);
      expect(targetPlaylist.playableAudioLst.length, 0);

      // Moving the audio keeping it in source playlist
      bool wasMoved = audioDownloadVM.moveAudioToPlaylist(
        audio: movedAudio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: true,
      );

      expect(wasMoved, true);

      // Now verifying source and target playlists data

      // Loading playlists from the json file
      Playlist loadedSourcePlaylist = loadPlaylist(sourcePlaylist.title);
      List<Audio> loadedSourcePlaylistDownloadedAudioLst =
          loadedSourcePlaylist.downloadedAudioLst;
      Audio loadedSourcePlaylistMovedDownloadedAudio =
          loadedSourcePlaylistDownloadedAudioLst[0];
      String targetPlaylistTitle = targetPlaylist.title;
      Playlist loadedTargetPlaylist = loadPlaylist(targetPlaylistTitle);
      List<Audio> loadedTargetPlaylistPlayableAudioLst =
          loadedTargetPlaylist.playableAudioLst;
      Audio loadedTargetPlaylistMovedPlayableAudio =
          loadedTargetPlaylistPlayableAudioLst[0];

      expect(loadedSourcePlaylistDownloadedAudioLst.length, 2);
      expect(loadedSourcePlaylist.playableAudioLst.length, 1);
      expect(loadedSourcePlaylistMovedDownloadedAudio.movedToPlaylistTitle,
          targetPlaylistTitle);
      expect(loadedSourcePlaylistMovedDownloadedAudio.movedFromPlaylistTitle,
          null);
      expect(loadedSourcePlaylistMovedDownloadedAudio.copiedFromPlaylistTitle,
          null);
      expect(
          loadedSourcePlaylistMovedDownloadedAudio.copiedToPlaylistTitle, null);

      expect(loadedTargetPlaylist.downloadedAudioLst.length, 6);
      expect(loadedTargetPlaylistPlayableAudioLst.length, 1);
      expect(loadedTargetPlaylistMovedPlayableAudio.movedFromPlaylistTitle,
          loadedSourcePlaylist.title);
      expect(loadedTargetPlaylistMovedPlayableAudio.movedToPlaylistTitle, null);
      expect(
          loadedTargetPlaylistMovedPlayableAudio.copiedFromPlaylistTitle, null);
      expect(
          loadedTargetPlaylistMovedPlayableAudio.copiedToPlaylistTitle, null);

      // Moving again the same audio not keeping it in source playlist
      wasMoved = audioDownloadVM.moveAudioToPlaylist(
        audio: movedAudio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: false,
      );

      expect(wasMoved, false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''Moving an audio which was manually deleted from the in source playlist
           directoryt''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_copy_move__audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Playlist sourcePlaylist = audioDownloadVM.listOfPlaylist[1];
      Audio movedAudio = sourcePlaylist.downloadedAudioLst[0];
      Playlist targetPlaylist = audioDownloadVM.listOfPlaylist[2];

      expect(sourcePlaylist.downloadedAudioLst.length, 2);
      expect(sourcePlaylist.playableAudioLst.length, 2);
      expect(targetPlaylist.downloadedAudioLst.length, 5);
      expect(targetPlaylist.playableAudioLst.length, 0);

      // Moving the audio keeping it in source playlist
      bool wasMoved = audioDownloadVM.moveAudioToPlaylist(
        audio: movedAudio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: true,
      );

      expect(wasMoved, true);

      // Now verifying source and target playlists data

      // Loading playlists from the json file
      Playlist loadedSourcePlaylist = loadPlaylist(sourcePlaylist.title);
      List<Audio> loadedSourcePlaylistDownloadedAudioLst =
          loadedSourcePlaylist.downloadedAudioLst;
      Audio loadedSourcePlaylistMovedDownloadedAudio =
          loadedSourcePlaylistDownloadedAudioLst[0];
      String targetPlaylistTitle = targetPlaylist.title;
      Playlist loadedTargetPlaylist = loadPlaylist(targetPlaylistTitle);
      List<Audio> loadedTargetPlaylistPlayableAudioLst =
          loadedTargetPlaylist.playableAudioLst;
      Audio loadedTargetPlaylistMovedPlayableAudio =
          loadedTargetPlaylistPlayableAudioLst[0];

      expect(loadedSourcePlaylistDownloadedAudioLst.length, 2);
      expect(loadedSourcePlaylist.playableAudioLst.length, 1);
      expect(loadedSourcePlaylistMovedDownloadedAudio.movedToPlaylistTitle,
          targetPlaylistTitle);
      expect(loadedSourcePlaylistMovedDownloadedAudio.movedFromPlaylistTitle,
          null);
      expect(loadedSourcePlaylistMovedDownloadedAudio.copiedFromPlaylistTitle,
          null);
      expect(
          loadedSourcePlaylistMovedDownloadedAudio.copiedToPlaylistTitle, null);

      expect(loadedTargetPlaylist.downloadedAudioLst.length, 6);
      expect(loadedTargetPlaylistPlayableAudioLst.length, 1);
      expect(loadedTargetPlaylistMovedPlayableAudio.movedFromPlaylistTitle,
          loadedSourcePlaylist.title);
      expect(loadedTargetPlaylistMovedPlayableAudio.movedToPlaylistTitle, null);
      expect(
          loadedTargetPlaylistMovedPlayableAudio.copiedFromPlaylistTitle, null);
      expect(
          loadedTargetPlaylistMovedPlayableAudio.copiedToPlaylistTitle, null);

      // Moving again the same audio keeping it in source playlist
      wasMoved = audioDownloadVM.moveAudioToPlaylist(
        audio: movedAudio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: true,
      );

      expect(wasMoved, false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Rename audio file', () {
    test('File with new name not exist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_modify_audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Audio audioToRename = audioDownloadVM
          .listOfPlaylist[0].downloadedAudioLst[0]; // Really short video

      const String newFileName = "new_name.mp3";
      audioDownloadVM.renameAudioFile(
        audio: audioToRename,
        modifiedAudioFileName: newFileName,
      );

      // Verify that the renamed file exists
      const String playListName = "audio_player_view_2_shorts_test";
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playListName${path.separator}$newFileName";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Load Playlist from the file
      Playlist loadedPlaylist = loadPlaylist(playListName);

      // Verify that the audio file name was changed
      // (playabeAudioLst and downloadedAudioLst contain the
      // same audios, but in inverse order)
      expect(loadedPlaylist.playableAudioLst[1].audioFileName, newFileName);
      expect(loadedPlaylist.downloadedAudioLst[0].audioFileName, newFileName);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('File with new name exist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_modify_audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Audio audioToRename = audioDownloadVM
          .listOfPlaylist[0].downloadedAudioLst[0]; // Really short video

      const String fileNameOfExistingFile =
          "231117-002828-morning _ cinematic video 23-07-01.mp3";
      audioDownloadVM.renameAudioFile(
        audio: audioToRename,
        modifiedAudioFileName: fileNameOfExistingFile,
      );

      // Verify that the not renamed file exists
      const String playListName = "audio_player_view_2_shorts_test";
      final String renamedAudioFilePath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playListName${path.separator}$fileNameOfExistingFile";
      expect(File(renamedAudioFilePath).existsSync(), true);

      // Load Playlist from the file
      Playlist loadedPlaylist = loadPlaylist(playListName);

      // Verify that the audio file name was not changed
      // (playabeAudioLst and downloadedAudioLst contain the
      // same audios, but in inverse order)
      expect(loadedPlaylist.playableAudioLst[1].audioFileName,
          '231117-002826-Really short video 23-07-01.mp3');
      expect(loadedPlaylist.downloadedAudioLst[0].audioFileName,
          '231117-002826-Really short video 23-07-01.mp3');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Modify audio title', () {
    test('Modify audio title', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_download_vm_modify_audio",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      audioDownloadVM.loadExistingPlaylists();

      Audio audioToModify = audioDownloadVM
          .listOfPlaylist[0].downloadedAudioLst[0]; // Really short video
      final String initialAudioTitle = audioToModify.validVideoTitle;

      const String newAudioTitle = "This video is very short";
      audioDownloadVM.modifyAudioTitle(
        audio: audioToModify,
        modifiedAudioTitle: newAudioTitle,
      );

      // Load Playlist from the file
      const String playListName = "audio_player_view_2_shorts_test";
      Playlist loadedPlaylist = loadPlaylist(playListName);

      // Verify that the audio title was changed in the playable
      // audio list only (playabeAudioLst and downloadedAudioLst
      // contain the same audios, but in inverse order)
      expect(loadedPlaylist.playableAudioLst[1].validVideoTitle, newAudioTitle);
      expect(loadedPlaylist.downloadedAudioLst[0].validVideoTitle,
          initialAudioTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
  group('Import audio files in playlist', () {
    test('''Import one not existing file in playlist whose play speed is set
           to 1.0 and then re-import it so that it will not be imported a
           second time. Since the playlist play speed is defined, it will
           be applied to the imported Audio.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}import_audio_file_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Using MockAudioDownloadVM which inherits from AudioDownloadVM
      // and overrides the getMp3DurationWithAudioPlayer() method so that
      // the AudioPlayer plugin not usable in unit test is not instantiated.
      AudioDownloadVM audioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // Initializing the audioDownloadVM
      audioDownloadVM.loadExistingPlaylists();

      // Load Playlist from the json file
      const String targetPlayListName = "Empty";
      Playlist targetPlaylistEmpty = loadPlaylist(targetPlayListName);

      expect(targetPlaylistEmpty.downloadedAudioLst.length, 0);
      expect(targetPlaylistEmpty.playableAudioLst.length, 0);

      String fileToImportDir =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}Files to import';
      const String importedFileNameOne =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher).mp3";
      List<String> importedFileNamesLst = [
        importedFileNameOne,
      ];
      List<String> filePathNamesToImportLst = [
        "$fileToImportDir${path.separator}$importedFileNameOne",
      ];

      // Import one file in the Empty playlist
      await audioDownloadVM.importAudioFilesInPlaylist(
        targetPlaylist: targetPlaylistEmpty,
        filePathNameToImportLst: filePathNamesToImportLst,
      );

      // Verify that the imported file physically exists in the target
      // playlist directory and in the downloaded and playable audio lists
      verifyImportedFilesPresence(
        targetPlaylist: targetPlaylistEmpty,
        importedFileNamesLst: importedFileNamesLst,
        targetPlaylistDownloadedAudioListInitialLengh: 0,
        targetPlaylistPlayableAudioListFinalLengh: 1,
      );

      final DateTime dateTimeNow = DateTime.now();

      Audio expectedImportedAudio = Audio.fullConstructor(
        enclosingPlaylist: targetPlaylistEmpty,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle:
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        compactVideoDescription: '',
        validVideoTitle:
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        videoUrl: '',
        audioDownloadDateTime: dateTimeNow,
        audioDownloadDuration: const Duration(microseconds: 0),
        audioDownloadSpeed: 0,
        videoUploadDate: dateTimeNow,
        audioDuration: const Duration(milliseconds: 469000),
        isAudioMusicQuality: false,
        audioPlaySpeed: 1.0,
        audioPlayVolume: 0.5,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName:
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher).mp3",
        audioFileSize: 7509275,
        isAudioImported: true,
      );

      Audio importedAudio = targetPlaylistEmpty.playableAudioLst[0];

      expect(importedAudio.enclosingPlaylist,
          expectedImportedAudio.enclosingPlaylist);
      expect(importedAudio.movedFromPlaylistTitle,
          expectedImportedAudio.movedFromPlaylistTitle);
      expect(importedAudio.movedToPlaylistTitle,
          expectedImportedAudio.movedToPlaylistTitle);
      expect(importedAudio.copiedFromPlaylistTitle,
          expectedImportedAudio.copiedFromPlaylistTitle);
      expect(importedAudio.copiedToPlaylistTitle,
          expectedImportedAudio.copiedToPlaylistTitle);
      expect(importedAudio.originalVideoTitle,
          expectedImportedAudio.originalVideoTitle);
      expect(importedAudio.compactVideoDescription,
          expectedImportedAudio.compactVideoDescription);
      expect(
          importedAudio.validVideoTitle, expectedImportedAudio.validVideoTitle);
      expect(importedAudio.videoUrl, expectedImportedAudio.videoUrl);
      expect(
        DateTimeUtil.areDateTimesEqualWithinTolerance(
          dateTimeOne: importedAudio.audioDownloadDateTime,
          dateTimeTwo: expectedImportedAudio.audioDownloadDateTime,
          toleranceInSeconds: 1,
        ),
        true,
      );
      expect(importedAudio.audioDownloadDuration,
          expectedImportedAudio.audioDownloadDuration);
      expect(importedAudio.audioDownloadSpeed,
          expectedImportedAudio.audioDownloadSpeed);
      expect(
        DateTimeUtil.areDateTimesEqualWithinTolerance(
          dateTimeOne: importedAudio.videoUploadDate,
          dateTimeTwo: expectedImportedAudio.videoUploadDate,
          toleranceInSeconds: 1,
        ),
        true,
      );
      expect(importedAudio.audioDuration, expectedImportedAudio.audioDuration);
      expect(importedAudio.isAudioMusicQuality,
          expectedImportedAudio.isAudioMusicQuality);
      expect(
          importedAudio.audioPlaySpeed, expectedImportedAudio.audioPlaySpeed);
      expect(
          importedAudio.audioPlayVolume, expectedImportedAudio.audioPlayVolume);
      expect(
          importedAudio.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
          expectedImportedAudio
              .isPlayingOrPausedWithPositionBetweenAudioStartAndEnd);
      expect(importedAudio.isPaused, expectedImportedAudio.isPaused);
      expect(importedAudio.audioPausedDateTime,
          expectedImportedAudio.audioPausedDateTime);
      expect(importedAudio.audioPositionSeconds,
          expectedImportedAudio.audioPositionSeconds);
      expect(importedAudio.audioFileName, expectedImportedAudio.audioFileName);
      expect(importedAudio.audioFileSize, expectedImportedAudio.audioFileSize);
      expect(
          importedAudio.isAudioImported, expectedImportedAudio.isAudioImported);

      // Now import again the same file which now exists in the Empty
      // playlist
      await audioDownloadVM.importAudioFilesInPlaylist(
        targetPlaylist: targetPlaylistEmpty,
        filePathNameToImportLst: filePathNamesToImportLst,
      );

      // Verify that the re-imported file has not been imported a second
      // time
      verifyImportedFilesPresence(
        targetPlaylist: targetPlaylistEmpty,
        importedFileNamesLst: [],
        targetPlaylistDownloadedAudioListInitialLengh:
            1, // final length in fact
        targetPlaylistPlayableAudioListFinalLengh: 1,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('''Import four not existing files and then reimport them so that they
           will not be imported a second time.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}import_audio_file_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Using MockAudioDownloadVM which inherits from AudioDownloadVM
      // and overrides the getMp3DurationWithAudioPlayer() method so that
      // the AudioPlayer plugin not usable in unit test is not instantiated.
      AudioDownloadVM audioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // Initializing the audioDownloadVM
      audioDownloadVM.loadExistingPlaylists();

      // Load Playlist from the json file
      const String targerPlayListName = "Empty";
      Playlist targetPlaylistEmpty = loadPlaylist(targerPlayListName);

      expect(targetPlaylistEmpty.downloadedAudioLst.length, 0);
      expect(targetPlaylistEmpty.playableAudioLst.length, 0);

      String fileToImportDir =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}Files to import';
      const String importedFileNameOne =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher).mp3";
      const String importedFileNameTwo = "audio learn test short video one.mp3";
      const String importedFileNameThree =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet.mp3";
      const String importedFileNameFour = "Really short video.mp3";
      List<String> importedFileNamesLst = [
        importedFileNameOne,
        importedFileNameTwo,
        importedFileNameThree,
        importedFileNameFour,
      ];
      List<String> filePathNamesToImportLst = [
        "$fileToImportDir${path.separator}$importedFileNameOne",
        "$fileToImportDir${path.separator}$importedFileNameTwo",
        "$fileToImportDir${path.separator}$importedFileNameThree",
        "$fileToImportDir${path.separator}$importedFileNameFour",
      ];

      // Import four files in the Empty playlist
      await audioDownloadVM.importAudioFilesInPlaylist(
        targetPlaylist: targetPlaylistEmpty,
        filePathNameToImportLst: filePathNamesToImportLst,
      );

      // Verify that the imported files physically exists in the target
      // playlist directory and in the downloaded and playable audio lists
      verifyImportedFilesPresence(
        targetPlaylist: targetPlaylistEmpty,
        importedFileNamesLst: importedFileNamesLst,
        targetPlaylistDownloadedAudioListInitialLengh: 0,
        targetPlaylistPlayableAudioListFinalLengh: 4,
      );

      // Now import again the same file which now exists in the Empty
      // playlist
      await audioDownloadVM.importAudioFilesInPlaylist(
        targetPlaylist: targetPlaylistEmpty,
        filePathNameToImportLst: filePathNamesToImportLst,
      );

      // Verify that the re-imported file has not been imported a second
      // time
      verifyImportedFilesPresence(
        targetPlaylist: targetPlaylistEmpty,
        importedFileNamesLst: [],
        targetPlaylistDownloadedAudioListInitialLengh:
            4, // final length in fact
        targetPlaylistPlayableAudioListFinalLengh: 4,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''Import four files of which two already exist in target playlist dir.''',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}import_audio_file_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );
      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // necessary, otherwise audioDownloadVM won't be able to load
      // the existing playlists and the test will fail
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}$kSettingsFileName");

      // Using MockAudioDownloadVM which inherits from AudioDownloadVM
      // and overrides the getMp3DurationWithAudioPlayer() method so that
      // the AudioPlayer plugin not usable in unit test is not instantiated.
      AudioDownloadVM audioDownloadVM = MockAudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: settingsDataService,
        isTest: true,
      );

      // Initializing the audioDownloadVM
      audioDownloadVM.loadExistingPlaylists();

      // Load Playlist from the json file
      const String targerPlayListName = "Empty";
      Playlist targetPlaylistEmpty = loadPlaylist(targerPlayListName);

      expect(targetPlaylistEmpty.downloadedAudioLst.length, 0);
      expect(targetPlaylistEmpty.playableAudioLst.length, 0);

      String fileToImportDir =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}Files to import';
      const String importedFileNameOne =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher).mp3";
      const String importedFileNameTwo = "audio learn test short video one.mp3";
      const String importedFileNameThree =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet.mp3";
      const String importedFileNameFour = "Really short video.mp3";
      List<String> importedFileNamesLst = [
        importedFileNameThree,
        importedFileNameFour,
      ];
      List<String> filePathNamesToImportLst = [
        "$fileToImportDir${path.separator}$importedFileNameOne",
        "$fileToImportDir${path.separator}$importedFileNameTwo",
        "$fileToImportDir${path.separator}$importedFileNameThree",
        "$fileToImportDir${path.separator}$importedFileNameFour",
      ];

      // Physically add two files to the target playlist directory
      final String targetPlaylistDownloadPath =
          targetPlaylistEmpty.downloadPath;
      final String fileOnePathName =
          "$targetPlaylistDownloadPath${path.separator}$importedFileNameOne";
      final String fileTwoPathName =
          "$targetPlaylistDownloadPath${path.separator}$importedFileNameTwo";
      File("$fileToImportDir${path.separator}$importedFileNameOne")
          .absolute
          .copySync(fileOnePathName);
      File("$fileToImportDir${path.separator}$importedFileNameTwo")
          .absolute
          .copySync(fileTwoPathName);

      // Import four files in the Empty playlist which already contains
      // two of them
      await audioDownloadVM.importAudioFilesInPlaylist(
        targetPlaylist: targetPlaylistEmpty,
        filePathNameToImportLst: filePathNamesToImportLst,
      );

      // Verify that the imported files physically exists in the target
      // playlist directory and in the downloaded and playable audio lists
      verifyImportedFilesPresence(
        targetPlaylist: targetPlaylistEmpty,
        importedFileNamesLst: importedFileNamesLst,
        targetPlaylistDownloadedAudioListInitialLengh: 0,
        targetPlaylistPlayableAudioListFinalLengh: 2,
      );

      // Now import again the same file which now exists in the Empty
      // playlist
      await audioDownloadVM.importAudioFilesInPlaylist(
        targetPlaylist: targetPlaylistEmpty,
        filePathNameToImportLst: filePathNamesToImportLst,
      );

      // Verify that the re-imported file has not been imported a second
      // time
      verifyImportedFilesPresence(
        targetPlaylist: targetPlaylistEmpty,
        importedFileNamesLst: [],
        targetPlaylistDownloadedAudioListInitialLengh:
            2, // final length in fact
        targetPlaylistPlayableAudioListFinalLengh: 2,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}

void verifyImportedFilesPresence({
  required Playlist targetPlaylist,
  required List<String> importedFileNamesLst,
  required int targetPlaylistDownloadedAudioListInitialLengh,
  required int targetPlaylistPlayableAudioListFinalLengh,
}) {
  final String targetPlaylistDownloadPath = targetPlaylist.downloadPath;

  for (String importedFileName in importedFileNamesLst) {
    final String importedFilePathName =
        "$targetPlaylistDownloadPath${path.separator}$importedFileName";

    // Reloadoad Playlist from the file
    targetPlaylist = loadPlaylist(targetPlaylist.title);

    // Verify that the imported file physically exists in the target
    // playlist directory
    expect(File(importedFilePathName).existsSync(), true);

    // Verify that the imported file is in the downloaded audio list
    expect(
      targetPlaylist
          .downloadedAudioLst[
              ++targetPlaylistDownloadedAudioListInitialLengh - 1]
          .audioFileName,
      importedFileName,
    );

    // Verify that the imported file is in the playable audio list
    expect(
      targetPlaylist
          .playableAudioLst[--targetPlaylistPlayableAudioListFinalLengh]
          .audioFileName,
      importedFileName,
    );
  }

  expect(
    targetPlaylist.downloadedAudioLst.length,
    targetPlaylistDownloadedAudioListInitialLengh,
  );
  expect(
    targetPlaylist.playableAudioLst.length,
    targetPlaylistPlayableAudioListFinalLengh + importedFileNamesLst.length,
  );
}

Playlist loadPlaylist(String playListOneName) {
  return JsonDataService.loadFromFile(
      jsonPathFileName:
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playListOneName${path.separator}$playListOneName.json",
      type: Playlist);
}
