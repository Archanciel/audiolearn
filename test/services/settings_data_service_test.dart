import 'dart:io';
import 'package:audiolearn/services/sort_filter_parameters.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';

import 'mock_shared_preferences.dart';

enum UnsupportedSettingsEnum { unsupported }

void main() {
  const String testSettingsDir =
      '$kApplicationPathWindowsTest\\audiolearn_test_settings';

  group('Settings', () {
    test('Test initial, modified, saved and loaded values', () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: 'not_exist/settings.json');

      settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
        audioSortFilterParametersName: 'Default',
        audioSortFilterParameters:
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );
      AudioSortFilterParameters historicalAudioSortFilterParameters =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      historicalAudioSortFilterParameters.filterSentenceLst.add("Jancovici");
      historicalAudioSortFilterParameters.selectedSortItemLst.add(SortingItem(
        sortingOption: SortingOption.audioDuration,
        isAscending: true,
      ));

      settingsDataService.addAudioSortFilterParametersToSearchHistory(
        audioSortFilterParameters: historicalAudioSortFilterParameters,
      );

      // Initial values
      expect(
          settingsDataService.get(
              settingType: SettingType.appTheme,
              settingSubType: SettingType.appTheme),
          AppTheme.dark);
      expect(
          settingsDataService.get(
              settingType: SettingType.language,
              settingSubType: SettingType.language),
          Language.english);
      expect(
          settingsDataService.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.isMusicQualityByDefault),
          false);
      expect(
          settingsDataService.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.playSpeed),
          kAudioDefaultPlaySpeed);
      expect(
          settingsDataService.get(
              settingType: SettingType.playlists,
              settingSubType:
                  Playlists.arePlaylistsDisplayedInPlaylistDownloadView),
          false);
      expect(
          settingsDataService.get(
              settingType: SettingType.dataLocation,
              settingSubType: DataLocation.appSettingsPath),
          "C:\\development\\flutter\\audiolearn\\test\\data\\audio");
      expect(
          settingsDataService.get(
              settingType: SettingType.dataLocation,
              settingSubType: DataLocation.playlistRootPath),
          "C:\\development\\flutter\\audiolearn\\test\\data\\audio\\playlists");
      expect(
          settingsDataService.get(
              settingType: SettingType.formatOfDate,
              settingSubType: FormatOfDate.formatOfDate),
          "dd/MM/yyyy");

      AudioSortFilterParameters defaultAudioSortFilterParameters =
          settingsDataService.namedAudioSortFilterParametersMap['Default']!;

      expect(
          defaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      AudioSortFilterParameters firstHistoricalAudioSortFilterParameters =
          settingsDataService.searchHistoryAudioSortFilterParametersLst[0];

      expect(
          firstHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Jancovici") &&
              firstHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDuration,
                isAscending: true,
              )),
          true);

      // Modify values
      settingsDataService.set(
          settingType: SettingType.appTheme,
          settingSubType: SettingType.appTheme,
          value: AppTheme.light);
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.isMusicQualityByDefault,
          value: true);
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.playSpeed,
          value: 1.1);
      settingsDataService.set(
          settingType: SettingType.playlists,
          settingSubType: Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
          value: true);
      settingsDataService.set(
          settingType: SettingType.dataLocation,
          settingSubType: DataLocation.appSettingsPath,
          value: "C:\\development\\flutter\\audiolearn\\test\\data\\new_audio");
      settingsDataService.set(
          settingType: SettingType.dataLocation,
          settingSubType: DataLocation.playlistRootPath,
          value:
              "C:\\development\\flutter\\audiolearn\\test\\data\\new_audio\\playlists");
      settingsDataService.set(
          settingType: SettingType.formatOfDate,
          settingSubType: FormatOfDate.formatOfDate,
          value: "MM/dd/yyyy");

      // Save settings to file

      await DirUtil.createDirIfNotExist(pathStr: testSettingsDir);

      final String testSettingsPathFileName =
          path.join(testSettingsDir, 'settings.json');
      settingsDataService.saveSettingsToFile(
        jsonPathFileName: testSettingsPathFileName,
      );

      // Load from file
      final SettingsDataService loadedSettings = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );
      await loadedSettings.loadSettingsFromFile(
        settingsJsonPathFileName: testSettingsPathFileName,
      );

      // Check loaded values
      expect(
          loadedSettings.get(
              settingType: SettingType.appTheme,
              settingSubType: SettingType.appTheme),
          AppTheme.light);
      expect(
          loadedSettings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.isMusicQualityByDefault),
          true);
      expect(
          loadedSettings.get(
              settingType: SettingType.playlists,
              settingSubType: Playlists.playSpeed),
          1.1);
      expect(
          loadedSettings.get(
              settingType: SettingType.playlists,
              settingSubType:
                  Playlists.arePlaylistsDisplayedInPlaylistDownloadView),
          true);
      expect(
          loadedSettings.get(
              settingType: SettingType.dataLocation,
              settingSubType: DataLocation.appSettingsPath),
          "C:\\development\\flutter\\audiolearn\\test\\data\\new_audio");
      expect(
          loadedSettings.get(
              settingType: SettingType.dataLocation,
              settingSubType: DataLocation.playlistRootPath),
          "C:\\development\\flutter\\audiolearn\\test\\data\\new_audio\\playlists");
      expect(
          loadedSettings.get(
              settingType: SettingType.formatOfDate,
              settingSubType: FormatOfDate.formatOfDate),
          "MM/dd/yyyy");

      AudioSortFilterParameters loadedDefaultAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Default']!;
      expect(
          loadedDefaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      AudioSortFilterParameters loadedFirstHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[0];

      expect(loadedFirstHistoricalAudioSortFilterParameters,
          firstHistoricalAudioSortFilterParameters);

      expect(
          loadedFirstHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Jancovici") &&
              loadedFirstHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDuration,
                isAscending: true,
              )),
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    test('''With 2 AudioSortFilterParameters, test initial, modified, saved and
            loaded values''', () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: 'test/settings.json');

      settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
        audioSortFilterParametersName: 'Default',
        audioSortFilterParameters:
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );
      AudioSortFilterParameters audioSortFilterParametersJancovici =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      audioSortFilterParametersJancovici.filterSentenceLst.add("Jancovici");
      settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
        audioSortFilterParametersName: 'Jancovici',
        audioSortFilterParameters: audioSortFilterParametersJancovici,
      );
      AudioSortFilterParameters historicalAudioSortFilterParameters =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      historicalAudioSortFilterParameters.filterSentenceLst.add("Euthanasie");
      historicalAudioSortFilterParameters.selectedSortItemLst.add(SortingItem(
        sortingOption: SortingOption.audioDuration,
        isAscending: true,
      ));

      settingsDataService.addAudioSortFilterParametersToSearchHistory(
        audioSortFilterParameters: historicalAudioSortFilterParameters,
      );
      settingsDataService.addAudioSortFilterParametersToSearchHistory(
        audioSortFilterParameters: audioSortFilterParametersJancovici,
      );

      // Save settings to file

      await DirUtil.createDirIfNotExist(pathStr: testSettingsDir);

      final String testSettingsPathFileName =
          path.join(testSettingsDir, 'settings.json');
      settingsDataService.saveSettingsToFile(
        jsonPathFileName: testSettingsPathFileName,
      );

      // Load from file
      final SettingsDataService loadedSettings = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );
      await loadedSettings.loadSettingsFromFile(
        settingsJsonPathFileName: testSettingsPathFileName,
      );

      // Check loaded values

      AudioSortFilterParameters loadedDefaultAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Default']!;
      expect(
          loadedDefaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      AudioSortFilterParameters loadedJancoAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Jancovici']!;
      expect(loadedJancoAudioSortFilterParameters,
          audioSortFilterParametersJancovici);

      AudioSortFilterParameters loadedFirstHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[0];

      expect(
          loadedFirstHistoricalAudioSortFilterParameters ==
              historicalAudioSortFilterParameters,
          true);

      expect(
          loadedFirstHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Euthanasie") &&
              loadedFirstHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDuration,
                isAscending: true,
              )),
          true);

      AudioSortFilterParameters
          loadedSecondHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[1];

      expect(loadedSecondHistoricalAudioSortFilterParameters,
          audioSortFilterParametersJancovici);

      expect(
          loadedSecondHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Jancovici") &&
              loadedSecondHistoricalAudioSortFilterParameters
                  .selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDownloadDate,
                isAscending: false,
              )),
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    test('''With 3 AudioSortFilterParameters, test initial, modified, saved and
            loaded values''', () async {
      final Directory directory = Directory(testSettingsDir);

      // if (directory.existsSync()) {
      //   directory.deleteSync(recursive: true);
      // }

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: 'test/settings.json');

      settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
        audioSortFilterParametersName: 'Default',
        audioSortFilterParameters:
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );
      AudioSortFilterParameters audioSortFilterParametersJancovici =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      audioSortFilterParametersJancovici.filterSentenceLst.add("Jancovici");
      settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
        audioSortFilterParametersName: 'Jancovici',
        audioSortFilterParameters: audioSortFilterParametersJancovici,
      );
      AudioSortFilterParameters audioSortFilterParametersBarrau =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      audioSortFilterParametersBarrau.filterSentenceLst.add("Barrau");
      settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
        audioSortFilterParametersName: 'Barrau',
        audioSortFilterParameters: audioSortFilterParametersBarrau,
      );
      AudioSortFilterParameters historicalAudioSortFilterParameters =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
      historicalAudioSortFilterParameters.filterSentenceLst.add("Euthanasie");
      historicalAudioSortFilterParameters.selectedSortItemLst.add(SortingItem(
        sortingOption: SortingOption.audioDuration,
        isAscending: true,
      ));

      settingsDataService.addAudioSortFilterParametersToSearchHistory(
        audioSortFilterParameters: historicalAudioSortFilterParameters,
      );
      settingsDataService.addAudioSortFilterParametersToSearchHistory(
        audioSortFilterParameters: audioSortFilterParametersJancovici,
      );
      settingsDataService.addAudioSortFilterParametersToSearchHistory(
        audioSortFilterParameters: audioSortFilterParametersBarrau,
      );

      // Save settings to file

      await DirUtil.createDirIfNotExist(pathStr: testSettingsDir);

      final String testSettingsPathFileName =
          path.join(testSettingsDir, 'settings.json');
      settingsDataService.saveSettingsToFile(
        jsonPathFileName: testSettingsPathFileName,
      );

      // Load from file
      final SettingsDataService loadedSettings = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );
      await loadedSettings.loadSettingsFromFile(
        settingsJsonPathFileName: testSettingsPathFileName,
      );

      // Check loaded values

      AudioSortFilterParameters loadedDefaultAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Default']!;
      expect(
          loadedDefaultAudioSortFilterParameters ==
              AudioSortFilterParameters
                  .createDefaultAudioSortFilterParameters(),
          true);

      AudioSortFilterParameters loadedJancoAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Jancovici']!;
      expect(loadedJancoAudioSortFilterParameters,
          audioSortFilterParametersJancovici);

      loadedJancoAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Barrau']!;
      expect(loadedJancoAudioSortFilterParameters,
          audioSortFilterParametersBarrau);

      AudioSortFilterParameters loadedFirstHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[0];

      expect(
          loadedFirstHistoricalAudioSortFilterParameters ==
              historicalAudioSortFilterParameters,
          true);

      expect(
          loadedFirstHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Euthanasie") &&
              loadedFirstHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDuration,
                isAscending: true,
              )),
          true);

      AudioSortFilterParameters
          loadedSecondHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[1];

      expect(loadedSecondHistoricalAudioSortFilterParameters,
          audioSortFilterParametersJancovici);

      expect(
          loadedSecondHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Jancovici") &&
              loadedSecondHistoricalAudioSortFilterParameters
                  .selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDownloadDate,
                isAscending: false,
              )),
          true);

      AudioSortFilterParameters loadedThirdHistoricalAudioSortFilterParameters =
          loadedSettings.searchHistoryAudioSortFilterParametersLst[2];

      expect(loadedThirdHistoricalAudioSortFilterParameters,
          audioSortFilterParametersBarrau);

      expect(
          loadedThirdHistoricalAudioSortFilterParameters.filterSentenceLst
                  .contains("Barrau") &&
              loadedThirdHistoricalAudioSortFilterParameters.selectedSortItemLst
                  .contains(SortingItem(
                sortingOption: SortingOption.audioDownloadDate,
                isAscending: false,
              )),
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    test('''With empty AudioSortFilterParameters, test initial, modified, saved
            and loaded values''', () async {
      final Directory directory = Directory(testSettingsDir);

      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // Save settings to file

      await DirUtil.createDirIfNotExist(pathStr: testSettingsDir);

      final String testSettingsPathFileName =
          path.join(testSettingsDir, 'settings.json');
      settingsDataService.saveSettingsToFile(
        jsonPathFileName: testSettingsPathFileName,
      );

      // Load from file
      final SettingsDataService loadedSettings = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      await loadedSettings.loadSettingsFromFile(
        settingsJsonPathFileName: testSettingsPathFileName,
      );

      // Check loaded values

      AudioSortFilterParameters? loadedDefaultAudioSortFilterParameters =
          loadedSettings.namedAudioSortFilterParametersMap['Default'];

      expect(loadedDefaultAudioSortFilterParameters, null);

      expect(loadedSettings.searchHistoryAudioSortFilterParametersLst.isEmpty,
          true);

      // Cleanup the test data directory
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });
    test(
        '''savePlaylistTitleOrder + restorePlaylistTitleOrderIfExistAndSaveSettings
           test''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      final String initialPlaylistRootPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}playlistInitialPath';
      final String modifiedPlaylistRootPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}playlistModifiedPath';

      await DirUtil.createDirIfNotExist(pathStr: testSettingsDir);
      await DirUtil.createDirIfNotExist(pathStr: initialPlaylistRootPath);
      await DirUtil.createDirIfNotExist(pathStr: modifiedPlaylistRootPath);

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: 'not_exist/settings.json');

      final String testSettingsPathFileName =
          path.join(kApplicationPathWindowsTest, 'settings.json');

      // Setting the playlist root path to the initial playlist root path
      settingsDataService.set(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath,
        value: initialPlaylistRootPath,
      );

      List<String> initialPlaylistOrder = [
        'playlist1',
        'playlist2',
        'playlist3',
      ];

      settingsDataService.updatePlaylistOrderAndSaveSettings(
        playlistOrder: initialPlaylistOrder,
      );

      // Now change the playlist root path, but first save the playlist
      // order so that it can be restored after changing the playlist
      // root path
      settingsDataService.savePlaylistTitleOrder(
        directory: initialPlaylistRootPath,
      );

      // Change the playlist root path
      settingsDataService.set(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath,
        value: modifiedPlaylistRootPath,
      );

      List<String> modifiedPlaylistOrder = [
        'playlist3',
        'playlist2',
        'playlist1',
      ];

      // Updating the playlist order list and saving the settings.
      settingsDataService.updatePlaylistOrderAndSaveSettings(
        playlistOrder: modifiedPlaylistOrder,
      );

      // Check that the playlist order list has been updated
      expect(
        settingsDataService.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ),
        modifiedPlaylistOrder,
      );

      // Load from file
      SettingsDataService loadedSettings = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      await loadedSettings.loadSettingsFromFile(
        settingsJsonPathFileName: testSettingsPathFileName,
      );

      // Check that the updated playlist order list has been saved
      expect(
        loadedSettings.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ),
        modifiedPlaylistOrder,
      );

      settingsDataService.restorePlaylistTitleOrderIfExistAndSaveSettings(
        directoryContainingPreviouslySavedPlaylistTitleOrder:
            initialPlaylistRootPath,
      );

      // Check that the playlist order list has been restored
      expect(
        settingsDataService.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ),
        initialPlaylistOrder,
      );

      // Load from file
      loadedSettings = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      await loadedSettings.loadSettingsFromFile(
        settingsJsonPathFileName: testSettingsPathFileName,
      );

      // Check that the restored playlist order list has been saved
      expect(
        loadedSettings.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ),
        initialPlaylistOrder,
      );

      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test(
        '''savePlaylistTitleOrder + delete it + restorePlaylistTitleOrderIfExistAndSaveSettings
           test''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      final String initialPlaylistRootPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}playlistInitialPath';
      final String modifiedPlaylistRootPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}playlistModifiedPath';

      await DirUtil.createDirIfNotExist(pathStr: testSettingsDir);
      await DirUtil.createDirIfNotExist(pathStr: initialPlaylistRootPath);
      await DirUtil.createDirIfNotExist(pathStr: modifiedPlaylistRootPath);

      final SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      // load settings from file which does not exist. This
      // will ensure that the default playlist root path is set
      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName: 'not_exist/settings.json');

      final String testSettingsPathFileName =
          path.join(kApplicationPathWindowsTest, 'settings.json');

      // Setting the playlist root path to the initial playlist root path
      settingsDataService.set(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath,
        value: initialPlaylistRootPath,
      );

      List<String> initialPlaylistOrder = [
        'playlist1',
        'playlist2',
        'playlist3',
      ];

      settingsDataService.updatePlaylistOrderAndSaveSettings(
        playlistOrder: initialPlaylistOrder,
      );

      // Now change the playlist root path, but first save the playlist
      // order so that it can be restored after changing the playlist
      // root path
      settingsDataService.savePlaylistTitleOrder(
        directory: initialPlaylistRootPath,
      );

      // Change the playlist root path
      settingsDataService.set(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath,
        value: modifiedPlaylistRootPath,
      );

      List<String> modifiedPlaylistOrder = [
        'playlist3',
        'playlist2',
        'playlist1',
      ];

      // Updating the playlist order list and saving the settings.
      settingsDataService.updatePlaylistOrderAndSaveSettings(
        playlistOrder: modifiedPlaylistOrder,
      );

      // Check that the playlist order list has been updated
      expect(
        settingsDataService.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ),
        modifiedPlaylistOrder,
      );

      // Load from file
      SettingsDataService loadedSettings = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      await loadedSettings.loadSettingsFromFile(
        settingsJsonPathFileName: testSettingsPathFileName,
      );

      // Check that the updated playlist order list has been saved
      expect(
        loadedSettings.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ),
        modifiedPlaylistOrder,
      );

      // Deleting the playlist order file in the initial playlist
      // root path and verifying that it can not be restored

      DirUtil.deleteFileIfExist(
          pathFileName:
              '$initialPlaylistRootPath${path.separator}$kOrderedPlaylistTitlesFileName');

      settingsDataService.restorePlaylistTitleOrderIfExistAndSaveSettings(
        directoryContainingPreviouslySavedPlaylistTitleOrder:
            initialPlaylistRootPath,
      );

      // Check that the playlist order list has NOT been restored
      expect(
        settingsDataService.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ),
        modifiedPlaylistOrder,
      );

      // Load from file
      loadedSettings = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      await loadedSettings.loadSettingsFromFile(
        settingsJsonPathFileName: testSettingsPathFileName,
      );

      // Check that the restored playlist order list has NOT been saved
      expect(
        loadedSettings.get(
          settingType: SettingType.playlists,
          settingSubType: Playlists.orderedTitleLst,
        ),
        modifiedPlaylistOrder,
      );

      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}
