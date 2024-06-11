import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';

import '../services/mock_shared_preferences.dart';

void main() {
  group('AudioDownloadVM video description', () {
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
    });
  });
  group('AudioDownloadVM update playlist json file', () {
    test('Check that playlist download path is correctly updated', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('AudioDownloadVM rename audio file', () {
    test('File with new name not exist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('File with new name exist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
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
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('AudioDownloadVM modify audio title', () {
    test('Modify audio title', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
        deleteSubDirectoriesAsWell: true,
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
      expect(
          loadedPlaylist.downloadedAudioLst[0].validVideoTitle, initialAudioTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
}

Playlist loadPlaylist(String playListOneName) {
  return JsonDataService.loadFromFile(
      jsonPathFileName:
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playListOneName${path.separator}$playListOneName.json",
      type: Playlist);
}
