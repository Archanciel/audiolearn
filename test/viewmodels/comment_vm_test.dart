import 'dart:io';

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';

/// This unit test does not pass when executed on the main branch.
void main() {
  group('CommentVM test on Windows', () {
    test('load comments, comment file not exist', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local',
        audioFileName: '240110-181805-Really short video 23-07-01.mp3',
      );

      CommentVM commentVM = CommentVM();

      // calling loadAudioComments in situation where comment file
      // does not exist

      List<Comment> commentLst = commentVM.loadAudioComments(
        audio: audio,
      );

      // the returned Commentlist should be empty
      expect(commentLst.length, 0);

      expect(
          commentVM.getCommentNumber(
            audio: audio,
          ),
          0);

      String createdCommentFilePathName =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}local${path.separator}$kCommentDirName${path.separator}240110-181805-Really short video 23-07-01.json";

      // the comment file should not have been created
      expect(File(createdCommentFilePathName).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('load comments, comment file exist', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local_delete_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      CommentVM commentVM = CommentVM();

      // calling loadAudioComments in situation where comment file
      // exists and has 3 comments

      List<Comment> commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist has 3 comments
      expect(commentLst.length, 3);

      expect(
          commentVM.getCommentNumber(
            audio: audio,
          ),
          3);

      List<Comment> expectedCommentsLst = [
        Comment.fullConstructor(
          id: 'Test Title 2_2',
          title: 'Test Title 2',
          content: 'Test Content 2\nline 2\nline 3\nline four\nline 5',
          commentStartPositionInTenthOfSeconds: 600,
          commentEndPositionInTenthOfSeconds: 1800,
          soundReductionPosition: 0.0,
          soundReductionDuration: 0.0,
          creationDateTime: DateTime.parse('2023-03-26T00:05:32.000'),
          lastUpdateDateTime: DateTime.parse('2024-05-19T15:23:51.000'),
        ),
        Comment.fullConstructor(
          id: 'number 3_8',
          title: 'number 3',
          content:
              'A complete example showcasing all audioplayers features can be found in our repository. Also check out our live web app.',
          commentStartPositionInTenthOfSeconds: 800,
          commentEndPositionInTenthOfSeconds: 2800,
          soundReductionPosition: 0.0,
          soundReductionDuration: 0.0,
          creationDateTime: DateTime.parse('2024-05-19T14:49:03.000'),
          lastUpdateDateTime: DateTime.parse('2024-05-19T14:49:03.000'),
        ),
        Comment.fullConstructor(
          id: 'Test Title_0',
          title: 'Test Title 1',
          content: 'Test Content\nline 2\nline 3',
          commentStartPositionInTenthOfSeconds: 3100,
          commentEndPositionInTenthOfSeconds: 5000,
          soundReductionPosition: 0.0,
          soundReductionDuration: 0.0,
          creationDateTime: DateTime.parse('2023-03-24T20:05:32.000'),
          lastUpdateDateTime: DateTime.parse('2024-05-19T14:46:05.000'),
        ),
      ];

      for (int i = 0; i < commentLst.length; i++) {
        validateComment(commentLst[i], expectedCommentsLst[i]);
      }

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('load comments from file, file exist', () async {
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

      // calling loadAudioComments in situation where comment file
      // exists and has 3 comments

      List<Comment> commentLst = commentVM.loadCommentsFromFile(
        commentFilePathName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}local_delete_comment${path.separator}$kCommentDirName${path.separator}240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json",
      );

      // the returned Commentlist has 3 comments
      expect(commentLst.length, 3);

      List<Comment> expectedCommentsLst = [
        Comment.fullConstructor(
          id: 'Test Title 2_2',
          title: 'Test Title 2',
          content: 'Test Content 2\nline 2\nline 3\nline four\nline 5',
          commentStartPositionInTenthOfSeconds: 600,
          commentEndPositionInTenthOfSeconds: 1800,
          soundReductionPosition: 0.0,
          soundReductionDuration: 0.0,
          creationDateTime: DateTime.parse('2023-03-26T00:05:32.000'),
          lastUpdateDateTime: DateTime.parse('2024-05-19T15:23:51.000'),
        ),
        Comment.fullConstructor(
          id: 'number 3_8',
          title: 'number 3',
          content:
              'A complete example showcasing all audioplayers features can be found in our repository. Also check out our live web app.',
          commentStartPositionInTenthOfSeconds: 800,
          commentEndPositionInTenthOfSeconds: 2800,
          soundReductionPosition: 0.0,
          soundReductionDuration: 0.0,
          creationDateTime: DateTime.parse('2024-05-19T14:49:03.000'),
          lastUpdateDateTime: DateTime.parse('2024-05-19T14:49:03.000'),
        ),
        Comment.fullConstructor(
          id: 'Test Title_0',
          title: 'Test Title 1',
          content: 'Test Content\nline 2\nline 3',
          commentStartPositionInTenthOfSeconds: 3100,
          commentEndPositionInTenthOfSeconds: 5000,
          soundReductionPosition: 0.0,
          soundReductionDuration: 0.0,
          creationDateTime: DateTime.parse('2023-03-24T20:05:32.000'),
          lastUpdateDateTime: DateTime.parse('2024-05-19T14:46:05.000'),
        ),
      ];

      for (int i = 0; i < commentLst.length; i++) {
        validateComment(commentLst[i], expectedCommentsLst[i]);
      }

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('load comments from file, file not exist', () async {
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

      // calling loadAudioComments in situation where comment file
      // exists and has 3 comments

      List<Comment> commentLst = commentVM.loadCommentsFromFile(
        commentFilePathName:
            "$kPlaylistDownloadRootPathWindowsTest${path.separator}local_delete_comment${path.separator}$kCommentDirName${path.separator}240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique.json",
      );

      // the returned Commentlist has 3 comments
      expect(commentLst.length, 0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('get playlist comments, 3 comment files for 4 audio exist', () async {
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

      // calling loadAudioComments in situation where comment file
      // exists and has 3 comments

      Playlist playlistS8 = Playlist(
        id: "PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99",
        url:
            "https://youtube.com/playlist?list=PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99&si=9KC7VsVt5JIUvNYN",
        title: 'S8 audio',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      playlistS8.downloadPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio";

      // Deleting comment file used in another test
      DirUtil.deleteFileIfExist(
          pathFileName:
              "${playlistS8.downloadPath}${path.separator}$kCommentDirName${path.separator}New file name.json");

      Map<String, List<Comment>> playlistAudiosCommentsMap =
          commentVM.getPlaylistAudioComments(
        playlist: playlistS8,
      );

      List<String> audioFileNamesLst = playlistAudiosCommentsMap.keys.toList();

      expect(audioFileNamesLst.length, 3);

      audioFileNamesLst.sort((a, b) => a.compareTo(b));

      expect(audioFileNamesLst[0],
          "240528-130636-Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité... 24-01-12");
      expect(audioFileNamesLst[1],
          "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12");
      expect(audioFileNamesLst[2],
          "240722-081104-Quand Aurélien Barrau va dans une école de management 23-09-10");

      // List<String> audioFileNamesLst = playlistAudiosCommentsMap.keys.toList();
      List<Comment> commentsLst = playlistAudiosCommentsMap.values
          .expand((element) => element)
          .toList();

      // the returned Commentlist has 10 comments
      expect(commentsLst.length, 10);

      expect(
          commentVM.getPlaylistAudioCommentNumber(
            playlist: playlistS8,
          ),
          10);

      Comment expectedCommentOne = Comment.fullConstructor(
        id: 'One_6473',
        title: 'One',
        content:
            'First comment.\n\nChatGPT is a chatbot and virtual assistant developed by OpenAI and launched on November 30, 2022. Based on large language models (LLMs), it enables users to refine and steer a conversation towards a desired length, format, style, level of detail, and language. Successive user prompts and replies are considered at each conversation stage as context.',
        commentStartPositionInTenthOfSeconds: 6473,
        commentEndPositionInTenthOfSeconds: 6553,
        soundReductionPosition: 0.0,
        soundReductionDuration: 0.0,
        creationDateTime: DateTime.parse('2024-05-27T13:14:32.000'),
        lastUpdateDateTime: DateTime.parse('2024-05-29T13:30:03.000'),
      );
      Comment expectedCommentFive = Comment.fullConstructor(
        id: 'To end_46727',
        title: 'To end',
        content: "",
        commentStartPositionInTenthOfSeconds: 46717,
        commentEndPositionInTenthOfSeconds: 46737,
        soundReductionPosition: 0.0,
        soundReductionDuration: 0.0,
        creationDateTime: DateTime.parse('2025-06-06 12:48:25.000'),
        lastUpdateDateTime: DateTime.parse('2025-06-06 12:48:25.000'),
      );

      validateComment(commentsLst[0], expectedCommentOne);
      validateComment(commentsLst[4], expectedCommentFive);

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

      Audio audio = createAudio(
        playlistTitle: 'S8 audio',
        audioFileName:
            "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
      );

      Comment testCommentOne = Comment(
        title: 'Test Title',
        content: 'Test Content',
        commentStartPositionInTenthOfSeconds: 3000,
        commentEndPositionInTenthOfSeconds: 5000,
      );

      commentVM.addComment(
        addedComment: testCommentOne,
        audioToComment: audio,
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have one element
      expect(commentLst.length, 1);

      // checking the content of the comment
      validateComment(commentLst[0], testCommentOne);

      // now, adding a new comment to the same file

      Comment testCommentTwo = Comment(
        title: 'Test Title 2',
        content: 'Test Content 2',
        commentStartPositionInTenthOfSeconds: 201,
        commentEndPositionInTenthOfSeconds: 501,
      );

      commentVM.addComment(
        addedComment: testCommentTwo,
        audioToComment: audio,
      );

      // now loading the comment list from the comment file

      commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have two elements
      expect(commentLst.length, 2);

      expect(
          commentVM.getCommentNumber(
            audio: audio,
          ),
          2);

      // checking the content of the comments. Since the comments are
      // sorted by audioPositionSeconds, the first comment should be
      // testCommentTwo and the second testCommentOne
      validateComment(commentLst[0], testCommentTwo);
      validateComment(commentLst[1], testCommentOne);

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

      Audio audio = createAudio(
        playlistTitle: 'local_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      Comment testCommentOne = Comment(
        title: 'Test Title',
        content: 'Test Content',
        commentStartPositionInTenthOfSeconds: 0,
        commentEndPositionInTenthOfSeconds: 10,
      );

      commentVM.addComment(
        addedComment: testCommentOne,
        audioToComment: audio,
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have one element
      expect(commentLst.length, 1);

      expect(
          commentVM.getCommentNumber(
            audio: audio,
          ),
          1);

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

      const String localPlaylistTitle = 'local_delete_comment';

      // Verify that the comment file exists

      final String playlistCommentPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}$localPlaylistTitle${path.separator}$kCommentDirName';
      final String playlistCommentFilePathName =
          "$playlistCommentPath${path.separator}240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json";

      expect(
        File(playlistCommentFilePathName).existsSync(),
        true,
      );

      CommentVM commentVM = CommentVM();

      Audio audio = createAudio(
        playlistTitle: localPlaylistTitle,
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      // deleting comment

      commentVM.deleteComment(
        commentId: "Test Title_0",
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have two elements
      expect(commentLst.length, 2);

      expect(
          commentVM.getCommentNumber(
            audio: audio,
          ),
          2);

      // deleting the remaining comments

      commentVM.deleteComment(
        commentId: "Test Title 2_2",
        commentedAudio: audio,
      );

      commentVM.deleteComment(
        commentId: "number 3_8",
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have zero element
      expect(commentLst.length, 0);

      // Verify that the comment dir was deleted
      expect(Directory(playlistCommentPath).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('''Of commented audio, deleteAllAudioComments. The audio is located in
            local_delete_comment playlist''', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local_delete_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have three elements
      expect(commentLst.length, 3);

      // deleting all the comments of the audio
      commentVM.deleteAllAudioComments(
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have 0 elements
      expect(commentLst.length, 0);

      expect(
        commentVM.getCommentNumber(
          audio: audio,
        ),
        0,
      );

      final String playlistCommentPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}local_delete_comment${path.separator}$kCommentDirName';

      // Verify that the comment dir was deleted
      expect(Directory(playlistCommentPath).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        '''Of uncommented audio, deleteAllAudioComments. The audio is located in
            S8 audio playlist''', () async {
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

      // This audio has no comment file
      Audio audio = createAudio(
        playlistTitle: 'S8 audio',
        audioFileName:
            "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03.mp3",
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have three elements
      expect(commentLst.length, 0);

      // deleting all the comments of the audio
      commentVM.deleteAllAudioComments(
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have 0 elements
      expect(commentLst.length, 0);

      expect(
        commentVM.getCommentNumber(
          audio: audio,
        ),
        0,
      );

      final String playlistCommentPath =
          '$kPlaylistDownloadRootPathWindowsTest${path.separator}S8 audio${path.separator}$kCommentDirName';

      // Verify that the comment dir was not deleted since another audio
      // has a comment file in it
      expect(Directory(playlistCommentPath).existsSync(), true);

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

      Audio audio = createAudio(
        playlistTitle: 'local_delete_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      // modifying comment

      List<Comment> commentLst = commentVM.loadAudioComments(audio: audio);

      Comment commentToModify = commentLst[1];

      commentToModify.title = "New title modified";
      commentToModify.content = "New content modified";
      commentToModify.commentStartPositionInTenthOfSeconds = 40100;
      commentToModify.commentEndPositionInTenthOfSeconds = 48100;

      commentVM.modifyComment(
        modifiedComment: commentToModify,
        commentedAudio: audio,
      );

      // now loading the comment list from the comment file

      commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have three element
      expect(commentLst.length, 3);

      validateComment(commentLst[2], commentToModify);
      expect(commentLst[2].lastUpdateDateTime,
          DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now()));

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        '''update audio comments in restore situation with adding and modifying comments to audio
          already having comments.''', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local_delete_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      // Creating updated comments list

      Comment addedComment = Comment(
        title: "New comment",
        content: "New comment content",
        commentStartPositionInTenthOfSeconds: 1000,
        commentEndPositionInTenthOfSeconds: 2000,
      );

      Comment firstModifiedComment = Comment(
        title: "First title modified",
        content: "First content modified",
        commentStartPositionInTenthOfSeconds: 4100,
        commentEndPositionInTenthOfSeconds: 6000,
      );
      firstModifiedComment.id = "Test Title_0";
      firstModifiedComment.creationDateTime =
          DateTime.parse('2023-03-24T20:05:32.000');
      firstModifiedComment.lastUpdateDateTime =
          DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

      List<Comment> commentLst = commentVM.loadAudioComments(
        audio: audio,
      );

      // This modiied comment does not have a lastUpdateDateTime later
      // than the lastUpdateDateTime of the corresponding comment and
      // so will not be applied.
      Comment secondModifiedComment = Comment(
        title: "Second title modified",
        content: "Second content modified",
        commentStartPositionInTenthOfSeconds: 4100,
        commentEndPositionInTenthOfSeconds: 6000,
      );
      secondModifiedComment.id = "Test Title 2_2";
      secondModifiedComment.lastUpdateDateTime =
          commentLst[0].lastUpdateDateTime;

      List<Comment> updatedCommentLst = commentLst.map((comment) {
        if (comment.id == "Test Title_0") {
          // this is the comment to modify
          comment.title = firstModifiedComment.title;
          comment.content = firstModifiedComment.content;
          comment.commentStartPositionInTenthOfSeconds =
              firstModifiedComment.commentStartPositionInTenthOfSeconds;
          comment.commentEndPositionInTenthOfSeconds =
              firstModifiedComment.commentEndPositionInTenthOfSeconds;
          comment.lastUpdateDateTime = firstModifiedComment.lastUpdateDateTime;
          return comment;
        } else if (comment.id == "Test Title 2_2") {
          comment.title = secondModifiedComment.title;
          comment.content = secondModifiedComment.content;
          comment.commentStartPositionInTenthOfSeconds =
              secondModifiedComment.commentStartPositionInTenthOfSeconds;
          comment.commentEndPositionInTenthOfSeconds =
              secondModifiedComment.commentEndPositionInTenthOfSeconds;
          // Last update date time is not modified
          return comment;
        } else {
          // the other comments are not modified
          return comment;
        }
        // modifying the comment
      }).toList();

      // adding a new comment to the updated comment list
      updatedCommentLst.add(addedComment);

      List<int> updateNumberLst = commentVM.updateAudioComments(
        commentedAudio: audio,
        updateCommentsLst: updatedCommentLst,
      );

      // now loading the comment list from the comment file

      commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have four elements
      expect(commentLst.length, 4);

      validateComment(commentLst[0], commentLst[0]); // unchanged comment
      validateComment(commentLst[1], commentLst[1]); // unchanged comment
      validateComment(commentLst[2], addedComment);
      validateComment(commentLst[3], firstModifiedComment);

      expect(updateNumberLst[0], 1); // modified comment number
      expect(updateNumberLst[1], 1); // added comment number

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        '''update audio comments in restore situation with adding comments to audio not yet having
          comments.''', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      // Creating added comment list

      Comment addedComment = Comment(
        title: "New comment",
        content: "New comment content",
        commentStartPositionInTenthOfSeconds: 1000,
        commentEndPositionInTenthOfSeconds: 2000,
      );

      // adding a new comment to the updated comment list
      List<Comment> updatedCommentLst = [];

      updatedCommentLst.add(addedComment);

      List<int> updateNumberLst = commentVM.updateAudioComments(
        commentedAudio: audio,
        updateCommentsLst: updatedCommentLst,
      );

      // now loading the comment list from the comment file

      List<Comment> commentLst = commentVM.loadAudioComments(audio: audio);

      // the returned Commentlist should have three element
      expect(commentLst.length, 1);

      validateComment(commentLst[0], addedComment);

      expect(updateNumberLst[0], 0); // modified comment number
      expect(updateNumberLst[1], 0); // added comment number
      expect(updateNumberLst[2], 1); // added comment json file number

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('CommentVM move and copy comment file test', () {
    test('move existing src comment file', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local_delete_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      String targetPlaylistTitle = 'local';
      String targetPlaylistPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle";

      List<String> sourceCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath:
              "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName",
          fileExtension: 'json');
      List<String> targetCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath: "$targetPlaylistPath${path.separator}$kCommentDirName",
          fileExtension: 'json');

      expect(sourceCommentFileNameLst.length, 1);
      expect(targetCommentFileNameLst.length, 0);

      commentVM.moveAudioCommentFileToTargetPlaylist(
        targetPlaylistPath: targetPlaylistPath,
        audio: audio,
      );

      sourceCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath:
              "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName",
          fileExtension: 'json');
      targetCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath: "$targetPlaylistPath${path.separator}$kCommentDirName",
          fileExtension: 'json');

      expect(sourceCommentFileNameLst.length, 0);
      expect(targetCommentFileNameLst.length, 1);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('move not existing src comment file', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      String targetPlaylistTitle = 'local_comment';
      String targetPlaylistPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle";

      List<String> sourceCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath:
              "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName",
          fileExtension: 'json');
      List<String> targetCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath: "$targetPlaylistPath${path.separator}$kCommentDirName",
          fileExtension: 'json');

      expect(sourceCommentFileNameLst.length, 0);
      expect(targetCommentFileNameLst.length, 0);

      commentVM.moveAudioCommentFileToTargetPlaylist(
        targetPlaylistPath: targetPlaylistPath,
        audio: audio,
      );

      sourceCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath:
              "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName",
          fileExtension: 'json');
      targetCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath: "$targetPlaylistPath${path.separator}$kCommentDirName",
          fileExtension: 'json');

      expect(sourceCommentFileNameLst.length, 0);
      expect(targetCommentFileNameLst.length, 0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('copy existing src comment file', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local_delete_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      String targetPlaylistTitle = 'local';
      String targetPlaylistPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle";

      List<String> sourceCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath:
              "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName",
          fileExtension: 'json');
      List<String> targetCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath: "$targetPlaylistPath${path.separator}$kCommentDirName",
          fileExtension: 'json');

      expect(sourceCommentFileNameLst.length, 1);
      expect(targetCommentFileNameLst.length, 0);

      commentVM.copyAudioCommentFileToTargetPlaylist(
        targetPlaylistPath: targetPlaylistPath,
        audio: audio,
      );

      sourceCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath:
              "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName",
          fileExtension: 'json');
      targetCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath: "$targetPlaylistPath${path.separator}$kCommentDirName",
          fileExtension: 'json');

      expect(sourceCommentFileNameLst.length, 1);
      expect(targetCommentFileNameLst.length, 1);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('copy not existing src comment file', () async {
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

      Audio audio = createAudio(
        playlistTitle: 'local', // contains no comment file
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      String targetPlaylistTitle = 'local_comment'; // contains no comment file
      String targetPlaylistPath =
          "$kPlaylistDownloadRootPathWindowsTest${path.separator}$targetPlaylistTitle";

      List<String> sourceCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath:
              "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName",
          fileExtension: 'json');
      List<String> targetCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath: "$targetPlaylistPath${path.separator}$kCommentDirName",
          fileExtension: 'json');

      expect(sourceCommentFileNameLst.length, 0);
      expect(targetCommentFileNameLst.length, 0);

      commentVM.copyAudioCommentFileToTargetPlaylist(
        targetPlaylistPath: targetPlaylistPath,
        audio: audio,
      );

      sourceCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath:
              "${audio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName",
          fileExtension: 'json');
      targetCommentFileNameLst = DirUtil.listFileNamesInDir(
          directoryPath: "$targetPlaylistPath${path.separator}$kCommentDirName",
          fileExtension: 'json');

      expect(sourceCommentFileNameLst.length, 0);
      expect(targetCommentFileNameLst.length, 0);

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
  expect(actualComment.commentStartPositionInTenthOfSeconds,
      expectedComment.commentStartPositionInTenthOfSeconds);
  expect(actualComment.commentEndPositionInTenthOfSeconds,
      expectedComment.commentEndPositionInTenthOfSeconds);
  expect(actualComment.creationDateTime, expectedComment.creationDateTime);
}

Audio createAudio({
  required String playlistTitle,
  required String audioFileName,
}) {
  Playlist playlist = Playlist(
    id: "PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99",
    url:
        "https://youtube.com/playlist?list=PLzwWSJNcZTMSVHGopMEjlfR7i5qtqbW99&si=9KC7VsVt5JIUvNYN",
    title: playlistTitle,
    playlistType: PlaylistType.youtube,
    playlistQuality: PlaylistQuality.voice,
  );

  playlist.downloadPath =
      "$kPlaylistDownloadRootPathWindowsTest${path.separator}$playlistTitle";

  Audio audio = Audio(
      enclosingPlaylist: playlist,
      originalVideoTitle:
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique",
      compactVideoDescription: '',
      videoUrl: 'https://example.com/video1',
      audioDownloadDateTime: DateTime(2023, 3, 17, 12, 34, 6),
      videoUploadDate: DateTime(2023, 4, 12),
      audioDuration: Duration.zero,
      audioPlaySpeed: 1.25);

  audio.audioFileName = audioFileName;

  return audio;
}
