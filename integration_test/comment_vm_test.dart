import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';

void main() {
  setUpAll(() async {
    // Request storage permissions
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  });

  group('CommentVM test on Android emulator', () {
    test('update audio comments on Android emulator in restore situation',
        () async {
      // Purge the test playlist directory if it exists so that the
      // playlist list is empty
      // DirUtil.deleteFilesAndSubDirsOfDir(
      //   rootPath: kPlaylistDownloadRootPathAndroidTest,
      // );

      // Copy the test initial audio data to the app dir
      // DirUtil.copyFilesFromDirAndSubDirsToDirectory(
      //   sourceRootPath:
      //       "$kApplicationPathAndroidTest",
      //   destinationRootPath: kPlaylistDownloadRootPathAndroidTest,
      // );

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

  playlist.downloadPath = path.posix.join(
    kPlaylistDownloadRootPathAndroidTest,
    playlistTitle,
  );

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
