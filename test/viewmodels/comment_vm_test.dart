import 'dart:io';
import 'dart:math';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
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
    test(
        'loadOrCreateCommentFile comment file not exist, then exist, but is empty',
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

      List<Comment> commentLst = await commentVM.loadOrCreateEmptyCommentFile(
        playListDir:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}local",
        audioFileName: '240110-181805-Really short video 23-07-01.mp3',
      );

      // the returned Commentlist should be empty
      expect(commentLst.length, 0);

      String createdCommentFilePathName =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}local${path.separator}$kCommentDirName${path.separator}240110-181805-Really short video 23-07-01.json";

      // the comment file should havve been created
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

      commentLst = await commentVM.loadOrCreateEmptyCommentFile(
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
    test('addComment where comment file not exist', () async {
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

      Comment testComment = Comment(
        title: 'Test Title',
        content: 'Test Content',
        audioPositionSeconds: 0,
        creationDateTime: DateTime(2023, 3, 24, 20, 5, 32),
      );

      await commentVM.addComment(
        comment: testComment,
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst = await commentVM.loadOrCreateEmptyCommentFile(
        playListDir: playlist.downloadPath,
        audioFileName: audio.audioFileName,
      );

      // the returned Commentlist should have one element
      expect(commentLst.length, 1);

      // checking the content of the comment
      expect(commentLst[0].title, testComment.title);
      expect(commentLst[0].content, testComment.content);
      expect(
          commentLst[0].audioPositionSeconds, testComment.audioPositionSeconds);
      expect(commentLst[0].creationDateTime, testComment.creationDateTime);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('addComment on empty comment file', () async {
      expect(true, false);
    });
    test('addComment on not empty comment file', () async {
      expect(true, false);
    });
  });
}
