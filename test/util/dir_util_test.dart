import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DirUtil test)', () {
    test(
      'replacing "/storage/emulated/0/Download/audiolear" by "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\audio"',
      () {
        // Purge the test playlist directory if it exists so that the
        // playlist list is empty
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}dir_util_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        DirUtil.replacePlaylistRootPathInSettingsJsonFiles(
            directoryPath:
                "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\audio",
            oldRootPath: '/storage/emulated/0/Download/audiolear',
            newRootPath:
                "C:\\Users\\Jean-Pierre\\Development\\Flutter\\audiolearn\\test\\data\\audio");

        File expectedFile = File(
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}test_result.json");
        File actualFile = File(
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}settings.json");
        String actual = actualFile.readAsStringSync();
        expect(actual, expectedFile.readAsStringSync());

        // Cleanup the test data directory
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true,
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
          deleteSubDirectoriesAsWell: true,
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
          deleteSubDirectoriesAsWell: true,
        );

        // Copy the test initial audio data to the app dir
        DirUtil.copyFilesFromDirAndSubDirsToDirectory(
          sourceRootPath:
              "$kDownloadAppTestSavedDataDir${path.separator}dir_util_test",
          destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
        );

        List<String> listJsonPathFileNames = DirUtil.listPathFileNamesInSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          extension: 'json',
        );

        expect(listJsonPathFileNames.length, 4);

        listJsonPathFileNames = DirUtil.listPathFileNamesInSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          extension: 'json',
          excludeDirName: 'comments',
        );

        expect(listJsonPathFileNames.length, 2);

        // Cleanup the test data directory
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest,
          deleteSubDirectoriesAsWell: true,
        );
      },
    );
  });
}
