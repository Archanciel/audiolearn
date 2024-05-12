import 'dart:io';
import 'dart:math';

import 'package:audiolearn/services/json_data_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String testSettingsDir =
      '$kPlaylistDownloadRootPathWindowsTest\\audiolearn_test_settings';

  group('CommentVM test', () {
    test('loadOrCreateCommentFile comment file not exist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteDirAndSubDirsIfExist(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      CommentVM commentVM = CommentVM();

      List<Comment> commentLst = await commentVM.loadOrCreateCommentFile(
        playListDir:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}local",
        audioFileName: '240110-181805-Really short video 23-07-01.mp3',
      );

      expect(commentLst.length, 0);
      expect(
          File("$kPlaylistDownloadRootPathWindowsTest${path.separator}local${path.separator}$kCommentDirName${path.separator}240110-181805-Really short video 23-07-01.json")
              .existsSync(),
          true);
      expect(
          () => JsonDataService.loadFromFile(
              jsonPathFileName:
                  "$kPlaylistDownloadRootPathWindowsTest${path.separator}local${path.separator}$kCommentDirName${path.separator}240110-181805-Really short video 23-07-01.json",
              type: Comment),
          throwsA(predicate((e) =>
              e is ClassNotContainedInJsonFileException &&
              e.toString().contains('Class Comment not stored in'))));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
}
