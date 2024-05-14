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

  List<Comment> loadExistingCommentFileOrCreateEmptyCommentFile({
    required Audio commentedAudio,
  }) {
    String commentFileName =
        _createCommentFileName(commentedAudio.audioFileName);
    String playlistCommentPath =
        "${commentedAudio.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName";
    String commentFilePathName =
        "$playlistCommentPath${path.separator}$commentFileName";
    File commentFile = File(commentFilePathName);

    // Load the list from the file
    List<Comment> commentLst = [];

    if (commentFile.existsSync()) {
      // Load the comment file
      commentLst = JsonDataService.loadListFromFile(
        jsonPathFileName: commentFilePathName,
        type: Comment,
      );
    } else {
      // Create the comment file
      DirUtil.createDirIfNotExistSync(
        pathStr: playlistCommentPath,
      );

      JsonDataService.saveListToFile(
        data: commentLst,
        jsonPathFileName: commentFilePathName,
      );
    }

    return commentLst;
  }

  void addComment({
    required Comment comment,
    required Audio commentedAudio,
  }) {
    String playListDir = commentedAudio.enclosingPlaylist!.downloadPath;

    List<Comment> commentLst = loadExistingCommentFileOrCreateEmptyCommentFile(
      commentedAudio: commentedAudio,
    );

    commentLst.add(comment);

    String commentFilePathName =
        "$playListDir${path.separator}$kCommentDirName${path.separator}${_createCommentFileName(commentedAudio.audioFileName)}";

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: commentFilePathName,
    );

    // Add comment to the database
    notifyListeners();
  }

  void deleteComment({
    required String commentId,
    required Audio commentedAudio,
  }) {
    String playListDir = commentedAudio.enclosingPlaylist!.downloadPath;

    List<Comment> commentLst = loadExistingCommentFileOrCreateEmptyCommentFile(
      commentedAudio: commentedAudio,
    );

    commentLst.remove(
      commentLst.firstWhere(
        (element) => element.id == commentId,
      ),
    );

    String commentFilePathName =
        "$playListDir${path.separator}$kCommentDirName${path.separator}${_createCommentFileName(commentedAudio.audioFileName)}";

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: commentFilePathName,
    );

    // Delete comment from the database
    notifyListeners();
  }

  void modifyComment({
    required Comment modifiedComment,
    required Audio commentedAudio,
  }) {
    String playListDir = commentedAudio.enclosingPlaylist!.downloadPath;

    List<Comment> commentLst = loadExistingCommentFileOrCreateEmptyCommentFile(
      commentedAudio: commentedAudio,
    );

    Comment oldComment = commentLst.firstWhere(
      (element) => element.id == modifiedComment.id,
    );

    oldComment.title = modifiedComment.title;
    oldComment.content = modifiedComment.content;
    oldComment.audioPositionSeconds = modifiedComment.audioPositionSeconds;
    oldComment.lastUpdateDateTime =
        DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

    String commentFilePathName =
        "$playListDir${path.separator}$kCommentDirName${path.separator}${_createCommentFileName(commentedAudio.audioFileName)}";

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: commentFilePathName,
    );

    notifyListeners();
  }

  String _createCommentFileName(String audioFileName) =>
      audioFileName.replaceAll('.mp3', '.json');
}
