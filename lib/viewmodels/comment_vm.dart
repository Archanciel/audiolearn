import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../models/audio.dart';
import '../models/comment.dart';
import '../models/playlist.dart';
import '../services/json_data_service.dart';
import '../utils/date_time_util.dart';
import '../utils/dir_util.dart';

/// This VM (View Model) class is part of the MVVM architecture.
///
/// This class manages the audio player obtained from the
class CommentVM extends ChangeNotifier {
  Duration _currentCommentStartPosition = Duration.zero;
  Duration get currentCommentStartPosition => _currentCommentStartPosition;
  set currentCommentStartPosition(Duration value) {
    _currentCommentStartPosition = value;
    notifyListeners();
  }

  Duration _currentCommentEndPosition = Duration.zero;
  Duration get currentCommentEndPosition => _currentCommentEndPosition;
  set currentCommentEndPosition(Duration value) {
    _currentCommentEndPosition = value;
    notifyListeners();
  }

  CommentVM();

  /// If the comment file exists, the list of comments it contains is
  /// returned, else, an empty list is returned.
  List<Comment> loadAudioComments({
    required Audio audio,
  }) {
    String commentFilePathName =
        buildCommentFilePathAndFilePathName(audioToComment: audio)[1];

    return JsonDataService.loadListFromFile(
      jsonPathFileName: commentFilePathName,
      type: Comment,
    );
  }

  void addComment({
    required Comment comment,
    required Audio audioToComment,
  }) {
    List<Comment> commentLst = loadAudioComments(
      audio: audioToComment,
    );

    List<String> commentDirInfo = buildCommentFilePathAndFilePathName(
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

  /// Returns a list of two strings. The first string is the path to the
  /// comment directory, and the second string is the path file name to the
  /// maybe not yet existing comment file.
  static List<String> buildCommentFilePathAndFilePathName({
    required Audio audioToComment,
  }) {
    final String playlistCommentPath =
        "${audioToComment.enclosingPlaylist!.downloadPath}${path.separator}$kCommentDirName";

    final String createdCommentFileName = audioToComment.audioFileName.replaceAll('.mp3', '.json');

    return [
      playlistCommentPath,
      "$playlistCommentPath${path.separator}${createdCommentFileName}"
    ];
  }

  void _sortAndSaveCommentLst({
    required List<Comment> commentLst,
    required String commentFilePathName,
  }) {
    commentLst.sort(
      (a, b) => a.commentStartPositionInTenthOfSeconds
          .compareTo(b.commentStartPositionInTenthOfSeconds),
    );

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: commentFilePathName,
    );
  }

  /// this method is uniquely used as a parameter for the application confirm
  /// dialog.
  void deleteCommentFunction(
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

    if (commentLst.isEmpty) {
      deleteAllAudioComments(
        commentedAudio: commentedAudio,
      );

      return;
    }

    JsonDataService.saveListToFile(
      data: commentLst,
      jsonPathFileName: buildCommentFilePathAndFilePathName(
          audioToComment: commentedAudio)[1],
    );

    notifyListeners();
  }

  /// Deletes all comments of the passed audio.
  void deleteAllAudioComments({
    required Audio commentedAudio,
  }) {
    DirUtil.deleteFileIfExist(
      pathFileName: buildCommentFilePathAndFilePathName(
        audioToComment: commentedAudio,
      )[1],
    );

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
    oldComment.commentStartPositionInTenthOfSeconds =
        modifiedComment.commentStartPositionInTenthOfSeconds;
    oldComment.commentEndPositionInTenthOfSeconds =
        modifiedComment.commentEndPositionInTenthOfSeconds;
    oldComment.lastUpdateDateTime =
        DateTimeUtil.getDateTimeLimitedToSeconds(DateTime.now());

    _sortAndSaveCommentLst(
      commentLst: commentLst,
      commentFilePathName: buildCommentFilePathAndFilePathName(
        audioToComment: commentedAudio,
      )[1],
    );

    notifyListeners();
  }

  void moveAudioCommentFileToTargetPlaylist({
    required Audio audio,
    required String targetPlaylistPath,
  }) {
    List<String> commentDirInfo = buildCommentFilePathAndFilePathName(
      audioToComment: audio,
    );

    String targetCommentDirPath =
        "$targetPlaylistPath${path.separator}$kCommentDirName";

    // Create the target comment directory if it does not exist
    DirUtil.createDirIfNotExistSync(
      pathStr: targetCommentDirPath,
    );

    // Move the comment file to the target playlist comment directory
    String commentFilePathName = commentDirInfo[1];

    if (File(commentFilePathName).existsSync()) {
      DirUtil.moveFileToDirectoryIfNotExistSync(
        sourceFilePathName: commentFilePathName,
        targetDirectoryPath: targetCommentDirPath,
      );
    }
  }

  void copyAudioCommentFileToTargetPlaylist({
    required Audio audio,
    required String targetPlaylistPath,
  }) {
    List<String> commentDirInfo = buildCommentFilePathAndFilePathName(
      audioToComment: audio,
    );

    String targetCommentDirPath =
        "$targetPlaylistPath${path.separator}$kCommentDirName";

    // Create the target comment directory if it does not exist
    DirUtil.createDirIfNotExistSync(
      pathStr: targetCommentDirPath,
    );

    // Copy the comment file to the target playlist comment directory
    String commentFilePathName = commentDirInfo[1];

    if (File(commentFilePathName).existsSync()) {
      DirUtil.copyFileToDirectorySync(
        sourceFilePathName: commentFilePathName,
        targetDirectoryPath: targetCommentDirPath,
        overwriteFileIfExist: false,
      );
    }
  }

  /// Returns all comments of all audio in the passed playlist. The
  /// comments are returned as a map with the audio file name without
  /// extension as the key.
  Map<String, List<Comment>> getAllPlaylistComments({
    required Playlist playlist,
  }) {
    String playlistPath = playlist.downloadPath;
    Map<String, List<Comment>> playlistAudiosCommentsMap = {};

    String commentPath = "$playlistPath${path.separator}$kCommentDirName";

    List<String> commentFileNamesLst = DirUtil.listFileNamesInDir(
      directoryPath: commentPath,
      fileExtension: 'json',
    );

    for (String commentFileName in commentFileNamesLst) {
      List<Comment> audioCommentsLst = JsonDataService.loadListFromFile(
        jsonPathFileName: "$commentPath${path.separator}$commentFileName",
        type: Comment,
      );

      // Remove the file extension from the comment file name. Since the
      // extension is ".json", the length of the file name is reduced by 5.
      playlistAudiosCommentsMap[commentFileName.substring(
          0, commentFileName.length - 5)] = audioCommentsLst;
    }

    return playlistAudiosCommentsMap;
  }
}
