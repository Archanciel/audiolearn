import 'dart:io';
import 'dart:math';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/utils/date_time_util.dart';
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
    test(
        'load or create comment file comment file not exist, then exist, but is empty',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      CommentVM commentVM = CommentVM();

      // calling loadOrCreateCommentFile in situation where comment file
      // does not exist

      List<Comment> commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}local",
        audioFileName: '240110-181805-Really short video 23-07-01.mp3',
      );

      // the returned Commentlist should be empty
      expect(commentLst.length, 0);

      String createdCommentFilePathName =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}local${path.separator}$kCommentDirName${path.separator}240110-181805-Really short video 23-07-01.json";

      // the comment file should have been created
      expect(File(createdCommentFilePathName).existsSync(), true);

      // check that due to the fact that the comment file is empty,
      // the JsonDataService.loadFromFile method throws
      // ClassNotContainedInJsonFileException
      expect(
          () => JsonDataService.loadFromFile(
              jsonPathFileName: createdCommentFilePathName, type: Comment),
          throwsA(predicate((e) =>
              e is ClassNotContainedInJsonFileException &&
              e.toString().contains(createdCommentFilePathName))));

      // now calling again loadOrCreateCommentFile in situation where an
      // empty comment file exists

      commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}local",
        audioFileName: '240110-181805-Really short video 23-07-01.mp3',
      );

      // the returned Commentlist should be empty
      expect(commentLst.length, 0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'addComment on not exist comment file, then add new comment on same file',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      CommentVM commentVM = CommentVM();

      Playlist playlist = Playlist(
        id: "PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99",
        url:
            "https://youtube.com/playlist?list=PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99&si=9KC7VsVt5JIUvNYN",
        title: 'S8 audio',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.downloadPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio";

      Audio audio = Audio(
          enclosingPlaylist: playlist,
          originalVideoTitle:
              "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          compactVideoDescription: '',
          videoUrl: 'https://example.com/video1',
          audioDownloadDateTime: DateTime(2023, 3, 17, 12, 34, 6),
          videoUploadDate: DateTime(2023, 4, 12),
          audioPlaySpeed: 1.25);

      audio.audioFileName =
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3";

      Comment testCommentOne = Comment(
        title: 'Test Title',
        content: 'Test Content',
        audioPositionSeconds: 0,
      );

      await commentVM.addComment(
        comment: testCommentOne,
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir: playlist.downloadPath,
        audioFileName: audio.audioFileName,
      );

      // the returned Commentlist should have one element
      expect(commentLst.length, 1);

      // checking the content of the comment
      validateComment(commentLst[0], testCommentOne);

      // now, adding a new comment to the same file

      Comment testCommentTwo = Comment(
        title: 'Test Title 2',
        content: 'Test Content 2',
        audioPositionSeconds: 2,
      );

      await commentVM.addComment(
        comment: testCommentTwo,
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir: playlist.downloadPath,
        audioFileName: audio.audioFileName,
      );

      // the returned Commentlist should have two elements
      expect(commentLst.length, 2);

      // checking the content of the comments
      validateComment(commentLst[0], testCommentOne);
      validateComment(commentLst[1], testCommentTwo);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('addComment on empty comment file', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      CommentVM commentVM = CommentVM();

      Playlist playlist = Playlist(
        id: "PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99",
        url:
            "https://youtube.com/playlist?list=PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99&si=9KC7VsVt5JIUvNYN",
        title: 'local_comment',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.downloadPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}local_comment";

      Audio audio = Audio(
          enclosingPlaylist: playlist,
          originalVideoTitle:
              "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          compactVideoDescription: '',
          videoUrl: 'https://example.com/video1',
          audioDownloadDateTime: DateTime(2023, 3, 17, 12, 34, 6),
          videoUploadDate: DateTime(2023, 4, 12),
          audioPlaySpeed: 1.25);

      audio.audioFileName =
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3";

      Comment testCommentOne = Comment(
        title: 'Test Title',
        content: 'Test Content',
        audioPositionSeconds: 0,
      );

      await commentVM.addComment(
        comment: testCommentOne,
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir: playlist.downloadPath,
        audioFileName: audio.audioFileName,
      );

      // the returned Commentlist should have one element
      expect(commentLst.length, 1);

      // checking the content of the comment
      validateComment(commentLst[0], testCommentOne);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('deleteComment', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      CommentVM commentVM = CommentVM();

      Playlist playlist = Playlist(
        id: "PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99",
        url:
            "https://youtube.com/playlist?list=PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99&si=9KC7VsVt5JIUvNYN",
        title: 'local_delete_comment',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.downloadPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}local_delete_comment";

      Audio audio = Audio(
          enclosingPlaylist: playlist,
          originalVideoTitle:
              "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          compactVideoDescription: '',
          videoUrl: 'https://example.com/video1',
          audioDownloadDateTime: DateTime(2023, 3, 17, 12, 34, 6),
          videoUploadDate: DateTime(2023, 4, 12),
          audioPlaySpeed: 1.25);

      audio.audioFileName =
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3";

      // deleting comment

      await commentVM.deleteComment(
        commentId: "Test Title_0",
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir: playlist.downloadPath,
        audioFileName: audio.audioFileName,
      );

      // the returned Commentlist should have one element
      expect(commentLst.length, 1);

      // deleting the remaining comment

      await commentVM.deleteComment(
        commentId: "Test Title 2_2",
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir: playlist.downloadPath,
        audioFileName: audio.audioFileName,
      );

      // the returned Commentlist should have one element
      expect(commentLst.length, 0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('modifyComment', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
      );

      CommentVM commentVM = CommentVM();

      Playlist playlist = Playlist(
        id: "PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99",
        url:
            "https://youtube.com/playlist?list=PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99&si=9KC7VsVt5JIUvNYN",
        title: 'local_delete_comment',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlist.downloadPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}local_delete_comment";

      Audio audio = Audio(
          enclosingPlaylist: playlist,
          originalVideoTitle:
              "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
          compactVideoDescription: '',
          videoUrl: 'https://example.com/video1',
          audioDownloadDateTime: DateTime(2023, 3, 17, 12, 34, 6),
          videoUploadDate: DateTime(2023, 4, 12),
          audioPlaySpeed: 1.25);

      audio.audioFileName =
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3";

      // modifying comment

      List<Comment> commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir: playlist.downloadPath,
        audioFileName: audio.audioFileName,
      );

      Comment commentToModify = commentLst[0];

      commentToModify.title = "New title";
      commentToModify.content = "New content";
      commentToModify.audioPositionSeconds = 20;

      await commentVM.modifyComment(
        modifiedComment: commentToModify,
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      commentLst =
          await commentVM.loadExistingCommentFileOrCreateEmptyCommentFile(
        playListDir: playlist.downloadPath,
        audioFileName: audio.audioFileName,
      );

      // the returned Commentlist should have one element
      expect(commentLst.length, 2);

      validateComment(commentLst[0], commentToModify);
      expect(commentLst[0].lastUpdateDateTime,
          DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now()));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
}

void validateComment(Comment actualComment, Comment expectedComment) {
  expect(actualComment.id, expectedComment.id);
  expect(actualComment.title, expectedComment.title);
  expect(actualComment.content, expectedComment.content);
  expect(
      actualComment.audioPositionSeconds, expectedComment.audioPositionSeconds);
  expect(actualComment.creationDateTime, expectedComment.creationDateTime);
}
