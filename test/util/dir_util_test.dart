import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('DirUtil test)', () {
    test(
      'replacing "/storage/emulated/0/Download/audiolear" by "C:\\development\\flutter\\audiolearn\\test\\data\\audio"',
      () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}dir_util_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        DirUtil.replacePlaylistRootPathInSettingsJsonFiles(
            directoryPath:
                "C:\\development\\flutter\\audiolearn\\test\\data\\audio",
            oldRootPath: '/storage/emulated/0/Download/audiolear',
            newRootPath:
                "C:\\development\\flutter\\audiolearn\\test\\data\\audio");

        File expectedFile = File(
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}test_result.json");
        File actualFile = File(
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}settings.json");
        String actual = actualFile.readAsStringSync();
        expect(actual, expectedFile.readAsStringSync());

        // Cleanup the test data directory
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      },
    );
    test(
      'deleteFilesAndSubDirsOfDir',
      () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}dir_util_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        Directory dir = Directory(kPlaylistDownloadRootPathWindowsTest);

        expect(dir.existsSync(), true);
        expect(dir.listSync().isEmpty, true);
      },
    );
    test(
      'listPathFileNamesInSubDirs',
      () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}dir_util_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        List<String> listJsonPathFileNames = DirUtil.listPathFileNamesInSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          fileExtension: 'json',
        );

        expect(listJsonPathFileNames.length, 4);

        listJsonPathFileNames = DirUtil.listPathFileNamesInSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          fileExtension: 'json',
          excludeDirNamesLst: ['comments'],
        );

        expect(listJsonPathFileNames.length, 2);

        // Cleanup the test data directory
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      },
    );
    test(
      'listPathFileNamesInDir',
      () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}dir_util_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        List<String> listJsonPathFileNames = DirUtil.listPathFileNamesInDir(
          directoryPath:
              "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName",
          fileExtension: 'json',
        );

        expect(listJsonPathFileNames.length, 1);

        // Cleanup the test data directory
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      },
    );
    test(
      'saveStringToFile and readStringFromFile',
      () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        // Copy the test initial audio data to the app dir
        String sourceRootPath =
            "$kDownloadAppTestSavedDataDir${path.separator}dir_util_test";

        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath: sourceRootPath,
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        String testString = 'test string';
        String testPathFileName =
            '$sourceRootPath${path.separator}test_file.txt';

        DirUtil.saveStringToFile(
          pathFileName: testPathFileName,
          content: testString,
        );

        String readString = DirUtil.readStringFromFile(
          pathFileName: testPathFileName,
        );

        expect(readString, testString);

        // Cleanup the test data directory
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
        );
      },
    );
  });
}
