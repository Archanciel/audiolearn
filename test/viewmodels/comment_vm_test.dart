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

void main() {
  group('CommentVM test', () {
    test('load comments, comment file not exist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
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
          "$kPlaylistDownloadRootPathWindows${path.separator}local${path.separator}$kCommentDirName${path.separator}240110-181805-Really short video 23-07-01.json";

      // the comment file should not have been created
      expect(File(createdCommentFilePathName).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('load comments, comment file exist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
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
          creationDateTime: DateTime.parse('2024-05-19T14:49:03.000'),
          lastUpdateDateTime: DateTime.parse('2024-05-19T14:49:03.000'),
        ),
        Comment.fullConstructor(
          id: 'Test Title_0',
          title: 'Test Title 1',
          content: 'Test Content\nline 2\nline 3',
          commentStartPositionInTenthOfSeconds: 3100,
          commentEndPositionInTenthOfSeconds: 5000,
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
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('get playlist comments, 3 comment files for 4 audio exist', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
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
          "$kPlaylistDownloadRootPathWindows${path.separator}S8 audio";

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

      // the returned Commentlist has 3 comments
      expect(commentsLst.length, 8);

      expect(
          commentVM.getPlaylistAudioCommentNumber(
            playlist: playlistS8,
          ),
          8);

      Comment expectedCommentOne = Comment.fullConstructor(
        id: 'One_6473',
        title: 'One',
        content:
            'First comment.\n\nChatGPT is a chatbot and virtual assistant developed by OpenAI and launched on November 30, 2022. Based on large language models (LLMs), it enables users to refine and steer a conversation towards a desired length, format, style, level of detail, and language. Successive user prompts and replies are considered at each conversation stage as context.',
        commentStartPositionInTenthOfSeconds: 6473,
        commentEndPositionInTenthOfSeconds: 6553,
        creationDateTime: DateTime.parse('2024-05-27T13:14:32.000'),
        lastUpdateDateTime: DateTime.parse('2024-05-29T13:30:03.000'),
      );
      Comment expectedCommentFive = Comment.fullConstructor(
        id: 'Comment Jancovici_430',
        title: 'Comment Jancovici',
        content:
            "Economic growth will become more and more an exception in Europe, starting from now\r\nBefore any attribution of causes, it is possible to note that the growth rate of the GDP per capita (world average) has been slowly – and constantly – decreasing since the 1960’s (I don’t have any data for the years before, that’s why I start in 1960!):",
        commentStartPositionInTenthOfSeconds: 430,
        commentEndPositionInTenthOfSeconds: 1030,
        creationDateTime: DateTime.parse('2024-07-21T16:32:42.000'),
        lastUpdateDateTime: DateTime.parse('2024-07-21T16:32:42.000'),
      );

      validateComment(commentsLst[0], expectedCommentOne);
      validateComment(commentsLst[4], expectedCommentFive);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test(
        'addComment on not exist comment file, then add new comment on same file',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
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
        comment: testCommentOne,
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
        comment: testCommentTwo,
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
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('addComment on empty comment file', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
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
        comment: testCommentOne,
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
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('deleteComment', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
      );

      const String localPlaylistTitle = 'local_delete_comment';

      // Verify that the comment file exists

      String playlistCommentFilePathName =
          "$kPlaylistDownloadRootPathWindows${path.separator}$localPlaylistTitle${path.separator}$kCommentDirName${path.separator}240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json";

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

      // Verify that the comment file no longer exist
      expect(
        File(playlistCommentFilePathName).existsSync(),
        false,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('''Of commented audio, deleteAllAudioComments. The audio is located in
            local_delete_comment playlist''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
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
          0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test(
        '''Of uncommented audio, deleteAllAudioComments. The audio is located in
            S8 audio playlist''', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
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
          0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesAndSubDirsOfDir(
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('modifyComment', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
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
          rootPath: kPlaylistDownloadRootPathWindows);
    });
  });
  group('CommentVM move and copy comment file test', () {
    test('move existing src comment file', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
      );

      CommentVM commentVM = CommentVM();

      Audio audio = createAudio(
        playlistTitle: 'local_delete_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      String targetPlaylistTitle = 'local';
      String targetPlaylistPath =
          "$kPlaylistDownloadRootPathWindows${path.separator}$targetPlaylistTitle";

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
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('move not existing src comment file', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
      );

      CommentVM commentVM = CommentVM();

      Audio audio = createAudio(
        playlistTitle: 'local',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      String targetPlaylistTitle = 'local_comment';
      String targetPlaylistPath =
          "$kPlaylistDownloadRootPathWindows${path.separator}$targetPlaylistTitle";

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
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('copy existing src comment file', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
      );

      CommentVM commentVM = CommentVM();

      Audio audio = createAudio(
        playlistTitle: 'local_delete_comment',
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      String targetPlaylistTitle = 'local';
      String targetPlaylistPath =
          "$kPlaylistDownloadRootPathWindows${path.separator}$targetPlaylistTitle";

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
          rootPath: kPlaylistDownloadRootPathWindows);
    });
    test('copy not existing src comment file', () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      DirUtil.deleteFilesAndSubDirsOfDir(
        rootPath: kPlaylistDownloadRootPathWindows,
      );

      // Copy the test initial audio data to the app dir
      DirUtil.copyFilesFromDirAndSubDirsToDirectory(
        sourceRootPath:
            "$kDownloadAppTestSavedDataDir${path.separator}audio_comment_test",
        destinationRootPath: kPlaylistDownloadRootPathWindows,
      );

      CommentVM commentVM = CommentVM();

      Audio audio = createAudio(
        playlistTitle: 'local', // contains no comment file
        audioFileName:
            "240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.mp3",
      );

      String targetPlaylistTitle = 'local_comment'; // contains no comment file
      String targetPlaylistPath =
          "$kPlaylistDownloadRootPathWindows${path.separator}$targetPlaylistTitle";

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
          rootPath: kPlaylistDownloadRootPathWindows);
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
      "$kPlaylistDownloadRootPathWindows${path.separator}$playlistTitle";

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
