import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';

import '../services/mock_shared_preferences.dart';

void main() {
  group('DateFormatVM test', () {
    test('''Check application of initial format, then change format and test the
        new format application.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}date_format_vm_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${Platform.pathSeparator}$kSettingsFileName");

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      DateTime dateTime = DateTime(2021, 11, 30, 23, 59, 59);

      expect(
        dateFormatVM.formatDate(dateTime),
        "30/11/2021",
      );

      dateFormatVM.updateFormat("MM/dd/yyyy");

      expect(
        dateFormatVM.formatDate(dateTime),
        "11/30/2021",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
    test('''Check application of initial format, then change format and create a
        new DateFormatVM with a reload SettingsDataService and test new format
        application.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}date_format_vm_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      WarningMessageVM warningMessageVM = WarningMessageVM();
      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${Platform.pathSeparator}$kSettingsFileName");

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      DateTime dateTime = DateTime(2021, 11, 30, 23, 59, 59);

      expect(
        dateFormatVM.formatDate(dateTime),
        "30/11/2021",
      );

      dateFormatVM.updateFormat("MM/dd/yyyy");

      SettingsDataService reloadedSettingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

      await reloadedSettingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindowsTest${Platform.pathSeparator}$kSettingsFileName");

      DateFormatVM reloadedDateFormatVM = DateFormatVM(
        settingsDataService: reloadedSettingsDataService,
      );

      expect(
        reloadedDateFormatVM.formatDate(dateTime),
        "11/30/2021",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );
    });
  });
}
