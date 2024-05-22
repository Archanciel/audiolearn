import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../models/audio.dart';
import '../models/comment.dart';
import '../services/json_data_service.dart';
import '../utils/date_time_util.dart';
import '../utils/dir_util.dart';

/// This VM (View Model) class is part of the MVVM architecture.
///
/// This class manages the audio player obtained from the
class CommentVM extends ChangeNotifier {
  Duration _currentCommentAudioPosition = Duration.zero;
  Duration get currentCommentAudioPosition => _currentCommentAudioPosition;
  set currentCommentAudioPosition(Duration value) {
    _currentCommentAudioPosition = value;
    notifyListeners();
  }

  CommentVM();

  /// If the comment file exists, the list of comments it contains is
  /// returned. Else, an empty list is returned.
  List<Comment> loadAudioComments({
    required Audio audio,
  }) {
    String commentFilePathName =_createCommentFilePathAndFilePathName(audioToComment: audio)[1];
    File commentFile =
        File(commentFilePathName);

    List<Comment> commentLst = [];

    if (commentFile.existsSync()) {
      // Load the comment list from the json comment file
      commentLst = JsonDataService.loadListFromFile(
        jsonPathFileName: commentFilePathName,
        type: Comment,
      );
    }

    return commentLst;
  }

  void addComment({
    required Comment comment,
    required Audio audioToComment,
  }) {
    List<Comment> commentLst = loadAudioComments(
      audio: audioToComment,
    );

    List<String> commentDirInfo = _createCommentFilePathAndFilePathName(
      audioToComment: audioToComment,
    );

    if (commentLst.isEmpty) {
      // Create the comment dir so that the comment file can be created
      DirUtil.createDirIfNotExistSync(
        pathStr: commentDirInfo[0],
      );
    }

    commentLst.add(comment);

    _sortAndSaveCommentLst(
      commentLst: commentLst,
      commentFilePathName: commentDirInfo[1],
    );

    // Add comment to the database
    notifyListeners();
  }

  List<String> _createCommentFilePathAndFilePathName({
    required Audio audioToComment,
  }) {
    String playlistCommentPath =
        "${audioToComment.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName";

    return [
      playlistCommentPath,
      "$playlistCommentPath${path.separator}${_createCommentFileName(audioToComment.audioFileName)}"
    ];
  }

  void _sortAndSaveCommentLst({
    required List<Comment> commentLst,
    required String commentFilePathName,
  }) {
    commentLst.sort(
      (a, b) => a.audioPositionInTenthOfSeconds
          .compareTo(b.audioPositionInTenthOfSeconds),
    );

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: commentFilePathName,
    );
  }

  /// this method is uniquely used as a parameter for the application confirm
  /// dialog.
  void deleteCommentParmsNotNamed(
    String commentId,
    Audio commentedAudio,
  ) {
    deleteComment(
      commentId: commentId,
      commentedAudio: commentedAudio,
    );
  }

  void deleteComment({
    required String commentId,
    required Audio commentedAudio,
  }) {
    List<Comment> commentLst = loadAudioComments(
      audio: commentedAudio,
    );

    commentLst.remove(
      commentLst.firstWhere(
        (element) => element.id == commentId,
      ),
    );

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: _createCommentFilePathAndFilePathName(
          audioToComment: commentedAudio)[1],
    );

    // Delete comment from the database
    notifyListeners();
  }

  void modifyComment({
    required Comment modifiedComment,
    required Audio commentedAudio,
  }) {
    List<Comment> commentLst = loadAudioComments(
      audio: commentedAudio,
    );

    Comment oldComment = commentLst.firstWhere(
      (element) => element.id == modifiedComment.id,
    );

    oldComment.title = modifiedComment.title;
    oldComment.content = modifiedComment.content;
    oldComment.audioPositionInTenthOfSeconds =
        modifiedComment.audioPositionInTenthOfSeconds;
    oldComment.lastUpdateDateTime =
        DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

    _sortAndSaveCommentLst(
      commentLst: commentLst,
      commentFilePathName: _createCommentFilePathAndFilePathName(
        audioToComment: commentedAudio,
      )[1],
    );

    notifyListeners();
  }

  String _createCommentFileName(String audioFileName) =>
      audioFileName.replaceAll('.mp3', '.json');
}
