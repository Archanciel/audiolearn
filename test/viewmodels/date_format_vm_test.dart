import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/viewmodels/date_format_vm.dart';

import '../services/mock_shared_preferences.dart';

void main() {
  group('DateFormatVM test', () {
    test('''Check application of initial format, then change format and test the
        new format application.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}date_format_vm_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindows${Platform.pathSeparator}$kSettingsFileName");

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      DateTime dateTime = DateTime(2021, 11, 30, 23, 59, 59);

      expect(
        dateFormatVM.formatDate(dateTime),
        "30/11/2021",
      );

      expect(
        dateFormatVM.formatDateYy(dateTime),
        "30/11/21",
      );

      expect(
        dateFormatVM.formatDateTime(dateTime),
        "30/11/2021 23:59", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.selectedDateFormat,
        'dd/MM/yyyy',
      );

      expect(
        dateFormatVM.selectedDateFormatLowCase,
        'dd/mm/yyyy',
      );

      dateFormatVM.selectDateFormat(dateFormatIndex: 1);

      expect(
        dateFormatVM.formatDate(dateTime),
        "11/30/2021",
      );

      expect(
        dateFormatVM.formatDateYy(dateTime),
        "11/30/21",
      );

      expect(
        dateFormatVM.formatDateTime(dateTime),
        "11/30/2021 23:59", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.selectedDateFormat,
        'MM/dd/yyyy',
      );

      expect(
        dateFormatVM.selectedDateFormatLowCase,
        'mm/dd/yyyy',
      );

      dateFormatVM.selectDateFormat(dateFormatIndex: 2);

      expect(
        dateFormatVM.formatDate(dateTime),
        "2021/11/30",
      );

      expect(
        dateFormatVM.formatDateYy(dateTime),
        "21/11/30",
      );

      expect(
        dateFormatVM.formatDateTime(dateTime),
        "2021/11/30 23:59", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.selectedDateFormat,
        'yyyy/MM/dd',
      );

      expect(
        dateFormatVM.selectedDateFormatLowCase,
        'yyyy/mm/dd',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindows,
      );
    });
    test('''Check application of initial format, then change format and create a
        new DateFormatVM with a reload SettingsDataService and test new format
        application.''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}date_format_vm_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
      );

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      await settingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindows${Platform.pathSeparator}$kSettingsFileName");

      DateFormatVM dateFormatVM = DateFormatVM(
        settingsDataService: settingsDataService,
      );

      DateTime dateTime = DateTime(2021, 11, 30, 23, 59, 59);

      expect(
        dateFormatVM.formatDate(dateTime),
        "30/11/2021", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.formatDateYy(dateTime),
        "30/11/21",
      );

      expect(
        dateFormatVM.formatDateTime(dateTime),
        "30/11/2021 23:59", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.selectedDateFormat,
        'dd/MM/yyyy',
      );

      expect(
        dateFormatVM.selectedDateFormatLowCase,
        'dd/mm/yyyy',
      );

      // Change the date format to the second format which is 'MM/dd/yyyy'
      // and reload the settings data service

      dateFormatVM.selectDateFormat(dateFormatIndex: 1);

      expect(
        dateFormatVM.formatDate(dateTime),
        "11/30/2021",
      );

      expect(
        dateFormatVM.formatDateYy(dateTime),
        "11/30/21",
      );

      expect(
        dateFormatVM.formatDateTime(dateTime),
        "11/30/2021 23:59", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.selectedDateFormat,
        'MM/dd/yyyy',
      );

      expect(
        dateFormatVM.selectedDateFormatLowCase,
        'mm/dd/yyyy',
      );

      SettingsDataService reloadedSettingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      await reloadedSettingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindows${Platform.pathSeparator}$kSettingsFileName");

      DateFormatVM reloadedDateFormatVM = DateFormatVM(
        settingsDataService: reloadedSettingsDataService,
      );

      expect(
        reloadedDateFormatVM.formatDate(dateTime),
        "11/30/2021",
      );

      expect(
        dateFormatVM.formatDateYy(dateTime),
        "11/30/21",
      );

      expect(
        dateFormatVM.formatDateTime(dateTime),
        "11/30/2021 23:59", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.selectedDateFormat,
        'MM/dd/yyyy',
      );

      expect(
        dateFormatVM.selectedDateFormatLowCase,
        'mm/dd/yyyy',
      );

      // Change the date format to the third format which is 'yyyy/MM/dd'
      // and reload the settings data service

      dateFormatVM.selectDateFormat(dateFormatIndex: 2);

      expect(
        dateFormatVM.formatDate(dateTime),
        "2021/11/30",
      );

      expect(
        dateFormatVM.formatDateYy(dateTime),
        "21/11/30",
      );

      expect(
        dateFormatVM.formatDateTime(dateTime),
        "2021/11/30 23:59", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.selectedDateFormat,
        'yyyy/MM/dd',
      );

      expect(
        dateFormatVM.selectedDateFormatLowCase,
        'yyyy/mm/dd',
      );

      SettingsDataService secondReloadedSettingsDataService =
          SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
      );

      await secondReloadedSettingsDataService.loadSettingsFromFile(
          settingsJsonPathFileName:
              "$kPlaylistDownloadRootPathWindows${Platform.pathSeparator}$kSettingsFileName");

      DateFormatVM secondReloadedDateFormatVM = DateFormatVM(
        settingsDataService: secondReloadedSettingsDataService,
      );

      expect(
        secondReloadedDateFormatVM.formatDate(dateTime),
        "2021/11/30",
      );

      expect(
        dateFormatVM.formatDateYy(dateTime),
        "21/11/30",
      );

      expect(
        dateFormatVM.formatDateTime(dateTime),
        "2021/11/30 23:59", // Initial format is 'dd/MM/yyyy'
      );

      expect(
        dateFormatVM.selectedDateFormat,
        'yyyy/MM/dd',
      );

      expect(
        dateFormatVM.selectedDateFormatLowCase,
        'yyyy/mm/dd',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kPlaylistDownloadRootPathWindows,
      );
    });
  });
}
